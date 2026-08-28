import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/coordinate_formatter.dart';
import '../../widgets/tactical_button.dart';
import '../../widgets/tactical_card.dart';
import 'create_group_dialog.dart';
import 'join_group_dialog.dart';

class GroupManagementScreen extends ConsumerWidget {
  const GroupManagementScreen({super.key});

  void _handleCreateGroup(BuildContext context, WidgetRef ref) async {
    final newGroup = await ref.read(groupRepositoryProvider).createGroup();
    ref.read(activeGroupProvider.notifier).state = newGroup;
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => CreateGroupDialog(group: newGroup),
      );
    }
  }

  void _handleJoinGroup(BuildContext context) {
    showDialog(context: context, builder: (_) => const JoinGroupDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGroup = ref.watch(activeGroupProvider);

    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(title: const Text('GROUP MANAGEMENT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACTIVE SHARING GROUP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: TacticalColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            if (activeGroup != null)
              TacticalCard(
                borderColor: TacticalColors.cyanActive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GROUP ${activeGroup.id.take(8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: TacticalColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TacticalColors.cyanActive.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: TacticalColors.cyanActive,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UUID: ${activeGroup.id}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: TacticalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TacticalButton(
                      label: 'VIEW INVITE QR',
                      icon: Icons.qr_code,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CreateGroupDialog(group: activeGroup),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              const TacticalCard(
                child: Text(
                  'No group active. Create or join one below.',
                  style: TextStyle(color: TacticalColors.textSecondary),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'ACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: TacticalColors.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TacticalButton(
                    label: 'CREATE GROUP',
                    icon: Icons.add_circle_outline,
                    variant: TacticalButtonVariant.primary,
                    onPressed: () => _handleCreateGroup(context, ref),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TacticalButton(
                    label: 'JOIN GROUP',
                    icon: Icons.qr_code_scanner,
                    variant: TacticalButtonVariant.secondary,
                    onPressed: () => _handleJoinGroup(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
