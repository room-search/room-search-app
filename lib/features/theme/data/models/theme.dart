import 'theme_review.dart';

/// Domain model for an escape room theme.
class EscapeTheme {
  const EscapeTheme({
    required this.refId,
    required this.name,
    required this.escapeCafeId,
    required this.photoUrl,
    required this.description,
    required this.playtime,
    required this.price,
    required this.isOpen,
    required this.createDate,
    required this.act,
    required this.activity,
    required this.difficulty,
    required this.fear,
    required this.interior,
    required this.problem,
    required this.satisfy,
    required this.story,
    this.review,
  });

  final int refId;
  final String name;
  final String escapeCafeId;
  final String photoUrl;
  final String description;
  final int playtime;
  final int price;
  final bool isOpen;
  final String createDate;
  final double act;
  final double activity;
  final double difficulty;
  final double fear;
  final double interior;
  final double problem;
  final double satisfy;
  final double story;
  final ThemeReview? review;

  factory EscapeTheme.fromJson(Map<String, dynamic> json) => EscapeTheme(
        refId: (json['refId'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        escapeCafeId: json['escapeCafeId'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
        description: json['description'] as String? ?? '',
        playtime: (json['playtime'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toInt() ?? 0,
        isOpen: json['isOpen'] as bool? ?? false,
        createDate: json['createDate'] as String? ?? '',
        act: (json['act'] as num?)?.toDouble() ?? 0,
        activity: (json['activity'] as num?)?.toDouble() ?? 0,
        difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0,
        fear: (json['fear'] as num?)?.toDouble() ?? 0,
        interior: (json['interior'] as num?)?.toDouble() ?? 0,
        problem: (json['problem'] as num?)?.toDouble() ?? 0,
        satisfy: (json['satisfy'] as num?)?.toDouble() ?? 0,
        story: (json['story'] as num?)?.toDouble() ?? 0,
        review: json['review'] is Map<String, dynamic>
            ? ThemeReview.fromJson(json['review'] as Map<String, dynamic>)
            : null,
      );

  Map<String, double> get scoreMap => {
        '난이도': difficulty,
        '공포': fear,
        '활동성': activity,
        '스토리': story,
        '문제수준': problem,
        '인테리어': interior,
        '연기력': act,
        '만족도': satisfy,
      };

  static const Map<String, String> scoreKeyToLabel = {
    'difficulty': '난이도',
    'fear': '공포',
    'activity': '활동성',
    'story': '스토리',
    'problem': '문제',
    'interior': '인테리어',
    'act': '연기력',
    'satisfy': '만족도',
  };

  double? scoreByKey(String key) {
    switch (key) {
      case 'difficulty':
        return difficulty;
      case 'fear':
        return fear;
      case 'activity':
        return activity;
      case 'story':
        return story;
      case 'problem':
        return problem;
      case 'interior':
        return interior;
      case 'act':
        return act;
      case 'satisfy':
        return satisfy;
    }
    return null;
  }
}

