import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/cached_theme_image.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/favorite_heart_button.dart';
import '../../../shared/widgets/grade_badge.dart';
import '../../../shared/widgets/score_bar.dart';
import '../../../shared/widgets/theme_poster_card.dart';
import '../../cafe/application/cafe_detail_controller.dart';
import '../../favorites/data/favorite_repository.dart';
import '../application/theme_detail_controller.dart';
import '../data/models/theme.dart';
import '../data/models/theme_review.dart';
import 'widgets/score_radar_chart.dart';

class ThemeDetailPage extends ConsumerWidget {
  const ThemeDetailPage({super.key, required this.refId, this.heroPhotoUrl});

  final int refId;
  final String? heroPhotoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(themeDetailProvider(refId));
    return Scaffold(
      body: async.when(
        loading: () => _LoadingScaffold(heroPhotoUrl: heroPhotoUrl, refId: refId),
        error: (err, _) => Center(
          child: ErrorView(
            message: '테마 정보를 불러오지 못했어요',
            onRetry: () => ref.invalidate(themeDetailProvider(refId)),
          ),
        ),
        data: (theme) => _Loaded(theme: theme),
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({this.heroPhotoUrl, required this.refId});
  final String? heroPhotoUrl;
  final int refId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (heroPhotoUrl != null)
          _PosterHeader(photoUrl: heroPhotoUrl!, refId: refId),
        const Positioned.fill(child: Center(child: CircularProgressIndicator())),
        Positioned(
          left: 8,
          top: MediaQuery.of(context).padding.top + 4,
          child: const _BackChip(),
        ),
      ],
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.photoUrl, required this.refId});

  final String photoUrl;
  final int refId;

  static const double _height = 420;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background poster for ambience
          if (photoUrl.isNotEmpty)
            ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(color: scheme.primary.withValues(alpha: 0.15)),
          // Scrim for readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface.withValues(alpha: 0.25),
                  scheme.surface.withValues(alpha: 0.6),
                  scheme.surface,
                ],
                stops: const [0, 0.72, 1],
              ),
            ),
          ),
          // Centered portrait poster
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 56, 48, 40),
              child: Hero(
                tag: 'theme-photo-$refId',
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 32,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: CachedThemeImage(
                      url: photoUrl,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.theme});
  final EscapeTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final repo = ref.watch(favoriteRepositoryProvider);
    ref.watch(themeFavoritesChangedProvider);
    final isFav = repo.isThemeFavorite(theme.refId);
    final review = theme.review;
    final grade = cleanGrade(review?.satisfy);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PosterHeader(photoUrl: theme.photoUrl, refId: theme.refId),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (grade.isNotEmpty) ...[
                          GradeBadge(grade: grade),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(theme.name, style: text.headlineLarge),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 260.ms)
                        .slideY(begin: 0.1, end: 0, duration: 260.ms),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(context, Icons.timer_outlined,
                            formatPlaytime(theme.playtime)),
                        _chip(context, Icons.payments_outlined,
                            formatPriceWon(theme.price)),
                        _chip(
                          context,
                          theme.isOpen
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_outline,
                          theme.isOpen ? '영업중' : '휴업',
                          colored: theme.isOpen,
                        ),
                        if (review?.difficulty != null &&
                            review!.difficulty!.isNotEmpty)
                          _chip(
                            context,
                            Icons.psychology_alt_outlined,
                            '체감 난이도 ${review.difficulty!}',
                          ),
                      ],
                    ),
                    if (theme.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        theme.description,
                        style: text.bodyLarge?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Text('점수', style: text.titleLarge),
                    const SizedBox(height: 8),
                    Center(child: ScoreRadarChart(scores: theme.scoreMap)),
                    const SizedBox(height: 8),
                    ..._scoreBars(theme),
                    if (review != null) _ReviewSection(review: review)
                        .animate()
                        .fadeIn(duration: 320.ms, delay: 180.ms),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.storefront_rounded),
                        label: const Text('카페 상세 보기'),
                        onPressed: () =>
                            context.push('/cafes/${theme.escapeCafeId}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _OtherThemesFromCafe(
                cafeId: theme.escapeCafeId,
                currentRefId: theme.refId,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        // Floating controls
        Positioned(
          left: 4,
          top: MediaQuery.of(context).padding.top + 4,
          child: const _BackChip(),
        ),
        Positioned(
          right: 4,
          top: MediaQuery.of(context).padding.top + 4,
          child: _GlassCircle(
            child: FavoriteHeartButton(
              isFavorite: isFav,
              size: 22,
              onTap: () => repo.toggleTheme(theme),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _scoreBars(EscapeTheme t) {
    final entries = t.scoreMap.entries.toList();
    return [
      for (var i = 0; i < entries.length; i++) ...[
        ScoreBar(label: entries[i].key, value: entries[i].value)
            .animate()
            .fadeIn(duration: 260.ms, delay: (60 * i).ms)
            .slideX(begin: -0.08, end: 0, duration: 260.ms, delay: (60 * i).ms),
        if (i != entries.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  Widget _chip(BuildContext context, IconData icon, String text,
      {bool colored = false}) {
    final scheme = Theme.of(context).colorScheme;
    final bg = colored
        ? scheme.tertiary.withValues(alpha: 0.16)
        : scheme.surfaceContainerHighest;
    final fg = colored ? scheme.tertiary : scheme.onSurface.withValues(alpha: 0.8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.review});
  final ThemeReview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final counts = <(String, int)>[
      if (review.story != null) ('스토리', review.story!),
      if (review.problem != null) ('문제', review.problem!),
      if (review.interior != null) ('인테리어', review.interior!),
      if (review.activity != null) ('활동성', review.activity!),
      if (review.act != null) ('연기력', review.act!),
      if (review.fear != null) ('공포', review.fear!),
      if (review.idea != null) ('창의성', review.idea!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text('리뷰 요약', style: text.titleLarge),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withValues(alpha: 0.08),
                scheme.secondary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (cleanGrade(review.satisfy).isNotEmpty)
                GradeBadge(grade: review.satisfy!),
              if (review.average != null) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('평균', style: text.labelMedium),
                    Text(
                      review.average!.toStringAsFixed(2),
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (review.difficulty != null && review.difficulty!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('체감 난이도', style: text.labelMedium),
                    Text(review.difficulty!, style: text.titleMedium),
                  ],
                ),
            ],
          ),
        ),
        if (counts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
            ),
            child: Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                for (final c in counts)
                  _ReviewCountPill(label: c.$1, value: c.$2),
              ],
            ),
          ),
        ],
        if (review.review != null && review.review!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('한 줄 후기', style: text.labelLarge),
                const SizedBox(height: 6),
                Text(review.review!, style: text.bodyMedium),
              ],
            ),
          ),
        ],
        if (review.escapeTip != null && review.escapeTip!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: scheme.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('탈출 팁',
                          style: text.labelLarge?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 4),
                      Text(review.escapeTip!, style: text.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewCountPill extends StatelessWidget {
  const _ReviewCountPill({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: text.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            )),
        const SizedBox(width: 4),
        Text('$value',
            style: text.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

class _OtherThemesFromCafe extends ConsumerWidget {
  const _OtherThemesFromCafe({
    required this.cafeId,
    required this.currentRefId,
  });

  final String cafeId;
  final int currentRefId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cafeId.isEmpty) return const SizedBox.shrink();
    final async = ref.watch(cafeDetailProvider(cafeId));
    final text = Theme.of(context).textTheme;

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cafe) {
        final others = cafe.themes
            .where((t) => t.refId != currentRefId)
            .toList(growable: false);
        if (others.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: [
                    Text('이 카페의 다른 테마', style: text.titleLarge),
                    const SizedBox(width: 6),
                    Text('${others.length}',
                        style: text.labelMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 320,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: others.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final t = others[i];
                    return ThemePosterCard(
                      theme: t,
                      onTap: () => ctx.push(
                        '/themes/${t.refId}',
                        extra: t.photoUrl,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (60 * i).ms, duration: 260.ms)
                        .slideX(
                          begin: 0.15,
                          end: 0,
                          delay: (60 * i).ms,
                          duration: 260.ms,
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip();

  @override
  Widget build(BuildContext context) {
    return _GlassCircle(
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
