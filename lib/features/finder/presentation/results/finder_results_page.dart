import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../theme/presentation/widgets/theme_card.dart';
import '../../application/finder_controller.dart';
import '../../application/match_score.dart';

class FinderResultsPage extends ConsumerWidget {
  const FinderResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(finderControllerProvider);
    final async = ref.watch(finderResultsProvider(state));
    final scorer = MatchScorer(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 결과'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: '결과를 불러오지 못했어요',
          onRetry: () => ref.invalidate(finderResultsProvider(state)),
        ),
        data: (themes) {
          if (themes.isEmpty) {
            return const EmptyView(
              title: '조건에 맞는 테마가 없어요',
              subtitle: '조금 더 느슨한 조건을 시도해 보세요.',
              icon: Icons.search_off_rounded,
            );
          }
          final ranked = scorer.rank(themes);
          return AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: ranked.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final r = ranked[i];
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 420),
                  child: SlideAnimation(
                    verticalOffset: 20,
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          _MatchRing(score: r.score),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ThemeCard(
                              theme: r.theme,
                              onTap: () => context.push(
                                '/themes/${r.theme.refId}',
                                extra: r.theme.photoUrl,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.tune_rounded),
        label: const Text('조건 수정'),
      ),
    );
  }
}

class _MatchRing extends StatelessWidget {
  const _MatchRing({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = score.clamp(0, 100) / 100;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (ctx, v, _) => SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: 5,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
          ),
          Text(
            '${score.round()}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
          ),
        ],
      ).animate().fadeIn(duration: 260.ms),
    );
  }
}
