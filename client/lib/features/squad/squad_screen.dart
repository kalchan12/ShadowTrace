import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';

class SquadScreen extends ConsumerWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // Section Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'SQUAD',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: TacticalColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: TacticalColors.primaryFixedDim,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SYSTEM ACTIVE',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: TacticalColors.primaryFixedDim,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 1: You
            _buildYouCard(),
            const SizedBox(height: 12),

            // Card 2: Alex
            _buildMemberCard(
              context: context,
              name: 'Alex',
              isOnline: true,
              battery: '84%',
              distance: '326m',
              isCriticalBattery: false,
              avatarLetter: 'A',
            ),
            const SizedBox(height: 12),

            // Card 3: Mike
            _buildMemberCard(
              context: context,
              name: 'Mike',
              isOnline: true,
              battery: '42%',
              distance: '1.2km',
              isCriticalBattery: true,
              avatarLetter: 'M',
            ),
            const SizedBox(height: 12),

            // Card 4: Sarah (Offline)
            _buildOfflineMemberCard(
              name: 'Sarah',
              lastSeen: '12m ago',
              avatarLetter: 'S',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildYouCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xD90D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.borderHud, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Cyan Indicator Line
          Container(
            height: 3,
            width: 80,
            decoration: const BoxDecoration(
              color: TacticalColors.primaryFixedDim,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: TacticalColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'SHARING LOCATION',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: TacticalColors.outline,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TacticalColors.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: TacticalColors.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TacticalColors.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: TacticalColors.primaryContainer
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: TacticalColors.primaryContainer,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCURACY: 7m',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: TacticalColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'LAT/LNG: 37.7749, -122.4194',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: TacticalColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.my_location,
                      color: TacticalColors.primaryFixedDim,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({
    required BuildContext context,
    required String name,
    required bool isOnline,
    required String battery,
    required String distance,
    required bool isCriticalBattery,
    required String avatarLetter,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xD90D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.borderHud, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TacticalColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: TacticalColors.borderHud,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TacticalColors.primaryFixedDim,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TacticalColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TacticalColors.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: TacticalColors.primaryContainer
                                      .withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ONLINE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: TacticalColors.primaryContainer,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'BAT: $battery',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isCriticalBattery
                      ? TacticalColors.errorCritical
                      : TacticalColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TacticalColors.borderHud),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.radar,
                    size: 16,
                    color: TacticalColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'DIST: $distance',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: TacticalColors.onSurface,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ping signal sent to $name')),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TacticalColors.tacticalBlue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PING',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMemberCard({
    required String name,
    required String lastSeen,
    required String avatarLetter,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x990D1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TacticalColors.borderHud, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: TacticalColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: TacticalColors.borderHud,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TacticalColors.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: TacticalColors.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: TacticalColors.outline,
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'OFFLINE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: TacticalColors.outline,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'LAST: $lastSeen',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: TacticalColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TacticalColors.borderHud),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.history, size: 16, color: TacticalColors.outline),
              SizedBox(width: 6),
              Text(
                'LAST KNOWN LOC',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: TacticalColors.outline,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
