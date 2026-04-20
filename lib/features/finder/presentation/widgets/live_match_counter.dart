import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/finder_controller.dart';
import '../../application/finder_state.dart';

class LiveMatchCounter extends ConsumerWidget {
  const LiveMatchCounter({super.key, required this.state});

  final FinderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(finderMatchCountProvider(state));
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return async.when(
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text('집계 중…', style: text.labelMedium),
        ],
      ),
      error: (err, _) => Text('– 개', style: text.labelMedium),
      data: (count) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Row(
          key: ValueKey(count),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: text.headlineMedium?.copyWith(color: scheme.primary),
            ),
            const SizedBox(width: 4),
            Text('개 매칭',
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                )),
          ],
        ),
      ),
    );
  }
}
