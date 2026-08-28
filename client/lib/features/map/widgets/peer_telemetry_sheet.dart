import 'package:flutter/material.dart';
import '../../../core/constants/tactical_colors.dart';
import '../../../core/utils/coordinate_formatter.dart';
import '../../../models/friend.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/tactical_button.dart';
import '../../../widgets/tactical_card.dart';

class PeerTelemetrySheet extends StatelessWidget {
  final Friend friend;
  final VoidCallback onEditNickname;

  const PeerTelemetrySheet({
    super.key,
    required this.friend,
    required this.onEditNickname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: TacticalColors.surfaceBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: TacticalColors.cyanActive, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.localNickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: TacticalColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DEVICE: ${friend.deviceId.take(12)}...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: TacticalColors.textTertiary,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: friend.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TacticalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISTANCE',
                        style: TextStyle(
                          fontSize: 10,
                          color: TacticalColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.distanceMeters != null
                            ? CoordinateFormatter.formatDistance(
                                friend.distanceMeters!,
                              )
                            : '--',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.cyanActive,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TacticalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SPEED',
                        style: TextStyle(
                          fontSize: 10,
                          color: TacticalColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CoordinateFormatter.formatSpeed(friend.speedMps),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TacticalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LAST UPDATE',
                        style: TextStyle(
                          fontSize: 10,
                          color: TacticalColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend.lastSeen != null
                            ? CoordinateFormatter.formatLastSeen(
                                friend.lastSeen!,
                              )
                            : 'OFFLINE',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.amberWarning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TacticalButton(
                  label: 'EDIT ALIAS',
                  icon: Icons.edit_outlined,
                  variant: TacticalButtonVariant.secondary,
                  onPressed: onEditNickname,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TacticalButton(
                  label: 'CENTER MAP',
                  icon: Icons.my_location,
                  variant: TacticalButtonVariant.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
