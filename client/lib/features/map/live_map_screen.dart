import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/coordinate_formatter.dart';
import '../../models/friend.dart';
import 'widgets/tactical_map_canvas.dart';
import 'widgets/peer_telemetry_sheet.dart';
import '../friends/friend_list_screen.dart';
import '../group/group_management_screen.dart';
import '../sharing/sharing_control_screen.dart';
import '../settings/settings_screen.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  void _openPeerTelemetry(Friend friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PeerTelemetrySheet(
        friend: friend,
        onEditNickname: () {
          Navigator.pop(context);
          _showEditNicknameDialog(friend);
        },
      ),
    );
  }

  void _showEditNicknameDialog(Friend friend) {
    final controller = TextEditingController(text: friend.localNickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surfaceBase,
        title: const Text(
          'EDIT LOCAL ALIAS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: TacticalColors.cyanActive),
          decoration: const InputDecoration(
            labelText: 'NICKNAME (STORED LOCALLY)',
            labelStyle: TextStyle(
              color: TacticalColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: TacticalColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(friendRepositoryProvider)
                  .updateNickname(friend.deviceId, controller.text.trim());
              ref.invalidate(groupFriendsProvider);
              Navigator.pop(ctx);
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: TacticalColors.cyanActive),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGroup = ref.watch(activeGroupProvider);
    final serviceStatus = ref.watch(serviceStatusProvider);
    final friendsAsync = ref.watch(groupFriendsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.radar, size: 20, color: TacticalColors.cyanActive),
            const SizedBox(width: 8),
            Text(
              activeGroup != null
                  ? 'GROUP: ${activeGroup.id.take(8).toUpperCase()}'
                  : 'TACTICAL RADAR',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.group_outlined,
              color: TacticalColors.textPrimary,
            ),
            tooltip: 'Friends List',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FriendListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.qr_code_2_outlined,
              color: TacticalColors.textPrimary,
            ),
            tooltip: 'Group Management',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupManagementScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.tune_outlined,
              color: TacticalColors.textPrimary,
            ),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tactical Map Canvas
          friendsAsync.when(
            data: (friends) => TacticalMapCanvas(
              friends: friends,
              onSelectFriend: _openPeerTelemetry,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: TacticalColors.cyanActive,
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: TacticalColors.crimsonCritical),
              ),
            ),
          ),

          // Broadcast Status Quick-Pill (Top Overlay)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SharingControlScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: TacticalColors.surfaceBase.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: serviceStatus.isBroadcasting
                        ? TacticalColors.cyanActive
                        : TacticalColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: serviceStatus.isBroadcasting
                            ? TacticalColors.cyanActive
                            : TacticalColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      serviceStatus.isBroadcasting
                          ? 'BROADCASTING: ACTIVE'
                          : 'BROADCASTING: STANDBY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: serviceStatus.isBroadcasting
                            ? TacticalColors.cyanActive
                            : TacticalColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'TAP TO CONFIGURE',
                      style: TextStyle(
                        fontSize: 9,
                        color: TacticalColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: TacticalColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
