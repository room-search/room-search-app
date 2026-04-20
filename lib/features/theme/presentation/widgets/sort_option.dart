class ThemeSortOption {
  const ThemeSortOption({
    required this.label,
    required this.apiValue,
    this.scoreKey,
  });

  final String label;
  final String apiValue;

  /// If this sort targets a numeric score field on the theme, scoreKey
  /// is the dot-field name on `EscapeTheme` so cards can highlight it.
  final String? scoreKey;

  static const List<ThemeSortOption> all = [
    ThemeSortOption(label: '최근순', apiValue: 'createDate,desc'),
    ThemeSortOption(label: '오래된순', apiValue: 'createDate,asc'),
    ThemeSortOption(label: '이름순', apiValue: 'name,asc'),
    ThemeSortOption(
        label: '만족도 높은순', apiValue: 'satisfy,desc', scoreKey: 'satisfy'),
    ThemeSortOption(
        label: '난이도 높은순', apiValue: 'difficulty,desc', scoreKey: 'difficulty'),
    ThemeSortOption(
        label: '난이도 낮은순', apiValue: 'difficulty,asc', scoreKey: 'difficulty'),
    ThemeSortOption(
        label: '공포도 높은순', apiValue: 'fear,desc', scoreKey: 'fear'),
    ThemeSortOption(
        label: '공포도 낮은순', apiValue: 'fear,asc', scoreKey: 'fear'),
    ThemeSortOption(
        label: '활동성 높은순', apiValue: 'activity,desc', scoreKey: 'activity'),
    ThemeSortOption(
        label: '스토리 높은순', apiValue: 'story,desc', scoreKey: 'story'),
    ThemeSortOption(
        label: '문제수준 높은순', apiValue: 'problem,desc', scoreKey: 'problem'),
    ThemeSortOption(
        label: '인테리어 높은순', apiValue: 'interior,desc', scoreKey: 'interior'),
    ThemeSortOption(
        label: '연기력 높은순', apiValue: 'act,desc', scoreKey: 'act'),
    ThemeSortOption(label: '플레이타임 짧은순', apiValue: 'playtime,asc'),
    ThemeSortOption(label: '플레이타임 긴순', apiValue: 'playtime,desc'),
    ThemeSortOption(label: '가격 낮은순', apiValue: 'price,asc'),
    ThemeSortOption(label: '가격 높은순', apiValue: 'price,desc'),
  ];

  static const ThemeSortOption defaultSort = ThemeSortOption(
    label: '최근순',
    apiValue: 'createDate,desc',
  );

  static ThemeSortOption? findByApi(String? apiValue) {
    if (apiValue == null) return null;
    for (final o in all) {
      if (o.apiValue == apiValue) return o;
    }
    return null;
  }
}
