import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../features/theme/data/models/theme.dart';
import 'cached_theme_image.dart';
import 'grade_badge.dart';

/// Portrait poster card used in horizontal scrolling theme lists
/// (cafe detail "테마 목록", theme detail "이 카페의 다른 테마").
class ThemePosterCard extends StatelessWidget {
  const ThemePosterCard({
    super.key,
    required this.theme,
    required this.onTap,
    this.width = 150,
    this.posterAspect = 2 / 3,
    this.heroTag,
  });

  final EscapeTheme theme;
  final VoidCallback onTap;
  final double width;
  final double posterAspect;

  /// Optional override. Defaults to the standard `theme-photo-${refId}` tag
  /// so transitions animate from any list (search / favorites / cafe detail).
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final grade = cleanGrade(theme.review?.satisfy);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: heroTag ?? 'theme-photo-${theme.refId}',
                    child: AspectRatio(
                      aspectRatio: posterAspect,
                      child: CachedThemeImage(
                        url: theme.photoUrl,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (grade.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GradeBadge(grade: grade, dense: true),
                    ),
                  if (!theme.isOpen)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '휴업',
                          style: text.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                theme.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: scheme.secondary),
                  const SizedBox(width: 2),
                  Text(
                    formatScore(theme.satisfy),
                    style: text.labelMedium,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '난이도 ${formatScore(theme.difficulty)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${formatPlaytime(theme.playtime)} · ${formatPriceWon(theme.price)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
