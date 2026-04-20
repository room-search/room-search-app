import 'package:flutter/material.dart';

/// Strip "(N)" numeric prefixes/suffixes that sometimes appear in the
/// API's grade string (e.g. "(2) S+", "S+(0)") and return only the letter
/// grade. Returns empty string if nothing is left.
String cleanGrade(String? raw) {
  if (raw == null) return '';
  final stripped = raw.replaceAll(RegExp(r'\(\s*\d+\s*\)'), '').trim();
  return stripped;
}

/// Resolved color palette for a specific grade.
/// When [bg] is null the badge renders unfilled (for "Misc" / unknown).
class GradeColors {
  const GradeColors({this.bg, required this.fg, required this.border});
  final Color? bg;
  final Color fg;
  final Color border;
}

GradeColors gradeColorsFor(BuildContext context, String grade) {
  final scheme = Theme.of(context).colorScheme;
  switch (grade) {
    case 'S++':
      return const GradeColors(
        bg: Color(0xFFFF8A3D),
        fg: Colors.white,
        border: Color(0xFFFF8A3D),
      );
    case 'S+':
      return const GradeColors(
        bg: Color(0xFFFF4D8F),
        fg: Colors.white,
        border: Color(0xFFFF4D8F),
      );
    case 'S':
      return const GradeColors(
        bg: Color(0xFFFFD233),
        fg: Color(0xFF6B4E00),
        border: Color(0xFFFFD233),
      );
    case 'A+':
      return const GradeColors(
        bg: Color(0xFF3C6BFF),
        fg: Colors.white,
        border: Color(0xFF3C6BFF),
      );
    case 'A':
      return const GradeColors(
        bg: Color(0xFF6EC4FF),
        fg: Color(0xFF063563),
        border: Color(0xFF6EC4FF),
      );
    case 'B+':
      return const GradeColors(
        bg: Color(0xFF2BB673),
        fg: Colors.white,
        border: Color(0xFF2BB673),
      );
    case 'B':
      return const GradeColors(
        bg: Color(0xFFB6E24A),
        fg: Color(0xFF2F4D00),
        border: Color(0xFFB6E24A),
      );
    case 'C+':
      return const GradeColors(
        bg: Color(0xFFB00020),
        fg: Colors.white,
        border: Color(0xFFB00020),
      );
    case 'C':
      return const GradeColors(
        bg: Color(0xFFFF4040),
        fg: Colors.white,
        border: Color(0xFFFF4040),
      );
    case 'F':
      return const GradeColors(
        bg: Color(0xFF111111),
        fg: Colors.white,
        border: Color(0xFF111111),
      );
    case 'X':
      return const GradeColors(
        bg: Color(0xFF9E9E9E),
        fg: Colors.white,
        border: Color(0xFF9E9E9E),
      );
    default:
      return GradeColors(
        bg: null,
        fg: scheme.onSurface.withValues(alpha: 0.75),
        border: scheme.outline,
      );
  }
}

/// Compact colored badge rendering a review grade like "S+", "A", "B+".
class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade, this.dense = false});

  final String grade;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cleaned = cleanGrade(grade);
    if (cleaned.isEmpty) return const SizedBox.shrink();
    final colors = gradeColorsFor(context, cleaned);
    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border.all(color: colors.border, width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        cleaned,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              fontSize: dense ? 11 : 13,
            ),
      ),
    );
  }
}
