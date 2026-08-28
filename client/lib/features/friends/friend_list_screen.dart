import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/coordinate_formatter.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tactical_card.dart';

class FriendListScreen extends ConsumerWidget {
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(groupFriendsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(title: const Text('GROUP OPERATORS')),
      body: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(
              child: Text(
                'NO PEERS IN THIS GROUP',
                style: TextStyle(
                  color: TacticalColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final friend = friends[index];
              return TacticalCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TacticalColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.person_pin,
                        color: TacticalColors.cyanActive,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.localNickname,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: TacticalColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ROLE: ${friend.role.toUpperCase()} • ${friend.lastSeen != null ? CoordinateFormatter.formatLastSeen(friend.lastSeen!) : "OFFLINE"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: TacticalColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: friend.status),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: TacticalColors.cyanActive),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: TacticalColors.crimsonCritical),
          ),
        ),
      ),
    );
  }
}
