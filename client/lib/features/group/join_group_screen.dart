import 'package:flutter/material.dart';
import '../../core/constants/tactical_colors.dart';
import '../shell/main_shell_screen.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _codeController = TextEditingController(
    text: '7F3K-92XA',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: 'Alex',
  );

  @override
  void dispose() {
    _codeController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalColors.background,
      body: Stack(
        children: [
          // Cyber Grid Background
          CustomPaint(size: Size.infinite, painter: _CyberGridPainter()),

          // Top Header
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'SHADOWTRACE // SYSTEM INIT',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TacticalColors.primaryFixedDim,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Main Panel
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: const Color(0xD90D1117),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TacticalColors.borderHud,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar
                      Container(
                        height: 3,
                        width: double.infinity,
                        color: TacticalColors.surfaceContainerHigh,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 300,
                          color: TacticalColors.primaryContainer,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section 1: Join Group
                            const Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  color: TacticalColors.primaryContainer,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'JOIN GROUP',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: TacticalColors.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: TacticalColors.borderHud),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'QR Scanner ready for Phase 5',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 16,
                                      color: TacticalColors.primaryFixedDim,
                                    ),
                                    label: const Text(
                                      'SCAN QR',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: TacticalColors.primaryFixedDim,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0x66124AF0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF05070A),
                                      border: Border(
                                        bottom: BorderSide(
                                          color:
                                              TacticalColors.primaryContainer,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: TextField(
                                      controller: _codeController,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        color: TacticalColors.primaryContainer,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'CODE',
                                        hintStyle: TextStyle(
                                          color: TacticalColors.outlineVariant,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.login,
                                size: 18,
                                color: TacticalColors.onSurface,
                              ),
                              label: const Text(
                                'JOIN GROUP',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: TacticalColors.onSurface,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side: const BorderSide(
                                  color: Color(0x4D00F0FF),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Identity Setup
                            const Row(
                              children: [
                                Icon(
                                  Icons.badge,
                                  color: TacticalColors.primaryContainer,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'IDENTITY SETUP',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: TacticalColors.onSurfaceVariant,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: TacticalColors.borderHud),
                            const SizedBox(height: 12),

                            const Text(
                              'How should your friends see you?',
                              style: TextStyle(
                                fontSize: 13,
                                color: TacticalColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF05070A),
                                border: Border(
                                  bottom: BorderSide(
                                    color: TacticalColors.primaryContainer,
                                    width: 2,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: TacticalColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _usernameController,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: TacticalColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter codename',
                                        hintStyle: TextStyle(
                                          color: TacticalColors.outlineVariant,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainShellScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                label: const Text(
                                  'CONTINUE',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      TacticalColors.primaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
