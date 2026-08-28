import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../widgets/tactical_button.dart';

class JoinGroupDialog extends ConsumerStatefulWidget {
  const JoinGroupDialog({super.key});

  @override
  ConsumerState<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends ConsumerState<JoinGroupDialog> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final joined = await ref
          .read(groupRepositoryProvider)
          .joinGroup(token, 'sec_token');
      ref.read(activeGroupProvider.notifier).state = joined;
      if (mounted) Navigator.pop(context);
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
          const SizedBox(height: 12),
          TacticalButton(
            label: 'SCAN QR CODE',
            icon: Icons.camera_alt_outlined,
            variant: TacticalButtonVariant.secondary,
            isFullWidth: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera QR scanner ready for Phase 5'),
                ),
              );
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
