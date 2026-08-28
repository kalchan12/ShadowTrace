import 'package:flutter/material.dart';
import '../core/constants/tactical_colors.dart';
import '../models/friend.dart';

class StatusBadge extends StatelessWidget {
  final PeerStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final String label;

    switch (status) {
      case PeerStatus.online:
        badgeColor = TacticalColors.cyanActive;
        label = 'ONLINE';
        break;
      case PeerStatus.stale:
        badgeColor = TacticalColors.amberWarning;
        label = 'STALE';
        break;
      case PeerStatus.offline:
        badgeColor = TacticalColors.crimsonCritical;
        label = 'OFFLINE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        border: Border.all(color: badgeColor.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
