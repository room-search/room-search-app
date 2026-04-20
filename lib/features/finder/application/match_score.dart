import '../../theme/data/models/theme.dart';
import 'finder_state.dart';

class ScoredTheme {
  const ScoredTheme({required this.theme, required this.score});
  final EscapeTheme theme;
  final double score;
}

class MatchScorer {
  const MatchScorer(this.state);
  final FinderState state;

  /// Returns a 0..100 matching score. Higher is closer to the user's target.
  double scoreFor(EscapeTheme t) {
    final mid = state.midpoints();
    final w = state.weights();
    double penalty = 0;
    penalty += w['difficulty']! * (t.difficulty - mid['difficulty']!).abs();
    penalty += w['fear']! * (t.fear - mid['fear']!).abs();
    penalty += w['activity']! * (t.activity - mid['activity']!).abs();
    penalty += w['story']! * (t.story - mid['story']!).abs();
    penalty += w['problem']! * (t.problem - mid['problem']!).abs();
    penalty += w['interior']! * (t.interior - mid['interior']!).abs();

    // playtime / price out-of-range penalties
    if (t.playtime < state.playtime.start) {
      penalty += (state.playtime.start - t.playtime) * 0.1;
    }
    if (t.playtime > state.playtime.end) {
      penalty += (t.playtime - state.playtime.end) * 0.1;
    }
    if (t.price < state.price.start) {
      penalty += (state.price.start - t.price) / 5000;
    }
    if (t.price > state.price.end) {
      penalty += (t.price - state.price.end) / 5000;
    }

    // satisfaction bonus
    final bonus = 2.0 * t.satisfy;

    // Max theoretical penalty ~ (1.4+1.4+1+1+1+0.6) * 5 = 32; scale.
    final raw = 100 - penalty * 2 + bonus;
    if (raw.isNaN) return 0;
    return raw.clamp(0, 100).toDouble();
  }

  List<ScoredTheme> rank(List<EscapeTheme> themes) {
    final scored = themes.map((t) => ScoredTheme(theme: t, score: scoreFor(t))).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}
