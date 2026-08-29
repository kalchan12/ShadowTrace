import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/constants/tactical_colors.dart';

/// Tactical cyberpunk themed QR code presentation widget.
class TacticalQrWidget extends StatelessWidget {
  final String data;
  final double size;
  final String? label;
  final bool showCopyButton;
  final Color accentColor;

  const TacticalQrWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.label,
    this.showCopyButton = true,
    this.accentColor = TacticalColors.primaryContainer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: TacticalColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Tactical Bordered Frame
        Container(
          width: size + 24,
          height: size + 24,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF05070A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Tactical Corner Marks
              Positioned(
                top: 0,
                left: 0,
                child: _CornerBracket(color: accentColor, isTop: true, isLeft: true),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _CornerBracket(color: accentColor, isTop: true, isLeft: false),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: _CornerBracket(color: accentColor, isTop: false, isLeft: true),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _CornerBracket(color: accentColor, isTop: false, isLeft: false),
              ),

              // QR Code
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(6),
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: size - 8,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF000000),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showCopyButton) ...[
          const SizedBox(height: 14),
          Container(
            constraints: BoxConstraints(maxWidth: size + 24),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: TacticalColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: TacticalColors.borderHud),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: TacticalColors.primaryFixedDim,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 14,
                    color: TacticalColors.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payload copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Color color;
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 2) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 2) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 2) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 2) : BorderSide.none,
        ),
      ),
    );
  }
}
