import 'package:flutter/material.dart';
import '../core/constants/tactical_colors.dart';

class TacticalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const TacticalCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TacticalColors.surfaceBase,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: TacticalColors.cyanGlow,
        highlightColor: Colors.transparent,
        child: Container(
          padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor ?? TacticalColors.surfaceBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
