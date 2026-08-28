import 'package:flutter/material.dart';
import '../core/constants/tactical_colors.dart';

enum TacticalButtonVariant { primary, secondary, critical }

class TacticalButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final TacticalButtonVariant variant;
  final bool isFullWidth;

  const TacticalButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = TacticalButtonVariant.primary,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    final Color backgroundColor;

    switch (variant) {
      case TacticalButtonVariant.primary:
        mainColor = TacticalColors.cyanActive;
        backgroundColor = TacticalColors.cyanActive.withValues(alpha: 0.15);
        break;
      case TacticalButtonVariant.secondary:
        mainColor = TacticalColors.violetAux;
        backgroundColor = TacticalColors.violetAux.withValues(alpha: 0.15);
        break;
      case TacticalButtonVariant.critical:
        mainColor = TacticalColors.crimsonCritical;
        backgroundColor = TacticalColors.crimsonCritical.withValues(
          alpha: 0.15,
        );
        break;
    }

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: mainColor),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: mainColor.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}
