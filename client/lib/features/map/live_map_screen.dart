import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../models/friend.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen>
    with SingleTickerProviderStateMixin {
  Friend? _selectedFriend;
  late AnimationController _accuracyPulseController;

  @override
  void initState() {
    super.initState();
    _accuracyPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _accuracyPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(groupFriendsProvider);

    return Scaffold(
      backgroundColor: TacticalColors.surfaceContainerLowest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.language,
            color: TacticalColors.primaryFixedDim,
          ),
          onPressed: () {},
        ),
        title: const Text('SHADOWTRACE'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TacticalColors.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: TacticalColors.outlineVariant.withValues(alpha: 0.3),
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
                      color: TacticalColors.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: TacticalColors.primaryContainer.withValues(
                            alpha: 0.6,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ONLINE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: TacticalColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tactical Map Canvas Background
          CustomPaint(size: Size.infinite, painter: _TacticalMapPainter()),

          // Floating Status Overlay (Top Left)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xD9111318), // surface/85
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x4D3B494B), width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHADOWTRACE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TacticalColors.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NODES',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: TacticalColors.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '4',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TacticalColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'STATUS',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: TacticalColors.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: TacticalColors.primaryFixedDim,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '3 LIVE',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TacticalColors.primaryFixedDim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // User Self Location Marker (Center)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _accuracyPulseController,
                  builder: (context, child) {
                    return Container(
                      width: 24 + (_accuracyPulseController.value * 28),
                      height: 24 + (_accuracyPulseController.value * 28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TacticalColors.primaryContainer.withValues(
                          alpha: (1.0 - _accuracyPulseController.value) * 0.2,
                        ),
                        border: Border.all(
                          color: TacticalColors.primaryContainer.withValues(
                            alpha: (1.0 - _accuracyPulseController.value) * 0.4,
                          ),
                          width: 1,
                        ),
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: TacticalColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TacticalColors.primaryContainer,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: TacticalColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE6111318),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0x803B494B),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurface,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Peer Markers
          friendsAsync.when(
            data: (friends) {
              if (friends.isEmpty) return const SizedBox.shrink();
              return Stack(
                children: [
                  // Marker 1: Alex (Top Right)
                  if (friends.isNotEmpty)
                    _buildMarker(
                      friend: friends[0],
                      alignment: const Alignment(0.35, -0.4),
                      distanceLabel: '320m',
                    ),
                  // Marker 2: Mike (Bottom Left)
                  if (friends.length > 1)
                    _buildMarker(
                      friend: friends[1],
                      alignment: const Alignment(-0.5, 0.45),
                      distanceLabel: '1.2km',
                    ),
                  // Marker 3: Sarah (Top Left Offline)
                  if (friends.length > 2)
                    _buildMarker(
                      friend: friends[2],
                      alignment: const Alignment(-0.6, -0.65),
                      distanceLabel: '12m ago',
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // Slide-up Bottom Sheet when a friend is selected
          if (_selectedFriend != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildDetailBottomSheet(_selectedFriend!),
            ),
        ],
      ),
    );
  }

  Widget _buildMarker({
    required Friend friend,
    required Alignment alignment,
    required String distanceLabel,
  }) {
    final isOnline = friend.status == PeerStatus.online;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFriend = friend;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? TacticalColors.primaryContainer
                    : Colors.transparent,
                border: Border.all(
                  color: isOnline
                      ? TacticalColors.primaryContainer
                      : TacticalColors.outlineVariant,
                  width: 2,
                ),
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: TacticalColors.primaryContainer.withValues(
                            alpha: 0.6,
                          ),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xE6111318),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isOnline
                      ? TacticalColors.primaryContainer.withValues(alpha: 0.3)
                      : const Color(0x4D3B494B),
                  width: 1,
                ),
              ),
              child: Text(
                friend.localNickname.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isOnline
                      ? TacticalColors.onSurface
                      : TacticalColors.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              distanceLabel,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: TacticalColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBottomSheet(Friend friend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xF2111318),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: Color(0x4D00F0FF), width: 1.5)),
        boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TacticalColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    friend.localNickname.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: TacticalColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: TacticalColors.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: TacticalColors.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: TacticalColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: TacticalColors.primaryFixedDim,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: TacticalColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _selectedFriend = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Data Grid
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TacticalColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x333B494B), width: 1),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COORDINATES',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: TacticalColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '37.7758° N, 122.4182° W',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: TacticalColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _buildDataCell('DISTANCE', '326m')),
              const SizedBox(width: 8),
              Expanded(child: _buildDataCell('SPEED', '2.4 km/h')),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _buildDataCell('ACCURACY', '± 7m')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDataCell(
                  'UPDATED',
                  '4s ago',
                  color: TacticalColors.primaryFixedDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Material(
                  color: TacticalColors.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Comm link connected to ${friend.localNickname}',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: const Text(
                        'COMM LINK',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ping signal sent to ${friend.localNickname}',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: TacticalColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'PING',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: TacticalColors.onSurface,
                        ),
                      ),
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

  Widget _buildDataCell(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TacticalColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x333B494B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: TacticalColors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: color ?? TacticalColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticalMapPainter extends CustomPainter {
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

    // Faint tactical range circles
    final circlePaint = Paint()
      ..color = const Color(0x1A00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      160,
      circlePaint,
    );
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 80, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
