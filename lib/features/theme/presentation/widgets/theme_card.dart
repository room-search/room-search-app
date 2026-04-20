import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/cached_theme_image.dart';
import '../../../../shared/widgets/favorite_heart_button.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../../../favorites/data/favorite_repository.dart';
import '../../data/models/theme.dart';

class ThemeCard extends ConsumerWidget {
  const ThemeCard({
    super.key,
    required this.theme,
    required this.onTap,
    this.trailing,
    this.highlightScoreKey,
  });

  final EscapeTheme theme;
  final VoidCallback onTap;
  final Widget? trailing;

  /// When set, the card emphasizes this score (by key like 'activity')
  /// so the user can see why the current sort ordering puts it here.
  final String? highlightScoreKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final repo = ref.watch(favoriteRepositoryProvider);
    ref.watch(themeFavoritesChangedProvider);
    final isFav = repo.isThemeFavorite(theme.refId);

    final grade = cleanGrade(theme.review?.satisfy);
    final highlightLabel =
        highlightScoreKey != null ? EscapeTheme.scoreKeyToLabel[highlightScoreKey] : null;
    final highlightValue =
        highlightScoreKey != null ? theme.scoreByKey(highlightScoreKey!) : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Hero(
                tag: 'theme-photo-${theme.refId}',
                child: SizedBox(
                  width: 84,
                  height: 112,
                  child: CachedThemeImage(
                    url: theme.photoUrl,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (!theme.isOpen)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '휴업',
                              style: text.labelMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            theme.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (highlightLabel != null && highlightValue != null)
                          _emphasisTag(
                            context,
                            '$highlightLabel ${formatScore(highlightValue)}',
                          ),
                        if (grade.isNotEmpty) GradeBadge(grade: grade, dense: true),
                        _miniTag(context, '난이도 ${formatScore(theme.difficulty)}'),
                        _miniTag(context, '공포 ${formatScore(theme.fear)}'),
                        _miniTag(context, formatPlaytime(theme.playtime)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16, color: scheme.secondary),
                        const SizedBox(width: 2),
                        Text(
                          formatScore(theme.satisfy),
                          style: text.labelLarge,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            formatPriceWon(theme.price),
                            style: text.labelMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.65),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing ??
                  FavoriteHeartButton(
                    isFavorite: isFav,
                    size: 24,
                    onTap: () => ref
                        .read(favoriteRepositoryProvider)
                        .toggleTheme(theme),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniTag(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _emphasisTag(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
