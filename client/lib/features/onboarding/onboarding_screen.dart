import 'package:flutter/material.dart';
import '../../core/constants/tactical_colors.dart';
import '../../widgets/tactical_button.dart';
import '../../widgets/tactical_card.dart';
import '../map/live_map_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _callsignController = TextEditingController(
    text: 'OPERATOR-1',
  );

  @override
  void dispose() {
    _callsignController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LiveMapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(title: const Text('DEVICE INITIALIZATION')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SET LOCAL CALLSIGN',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TacticalColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your callsign is stored locally on this device. ShadowTrace uses hardware cryptographic keys rather than accounts.',
              style: TextStyle(
                color: TacticalColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            TacticalCard(
              child: TextField(
                controller: _callsignController,
                style: const TextStyle(
                  color: TacticalColors.cyanActive,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: 'LOCAL ALIAS / CALLSIGN',
                  labelStyle: TextStyle(
                    color: TacticalColors.textSecondary,
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: TacticalColors.cyanActive,
                  ),
                ),
              ),
            ),
            const Spacer(),
            TacticalButton(
              label: 'INITIALIZE SYSTEM',
              icon: Icons.check_circle_outline,
              isFullWidth: true,
              onPressed: _continue,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
