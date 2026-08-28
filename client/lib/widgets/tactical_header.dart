import 'package:flutter/material.dart';
import '../core/constants/tactical_colors.dart';

class TacticalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const TacticalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: TacticalColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: TacticalColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        ?trailing,
      ],
    );
  }
}
