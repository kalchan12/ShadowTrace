import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/utils/coordinate_formatter.dart';
import '../../models/group.dart';
import '../../widgets/tactical_button.dart';
import '../../widgets/tactical_qr_widget.dart';

class CreateGroupDialog extends StatelessWidget {
  final Group group;

  const CreateGroupDialog({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final inviteUri =
        'shadowtrace://v1/join?gid=${group.id}&sec=${group.inviteSecret ?? ""}';

    return AlertDialog(
      backgroundColor: TacticalColors.surfaceBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TacticalColors.cyanActive, width: 1),
      ),
      title: const Row(
        children: [
          Icon(Icons.qr_code, color: TacticalColors.cyanActive),
          SizedBox(width: 8),
          Text(
            'GROUP CREATED',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Share this invite token or QR code with trusted members.',
            style: TextStyle(fontSize: 12, color: TacticalColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TacticalQrWidget(
            data: inviteUri,
            size: 160,
            showCopyButton: false,
            accentColor: TacticalColors.cyanActive,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TacticalColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: TacticalColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ID: ${group.id.take(16)}...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: TacticalColors.cyanActive,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: TacticalColors.textSecondary,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteUri));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invite token copied to clipboard!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TacticalButton(label: 'DONE', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
