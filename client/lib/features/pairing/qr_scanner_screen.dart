import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/tactical_colors.dart';
import '../../models/pairing_payload.dart';

/// Tactical HUD Camera QR Scanner Screen.
class QrScannerScreen extends StatefulWidget {
  final String title;

  const QrScannerScreen({
    super.key,
    this.title = 'PAIRING SCANNER',
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  late final Animation<double> _scanLineAnimation;

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        try {
          setState(() => _isProcessing = true);
          final payload = PairingPayload.parse(rawValue);
          Navigator.of(context).pop(payload);
          return;
        } catch (e) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: TacticalColors.error,
              content: Text(
                'Invalid QR: ${e.toString().replaceAll('InvalidPairingPayloadException: ', '')}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TacticalColors.surfaceBase,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: TacticalColors.primaryContainer),
        ),
        title: const Text(
          'MANUAL PAYLOAD INPUT',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: TacticalColors.primaryFixedDim,
          ),
        ),
        content: TextField(
          controller: textController,
          maxLines: 3,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: TacticalColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'shadowtrace://v1/join?gid=... or shadowtrace://v1/peer?did=...',
            hintStyle: TextStyle(fontSize: 11, color: TacticalColors.textTertiary),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: TacticalColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TacticalColors.primaryContainer,
            ),
            onPressed: () {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              try {
                final payload = PairingPayload.parse(text);
                Navigator.pop(ctx);
                Navigator.of(context).pop(payload);
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    backgroundColor: TacticalColors.error,
                    content: Text('Invalid payload: $e'),
                  ),
                );
              }
            },
            child: const Text('DECODE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const scanBoxSize = 260.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Cyber HUD Reticle Overlay
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TacticalColors.primaryFixedDim,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isTorchOn ? Icons.flash_on : Icons.flash_off,
                              color: _isTorchOn
                                  ? TacticalColors.primaryContainer
                                  : Colors.white70,
                            ),
                            onPressed: () async {
                              await _scannerController.toggleTorch();
                              setState(() {
                                _isTorchOn = !_isTorchOn;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.flip_camera_android, color: Colors.white70),
                            onPressed: () => _scannerController.switchCamera(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Scanner Target Area
                Center(
                  child: SizedBox(
                    width: scanBoxSize,
                    height: scanBoxSize,
                    child: Stack(
                      children: [
                        // Reticle Corners
                        const Positioned(
                          top: 0,
                          left: 0,
                          child: _ScannerCorner(isTop: true, isLeft: true),
                        ),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: _ScannerCorner(isTop: true, isLeft: false),
                        ),
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          child: _ScannerCorner(isTop: false, isLeft: true),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: _ScannerCorner(isTop: false, isLeft: false),
                        ),

                        // Animated Laser Scan Line
                        AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanLineAnimation.value * (scanBoxSize - 4),
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: TacticalColors.primaryContainer,
                                  boxShadow: [
                                    BoxShadow(
                                      color: TacticalColors.primaryContainer.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Status & Manual Entry
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.black.withValues(alpha: 0.75),
                  child: Column(
                    children: [
                      const Text(
                        'ALIGN RETICLE OVER PEER QR CODE',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: TacticalColors.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _showManualInputDialog,
                        icon: const Icon(
                          Icons.keyboard,
                          size: 16,
                          color: TacticalColors.primaryFixedDim,
                        ),
                        label: const Text(
                          'ENTER PAYLOAD STRING',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TacticalColors.primaryFixedDim,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: TacticalColors.borderHud),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _ScannerCorner({
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    const color = TacticalColors.primaryContainer;
    const cornerSize = 24.0;
    const thickness = 3.0;

    return Container(
      width: cornerSize,
      height: cornerSize,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
      ),
    );
  }
}
