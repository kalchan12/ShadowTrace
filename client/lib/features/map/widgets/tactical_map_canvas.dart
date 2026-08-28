import 'package:flutter/material.dart';
import '../../../core/constants/tactical_colors.dart';
import '../../../models/friend.dart';

class TacticalMapCanvas extends StatelessWidget {
  final List<Friend> friends;
  final Function(Friend) onSelectFriend;

  const TacticalMapCanvas({
    super.key,
    required this.friends,
    required this.onSelectFriend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TacticalColors.backgroundBase,
      child: Stack(
        children: [
          // Tactical Grid Overlay
          CustomPaint(size: Size.infinite, painter: _TacticalGridPainter()),

          // Center Radar Range Circles
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TacticalColors.cyanGlow, width: 1),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TacticalColors.cyanGlow, width: 1),
              ),
            ),
          ),

          // User Self Location Marker (Center)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: TacticalColors.cyanActive,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TacticalColors.cyanActive.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.navigation,
                      size: 10,
                      color: TacticalColors.backgroundBase,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: TacticalColors.surfaceBase,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: TacticalColors.cyanActive,
                      width: 0.8,
                    ),
                  ),
                  child: const Text(
                    'YOU (SELF)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: TacticalColors.cyanActive,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Peer Friend Markers positioned across the grid
          if (friends.isNotEmpty) ...[
            _buildPeerMarker(
              friend: friends[0],
              alignment: const Alignment(-0.45, -0.35),
            ),
            if (friends.length > 1)
              _buildPeerMarker(
                friend: friends[1],
                alignment: const Alignment(0.65, 0.45),
              ),
            if (friends.length > 2)
              _buildPeerMarker(
                friend: friends[2],
                alignment: const Alignment(-0.6, 0.7),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeerMarker({
    required Friend friend,
    required Alignment alignment,
  }) {
    final Color markerColor = friend.status == PeerStatus.online
        ? TacticalColors.cyanActive
        : (friend.status == PeerStatus.stale
              ? TacticalColors.amberWarning
              : TacticalColors.crimsonCritical);

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => onSelectFriend(friend),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TacticalColors.surfaceBase,
                shape: BoxShape.circle,
                border: Border.all(color: markerColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.person, size: 14, color: markerColor),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: TacticalColors.surfaceBase.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: TacticalColors.surfaceBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                friend.localNickname,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: markerColor,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TacticalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TacticalColors.surfaceBorder.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
