import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import 'create_group_screen.dart';

class GroupManagementScreen extends ConsumerWidget {
  const GroupManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String groupCode = '7F3K-92XA';

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.language,
            color: TacticalColors.onSurfaceVariant,
          ),
          onPressed: () {},
        ),
        title: const Text('SHADOWTRACE'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sensors,
              color: TacticalColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            const Text(
              'GROUP: NIGHT OPS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: TacticalColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: TacticalColors.primaryContainer,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '4 MEMBERS • LIVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TacticalColors.primaryContainer,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Group Code Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xD90D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.borderHud, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GROUP CODE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Icon(
                        Icons.qr_code_2,
                        size: 18,
                        color: TacticalColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: TacticalColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          groupCode,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TacticalColors.primaryFixedDim,
                            letterSpacing: 3.0,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.content_copy,
                            size: 18,
                            color: TacticalColors.onSurfaceVariant,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              const ClipboardData(text: groupCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Group code copied to clipboard!',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this code to allow trusted operatives to join Night Ops.',
                    style: TextStyle(
                      fontSize: 12,
                      color: TacticalColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Invite & Leave Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateGroupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add,
                      size: 16,
                      color: TacticalColors.primaryFixedDim,
                    ),
                    label: const Text(
                      'INVITE FRIEND',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TacticalColors.primaryFixedDim,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: TacticalColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Left group Night Ops')),
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      size: 16,
                      color: TacticalColors.error,
                    ),
                    label: const Text(
                      'LEAVE GROUP',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: TacticalColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: TacticalColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Members List Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xD90D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.borderHud, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MEMBERS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '4/12 SLOTS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: TacticalColors.borderHud),
                  const SizedBox(height: 8),

                  // Member 1: You (Squad Leader)
                  _buildMemberRow(
                    name: 'You',
                    role: 'SQUAD LEADER',
                    avatarLetter: 'Y',
                    distance: '0.0km',
                    isLeader: true,
                    isOnline: true,
                  ),
                  const SizedBox(height: 8),

                  // Member 2: Alex
                  _buildMemberRow(
                    name: 'Alex',
                    role: 'OPERATIVE',
                    avatarLetter: 'A',
                    distance: '1.2km',
                    isLeader: false,
                    isOnline: true,
                  ),
                  const SizedBox(height: 8),

                  // Member 3: Mike
                  _buildMemberRow(
                    name: 'Mike',
                    role: 'OPERATIVE',
                    avatarLetter: 'M',
                    distance: '3.4km',
                    isLeader: false,
                    isOnline: true,
                  ),
                  const SizedBox(height: 8),

                  // Member 4: Sarah (Offline)
                  _buildMemberRow(
                    name: 'Sarah',
                    role: 'OFFLINE',
                    avatarLetter: 'S',
                    distance: '--',
                    isLeader: false,
                    isOnline: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberRow({
    required String name,
    required String role,
    required String avatarLetter,
    required String distance,
    required bool isLeader,
    required bool isOnline,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isLeader
            ? TacticalColors.primaryContainer.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isLeader
            ? const Border(
                left: BorderSide(
                  color: TacticalColors.primaryContainer,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline
                      ? TacticalColors.surfaceContainerHigh
                      : TacticalColors.surfaceContainerLowest,
                  border: Border.all(
                    color: isOnline
                        ? TacticalColors.borderHud
                        : const Color(0x0FFFFFFF),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isLeader
                        ? TacticalColors.primaryContainer
                        : (isOnline
                              ? TacticalColors.primaryFixedDim
                              : TacticalColors.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? TacticalColors.onSurface
                          : TacticalColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isLeader
                          ? TacticalColors.primaryContainer
                          : (isOnline
                                ? TacticalColors.onSurfaceVariant
                                : TacticalColors.error),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                isOnline ? Icons.location_on : Icons.location_off,
                size: 16,
                color: isOnline
                    ? TacticalColors.primaryContainer.withValues(alpha: 0.7)
                    : TacticalColors.outlineVariant,
              ),
              const SizedBox(width: 4),
              Text(
                distance,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: TacticalColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
