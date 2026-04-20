import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/update/update_controller.dart';

class UpdateOverlay extends ConsumerWidget {
  const UpdateOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    final media = MediaQuery.of(context);
    final topInset = media.padding.top + 8;

    final showBanner = state.phase == UpdatePhase.available;
    final showProgress =
        state.phase == UpdatePhase.downloading || state.phase == UpdatePhase.installing;

    return Stack(
      children: [
        child,
        if (showBanner)
          Positioned(
            top: topInset,
            left: 12,
            right: 12,
            child: _CloudBanner(
              version: state.info?.latestVersion ?? '',
              notes: state.info?.releaseNotes ?? '',
              onUpdate: () => ref.read(updateControllerProvider.notifier).downloadAndInstall(),
              onDismiss: () => ref.read(updateControllerProvider.notifier).dismiss(),
            ),
          ),
        if (showProgress)
          Positioned(
            top: topInset,
            left: 12,
            right: 12,
            child: _DownloadCloud(
              progress: state.progress,
              phase: state.phase,
              onCancel: () => ref.read(updateControllerProvider.notifier).cancelDownload(),
            ),
          ),
      ],
    );
  }
}

class _CloudBanner extends StatelessWidget {
  const _CloudBanner({
    required this.version,
    required this.notes,
    required this.onUpdate,
    required this.onDismiss,
  });

  final String version;
  final String notes;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CloudContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '새 업데이트 $version',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onUpdate,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
              ),
              child: const Text('업데이트', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: '닫기',
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(begin: -0.5, end: 0, duration: 350.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 250.ms);
  }
}

class _DownloadCloud extends StatelessWidget {
  const _DownloadCloud({required this.progress, required this.phase, required this.onCancel});

  final double progress;
  final UpdatePhase phase;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    final label = phase == UpdatePhase.installing ? '설치 준비 중…' : '다운로드 중 $percent%';
    return _CloudContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (phase == UpdatePhase.downloading)
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: '취소',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: phase == UpdatePhase.installing
                    ? null
                    : (progress > 0 ? progress : null),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _CloudContainer extends StatelessWidget {
  const _CloudContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: CustomPaint(
        painter: _CloudPainter(
          color: theme.colorScheme.primary,
          shadow: Colors.black.withValues(alpha: 0.18),
        ),
        child: child,
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  _CloudPainter({required this.color, required this.shadow});

  final Color color;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildCloud(size);
    canvas.drawShadow(path, shadow, 6, false);
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  Path _buildCloud(Size size) {
    final w = size.width;
    final h = size.height;
    final bodyTop = h * 0.28;
    final radius = 18.0;

    final path = Path()
      ..moveTo(radius, bodyTop)
      ..arcToPoint(Offset(radius * 2, bodyTop - radius),
          radius: Radius.circular(radius), clockwise: true);

    final bumps = [
      Offset(w * 0.18, bodyTop),
      Offset(w * 0.42, bodyTop),
      Offset(w * 0.68, bodyTop),
      Offset(w * 0.88, bodyTop),
    ];
    final bumpRadii = [16.0, 22.0, 20.0, 14.0];
    for (var i = 0; i < bumps.length; i++) {
      final c = bumps[i];
      final r = bumpRadii[i];
      path.arcToPoint(
        Offset(c.dx + r, c.dy),
        radius: Radius.circular(r),
        clockwise: true,
      );
      if (i < bumps.length - 1) {
        path.lineTo(bumps[i + 1].dx - bumpRadii[i + 1], bumps[i + 1].dy);
      }
    }
    path.lineTo(w - radius, bodyTop);
    path.arcToPoint(Offset(w, bodyTop + radius),
        radius: Radius.circular(radius), clockwise: true);
    path.lineTo(w, h - radius);
    path.arcToPoint(Offset(w - radius, h),
        radius: Radius.circular(radius), clockwise: true);
    path.lineTo(radius, h);
    path.arcToPoint(Offset(0, h - radius),
        radius: Radius.circular(radius), clockwise: true);
    path.lineTo(0, bodyTop + radius);
    path.arcToPoint(Offset(radius, bodyTop),
        radius: Radius.circular(radius), clockwise: true);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.shadow != shadow;
}
