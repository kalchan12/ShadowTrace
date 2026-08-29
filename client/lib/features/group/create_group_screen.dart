import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../models/group.dart';
import '../../widgets/tactical_qr_widget.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'NIGHT OPS',
  );
  bool _isCreated = false;
  bool _isLoading = false;
  Group? _createdGroup;
  String _inviteUri = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: Stack(
        children: [
          // Cyber Grid
          CustomPaint(size: Size.infinite, painter: _CyberGridPainter()),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _isCreated ? _buildCreatedView() : _buildCreateView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateView() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: const Color(0xD90D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TacticalColors.borderHud, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.groups,
                color: TacticalColors.primaryContainer,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'CREATE GROUP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TacticalColors.primaryFixedDim,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: TacticalColors.borderHud),
          const SizedBox(height: 20),

          // Input
          const Text(
            'CHOOSE A GROUP NAME',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: TacticalColors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF05070A),
              border: Border(
                bottom: BorderSide(
                  color: TacticalColors.primaryContainer,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: TacticalColors.onSurface,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'ENTER CLASSIFICATION',
                      hintStyle: TextStyle(
                        color: TacticalColors.outlineVariant,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(
                  Icons.edit,
                  size: 16,
                  color: TacticalColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: TacticalColors.outlineVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TacticalColors.onSurface,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          try {
                            final group = await ref
                                .read(groupRepositoryProvider)
                                .createGroup();
                            ref.read(activeGroupProvider.notifier).state = group;
                            setState(() {
                              _createdGroup = group;
                              _inviteUri =
                                  'shadowtrace://v1/join?gid=${group.id}&sec=${group.inviteSecret ?? ""}';
                              _isCreated = true;
                            });
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TacticalColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 4,
                    shadowColor: TacticalColors.primaryContainer,
                  ),
                  child: Text(
                    _isLoading ? 'CREATING...' : 'CREATE',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedView() {
    final gid = _createdGroup?.id ?? 'UNKNOWN';

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: const Color(0xD90D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TacticalColors.primaryContainer.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TacticalColors.primaryContainer.withValues(alpha: 0.1),
              border: Border.all(
                color: TacticalColors.primaryContainer,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.done_all,
              color: TacticalColors.primaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'GROUP CREATED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TacticalColors.primaryFixedDim,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _nameController.text.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Share this QR code with your trusted peers.',
            style: TextStyle(
              fontSize: 13,
              color: TacticalColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic QR Code
          TacticalQrWidget(
            data: _inviteUri,
            size: 160,
            showCopyButton: false,
          ),
          const SizedBox(height: 16),

          // Invite Code Block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GROUP IDENTIFIER',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TacticalColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF05070A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: TacticalColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'ID: ${gid.length > 16 ? "${gid.substring(0, 16)}..." : gid}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.primaryContainer,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.content_copy,
                        size: 18,
                        color: TacticalColors.onSurfaceVariant,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _inviteUri));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite URI copied!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Done Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TacticalColors.primaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'DONE',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0x0FFFFFFF)
      ..strokeWidth = 1.0;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
