import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 5,
    this.animated = true,
  });

  final String label;
  final double value;
  final double max;
  final bool animated;

  Color _colorFor(BuildContext context, double ratio) {
    if (ratio < 0.4) return AppColors.scoreLow;
    if (ratio < 0.7) return AppColors.scoreMid;
    return AppColors.scoreHigh;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    final color = _colorFor(context, ratio);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: scheme.onSurface.withValues(alpha: 0.08),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
                duration: animated
                    ? const Duration(milliseconds: 900)
                    : Duration.zero,
                curve: Curves.easeOutCubic,
                builder: (ctx, v, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: v,
                  child: Container(height: 6, color: color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
