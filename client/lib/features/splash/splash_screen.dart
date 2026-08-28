import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../map/live_map_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LiveMapScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radar_rounded,
              size: 64,
              color: TacticalColors.cyanActive,
            ),
            SizedBox(height: 24),
            Text(
              'SHADOWTRACE',
              style: TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'SECURE REALTIME TELEMETRY',
              style: TextStyle(
                color: TacticalColors.textSecondary,
                fontSize: 11,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
