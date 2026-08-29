import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../widgets/tactical_button.dart';

import '../../models/pairing_payload.dart';
import '../pairing/qr_scanner_screen.dart';

class JoinGroupDialog extends ConsumerStatefulWidget {
  const JoinGroupDialog({super.key});

  @override
  ConsumerState<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends ConsumerState<JoinGroupDialog> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedPayload(PairingPayload payload) async {
    if (payload is GroupInvitePayload) {
      _tokenController.text = payload.toUri();
      await _joinWithPayload(payload);
    } else if (payload is PeerPairingPayload) {
      final activeGroup = ref.read(activeGroupProvider);
      final targetGid = payload.groupId ?? activeGroup?.id;
      if (targetGid == null) {
        setState(() {
          _errorMessage = 'No active group selected for peer pairing';
        });
        return;
      }
      setState(() => _isLoading = true);
      try {
        await ref.read(friendRepositoryProvider).registerPeer(
              deviceId: payload.deviceId,
              groupId: targetGid,
              nickname: payload.alias ?? 'PEER-${payload.deviceId.substring(0, 4).toUpperCase()}',
              publicKey: payload.publicKey,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: TacticalColors.primaryContainer,
              content: Text(
                'Peer ${payload.alias ?? payload.deviceId.substring(0, 6)} paired successfully!',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinWithPayload(GroupInvitePayload payload) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final joined = await ref
          .read(groupRepositoryProvider)
          .joinGroup(payload.groupId, payload.inviteSecret);
      ref.read(activeGroupProvider.notifier).state = joined;
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to join group: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _join() async {
    final raw = _tokenController.text.trim();
    if (raw.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final payload = PairingPayload.parse(raw);
      if (payload is GroupInvitePayload) {
        await _joinWithPayload(payload);
      } else if (payload is PeerPairingPayload) {
        await _handleScannedPayload(payload);
      }
    } catch (e) {
      // Fallback: If it was a plain group ID / token
      try {
        final joined = await ref
            .read(groupRepositoryProvider)
            .joinGroup(raw, 'sec_token');
        ref.read(activeGroupProvider.notifier).state = joined;
        if (mounted) Navigator.pop(context);
      } catch (fallbackError) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceAll('InvalidPairingPayloadException: ', '');
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TacticalColors.surfaceBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TacticalColors.violetAux, width: 1),
      ),
      title: const Row(
        children: [
          Icon(Icons.login, color: TacticalColors.violetAux),
          SizedBox(width: 8),
          Text(
            'JOIN GROUP',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paste an invite string or scan a QR code from a group member.',
            style: TextStyle(fontSize: 12, color: TacticalColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            style: const TextStyle(
              color: TacticalColors.textPrimary,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: 'shadowtrace://v1/join?gid=...',
              hintStyle: TextStyle(
                color: TacticalColors.textTertiary,
                fontSize: 11,
              ),
              border: OutlineInputBorder(),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TacticalColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: TacticalColors.error),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: TacticalColors.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TacticalButton(
            label: 'SCAN QR CODE',
            icon: Icons.camera_alt_outlined,
            variant: TacticalButtonVariant.secondary,
            isFullWidth: true,
            onPressed: () async {
              final payload = await Navigator.push<PairingPayload?>(
                context,
                MaterialPageRoute(
                  builder: (_) => const QrScannerScreen(
                    title: 'SCAN INVITE / PEER QR',
                  ),
                ),
              );
              if (payload != null && mounted) {
                await _handleScannedPayload(payload);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: TacticalColors.textSecondary),
          ),
        ),
        TacticalButton(
          label: _isLoading ? 'JOINING...' : 'CONFIRM JOIN',
          onPressed: _isLoading ? null : _join,
        ),
      ],
    );
  }
}
