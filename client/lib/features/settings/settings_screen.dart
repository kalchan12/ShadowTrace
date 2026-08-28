import 'package:flutter/material.dart';
import '../../core/constants/tactical_colors.dart';
import '../../widgets/tactical_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(title: const Text('SYSTEM DIAGNOSTICS & SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'DEVICE & CRYPTO IDENTITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TacticalColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          TacticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEVICE FINGERPRINT (SHA-256)',
                  style: TextStyle(
                    fontSize: 11,
                    color: TacticalColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: TacticalColors.cyanActive,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'KEYSTORE ALGORITHM',
                  style: TextStyle(
                    fontSize: 11,
                    color: TacticalColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'EC NIST P-256 (AndroidKeyStore TEE)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: TacticalColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'PRIVACY & SECURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TacticalColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          TacticalCard(
            child: Column(
              children: [
                _buildToggleRow(
                  'HISTORICAL TRACKING',
                  'DISABLED (EPHEMERAL)',
                  TacticalColors.cyanActive,
                ),
                const Divider(),
                _buildToggleRow(
                  'LOCAL ALIAS SYNC',
                  'DISABLED (ON-DEVICE ONLY)',
                  TacticalColors.cyanActive,
                ),
                const Divider(),
                _buildToggleRow(
                  'ROW-LEVEL SECURITY',
                  'ACTIVE',
                  TacticalColors.cyanActive,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ABOUT SHADOWTRACE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: TacticalColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const TacticalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ShadowTrace Client v1.0.0 (Phase 0/1 Foundation)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TacticalColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Decentralized, accountless realtime location network.',
                  style: TextStyle(
                    fontSize: 12,
                    color: TacticalColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: TacticalColors.textPrimary,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
