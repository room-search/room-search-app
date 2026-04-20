class ThemeReview {
  const ThemeReview({
    this.act,
    this.activity,
    this.average,
    this.difficulty,
    this.escapeTip,
    this.fear,
    this.idea,
    this.interior,
    this.problem,
    this.review,
    this.satisfy,
    this.story,
  });

  final int? act;
  final int? activity;
  final double? average;
  final String? difficulty;
  final String? escapeTip;
  final int? fear;
  final int? idea;
  final int? interior;
  final int? problem;
  final String? review;
  final String? satisfy;
  final int? story;

  factory ThemeReview.fromJson(Map<String, dynamic> json) => ThemeReview(
        act: (json['act'] as num?)?.toInt(),
        activity: (json['activity'] as num?)?.toInt(),
        average: (json['average'] as num?)?.toDouble(),
        difficulty: json['difficulty'] as String?,
        escapeTip: json['escapeTip'] as String?,
        fear: (json['fear'] as num?)?.toInt(),
        idea: (json['idea'] as num?)?.toInt(),
        interior: (json['interior'] as num?)?.toInt(),
        problem: (json['problem'] as num?)?.toInt(),
        review: json['review'] as String?,
        satisfy: json['satisfy'] as String?,
        story: (json['story'] as num?)?.toInt(),
      );
}
