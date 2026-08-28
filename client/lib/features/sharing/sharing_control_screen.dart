import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/coordinate_formatter.dart';
import '../../widgets/tactical_button.dart';
import '../../widgets/tactical_card.dart';

class SharingControlScreen extends ConsumerWidget {
  const SharingControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceStatus = ref.watch(serviceStatusProvider);
    final activeGroup = ref.watch(activeGroupProvider);

    return Scaffold(
      backgroundColor: TacticalColors.backgroundBase,
      appBar: AppBar(title: const Text('BROADCAST CONTROLS')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TacticalCard(
              borderColor: serviceStatus.isBroadcasting
                  ? TacticalColors.cyanActive
                  : TacticalColors.surfaceBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceStatus.isBroadcasting
                            ? 'SERVICE: ACTIVE'
                            : 'SERVICE: STANDBY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: serviceStatus.isBroadcasting
                              ? TacticalColors.cyanActive
                              : TacticalColors.textSecondary,
                        ),
                      ),
                      Switch(
                        value: serviceStatus.isBroadcasting,
                        activeThumbColor: TacticalColors.cyanActive,
                        onChanged: activeGroup != null
                            ? (val) {
                                ref
                                    .read(serviceStatusProvider.notifier)
                                    .toggleBroadcast(activeGroup.id);
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceStatus.isBroadcasting
                        ? 'Broadcasting high-accuracy GPS coordinates via Android Foreground Service.'
                        : 'Location collection is halted. No coordinates are being transmitted.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TacticalColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'TELEMETRY METRICS',
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
                  _buildMetricRow('SERVICE PROCESS', 'com.shadowtrace.service'),
                  const Divider(),
                  _buildMetricRow(
                    'ACTIVE GROUP',
                    activeGroup?.id.take(8) ?? 'NONE',
                  ),
                  const Divider(),
                  _buildMetricRow('SAMPLING RATE', 'Adaptive (5s - 60s)'),
                  const Divider(),
                  _buildMetricRow(
                    'PERMISSION STATUS',
                    serviceStatus.locationPermissionStatus.toUpperCase(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (serviceStatus.isBroadcasting)
              TacticalButton(
                label: 'EMERGENCY STOP BROADCAST',
                icon: Icons.stop_circle_outlined,
                variant: TacticalButtonVariant.critical,
                isFullWidth: true,
                onPressed: () {
                  if (activeGroup != null) {
                    ref
                        .read(serviceStatusProvider.notifier)
                        .toggleBroadcast(activeGroup.id);
                  }
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: TacticalColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: TacticalColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
