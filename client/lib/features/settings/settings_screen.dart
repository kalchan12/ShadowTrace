import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/tactical_colors.dart';
import '../../core/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _callsignController = TextEditingController(
    text: 'Alex',
  );

  @override
  void dispose() {
    _callsignController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceStatus = ref.watch(serviceStatusProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.language,
            color: TacticalColors.primaryFixedDim,
          ),
          onPressed: () {},
        ),
        title: const Text('SETTINGS'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sensors,
              color: TacticalColors.primaryFixedDim,
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
            // Section 1: IDENTITY
            _buildSectionHeader('IDENTITY'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xD90D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.borderHud, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TacticalColors.surfaceContainerHigh,
                      border: Border.all(
                        color: TacticalColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      size: 28,
                      color: TacticalColors.primaryFixedDim,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CALLSIGN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: TacticalColors.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF05070A),
                            border: Border(
                              bottom: BorderSide(
                                color: TacticalColors.outlineVariant,
                                width: 2,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: TextField(
                            controller: _callsignController,
                            style: const TextStyle(
                              fontSize: 15,
                              color: TacticalColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: LOCATION SHARING
            _buildSectionHeader(
              'LOCATION SHARING',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: serviceStatus.isBroadcasting
                      ? TacticalColors.primaryContainer.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: serviceStatus.isBroadcasting
                        ? TacticalColors.primaryContainer
                        : TacticalColors.outlineVariant,
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
                        color: serviceStatus.isBroadcasting
                            ? TacticalColors.primaryContainer
                            : TacticalColors.outline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      serviceStatus.isBroadcasting ? 'ACTIVE' : 'PAUSED',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: serviceStatus.isBroadcasting
                            ? TacticalColors.primaryContainer
                            : TacticalColors.outline,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xD90D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: serviceStatus.isBroadcasting
                      ? const Color(0x4D2E5BFF)
                      : TacticalColors.borderHud,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your location is visible to your ShadowTrace group.',
                    style: TextStyle(
                      fontSize: 13,
                      color: TacticalColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mini Map Graphic Preview
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TacticalColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TacticalColors.outlineVariant),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _MiniGridPainter(),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: TacticalColors.primaryContainer.withValues(
                              alpha: 0.2,
                            ),
                            border: Border.all(
                              color: TacticalColors.primaryContainer,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: TacticalColors.primaryContainer,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pause / Resume Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(serviceStatusProvider.notifier)
                            .toggleBroadcast(
                              'a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d',
                            );
                      },
                      icon: Icon(
                        serviceStatus.isBroadcasting
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: 18,
                        color: TacticalColors.onSurface,
                      ),
                      label: Text(
                        serviceStatus.isBroadcasting
                            ? 'PAUSE SHARING'
                            : 'RESUME SHARING',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.onSurface,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: TacticalColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: PREFERENCES
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xD90D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TacticalColors.borderHud, width: 1),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildPreferenceRow('Update Frequency', 'Balanced'),
                  const Divider(color: TacticalColors.borderHud),
                  _buildPreferenceRow('Accuracy Mode', 'High'),
                  const Divider(color: TacticalColors.borderHud),
                  _buildPreferenceRow('Units', 'Metric'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 4: SERVICE STATUS
            _buildSectionHeader('SERVICE STATUS'),
            const SizedBox(height: 10),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xD90D1117),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                border: Border(
                  top: BorderSide(
                    color: TacticalColors.primaryContainer,
                    width: 2,
                  ),
                  left: BorderSide(color: TacticalColors.borderHud, width: 1),
                  right: BorderSide(color: TacticalColors.borderHud, width: 1),
                  bottom: BorderSide(color: TacticalColors.borderHud, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_tethering,
                    color: TacticalColors.primaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCATION SERVICE ● CONNECTED',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.primaryContainer,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Last heartbeat 3s ago',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: TacticalColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TacticalColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: TacticalColors.onSurface,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: TacticalColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0x0FFFFFFF)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
