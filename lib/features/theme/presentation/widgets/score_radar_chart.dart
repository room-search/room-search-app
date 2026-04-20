import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ScoreRadarChart extends StatefulWidget {
  const ScoreRadarChart({
    super.key,
    required this.scores,
    this.max = 5,
    this.size = 220,
  });

  final Map<String, double> scores;
  final double max;
  final double size;

  @override
  State<ScoreRadarChart> createState() => _ScoreRadarChartState();
}

class _ScoreRadarChartState extends State<ScoreRadarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (ctx, _) => CustomPaint(
          painter: _RadarPainter(
            scores: widget.scores,
            max: widget.max,
            progress: Curves.easeOutCubic.transform(_ctl.value),
            primary: scheme.primary,
            onSurface: scheme.onSurface,
            outline: scheme.outline,
            fillLow: AppColors.scoreLow.withValues(alpha: 0.5),
            fillMid: AppColors.scoreMid.withValues(alpha: 0.5),
            fillHigh: AppColors.scoreHigh.withValues(alpha: 0.5),
            labelStyle: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.scores,
    required this.max,
    required this.progress,
    required this.primary,
    required this.onSurface,
    required this.outline,
    required this.fillLow,
    required this.fillMid,
    required this.fillHigh,
    required this.labelStyle,
  });

  final Map<String, double> scores;
  final double max;
  final double progress;
  final Color primary;
  final Color onSurface;
  final Color outline;
  final Color fillLow;
  final Color fillMid;
  final Color fillHigh;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 28;
    final labels = scores.keys.toList();
    final values = scores.values.toList();
    final n = labels.length;
    if (n == 0) return;

    final gridPaint = Paint()
      ..color = outline.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int step = 1; step <= 5; step++) {
      final r = radius * (step / 5);
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -pi / 2 + i * (2 * pi / n);
        final p = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + i * (2 * pi / n);
      final end = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.drawLine(center, end, gridPaint);
    }

    // Data polygon
    final dataPath = Path();
    double avg = 0;
    for (int i = 0; i < n; i++) {
      final ratio = (values[i] / max).clamp(0.0, 1.0) * progress;
      avg += ratio;
      final angle = -pi / 2 + i * (2 * pi / n);
      final p = Offset(
        center.dx + radius * ratio * cos(angle),
        center.dy + radius * ratio * sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();
    avg /= n;
    final fill = avg < 0.4 ? fillLow : (avg < 0.7 ? fillMid : fillHigh);

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Vertex dots
    for (int i = 0; i < n; i++) {
      final ratio = (values[i] / max).clamp(0.0, 1.0) * progress;
      final angle = -pi / 2 + i * (2 * pi / n);
      final p = Offset(
        center.dx + radius * ratio * cos(angle),
        center.dy + radius * ratio * sin(angle),
      );
      canvas.drawCircle(p, 3, Paint()..color = primary);
    }

    // Labels
    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + i * (2 * pi / n);
      final lr = radius + 18;
      final pos = Offset(center.dx + lr * cos(angle), center.dy + lr * sin(angle));
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: labelStyle?.copyWith(color: onSurface.withValues(alpha: 0.75)) ??
              TextStyle(color: onSurface, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      final offset = Offset(
        pos.dx - painter.width / 2,
        pos.dy - painter.height / 2,
      );
      painter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.scores != scores;
}
