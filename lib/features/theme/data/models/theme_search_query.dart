class ThemeSearchQuery {
  const ThemeSearchQuery({
    this.search,
    this.areas = const [],
    this.locations = const [],
    this.onlyOpen,
    this.startAct,
    this.endAct,
    this.startActivity,
    this.endActivity,
    this.startDifficulty,
    this.endDifficulty,
    this.startFear,
    this.endFear,
    this.startInterior,
    this.endInterior,
    this.startProblem,
    this.endProblem,
    this.startSatisfy,
    this.endSatisfy,
    this.startStory,
    this.endStory,
    this.startPlaytime,
    this.endPlaytime,
    this.startPrice,
    this.endPrice,
    this.page = 0,
    this.size = 20,
    this.sort = 'createDate,desc',
  });

  final String? search;
  final List<String> areas;
  final List<String> locations;
  final bool? onlyOpen;
  final double? startAct;
  final double? endAct;
  final double? startActivity;
  final double? endActivity;
  final double? startDifficulty;
  final double? endDifficulty;
  final double? startFear;
  final double? endFear;
  final double? startInterior;
  final double? endInterior;
  final double? startProblem;
  final double? endProblem;
  final double? startSatisfy;
  final double? endSatisfy;
  final double? startStory;
  final double? endStory;
  final int? startPlaytime;
  final int? endPlaytime;
  final int? startPrice;
  final int? endPrice;
  final int page;
  final int size;
  final String? sort;

  Map<String, dynamic> toQuery() {
    final q = <String, dynamic>{
      'page': page,
      'size': size,
    };
    void set(String k, dynamic v) {
      if (v == null) return;
      if (v is String && v.isEmpty) return;
      if (v is List && v.isEmpty) return;
      q[k] = v;
    }

    set('search', search);
    set('areas', areas);
    set('locations', locations);
    set('onlyOpen', onlyOpen);
    set('startAct', startAct);
    set('endAct', endAct);
    set('startActivity', startActivity);
    set('endActivity', endActivity);
    set('startDifficulty', startDifficulty);
    set('endDifficulty', endDifficulty);
    set('startFear', startFear);
    set('endFear', endFear);
    set('startInterior', startInterior);
    set('endInterior', endInterior);
    set('startProblem', startProblem);
    set('endProblem', endProblem);
    set('startSatisfy', startSatisfy);
    set('endSatisfy', endSatisfy);
    set('startStory', startStory);
    set('endStory', endStory);
    set('startPlaytime', startPlaytime);
    set('endPlaytime', endPlaytime);
    set('startPrice', startPrice);
    set('endPrice', endPrice);
    set('sort', sort);
    return q;
  }

  ThemeSearchQuery copyWith({
    String? search,
    List<String>? areas,
    List<String>? locations,
    bool? onlyOpen,
    double? startDifficulty,
    double? endDifficulty,
    double? startFear,
    double? endFear,
    double? startActivity,
    double? endActivity,
    double? startStory,
    double? endStory,
    double? startProblem,
    double? endProblem,
    double? startInterior,
    double? endInterior,
    double? startAct,
    double? endAct,
    double? startSatisfy,
    double? endSatisfy,
    int? startPlaytime,
    int? endPlaytime,
    int? startPrice,
    int? endPrice,
    int? page,
    int? size,
    String? sort,
  }) =>
      ThemeSearchQuery(
        search: search ?? this.search,
        areas: areas ?? this.areas,
        locations: locations ?? this.locations,
        onlyOpen: onlyOpen ?? this.onlyOpen,
        startDifficulty: startDifficulty ?? this.startDifficulty,
        endDifficulty: endDifficulty ?? this.endDifficulty,
        startFear: startFear ?? this.startFear,
        endFear: endFear ?? this.endFear,
        startActivity: startActivity ?? this.startActivity,
        endActivity: endActivity ?? this.endActivity,
        startStory: startStory ?? this.startStory,
        endStory: endStory ?? this.endStory,
        startProblem: startProblem ?? this.startProblem,
        endProblem: endProblem ?? this.endProblem,
        startInterior: startInterior ?? this.startInterior,
        endInterior: endInterior ?? this.endInterior,
        startAct: startAct ?? this.startAct,
        endAct: endAct ?? this.endAct,
        startSatisfy: startSatisfy ?? this.startSatisfy,
        endSatisfy: endSatisfy ?? this.endSatisfy,
        startPlaytime: startPlaytime ?? this.startPlaytime,
        endPlaytime: endPlaytime ?? this.endPlaytime,
        startPrice: startPrice ?? this.startPrice,
        endPrice: endPrice ?? this.endPrice,
        page: page ?? this.page,
        size: size ?? this.size,
        sort: sort ?? this.sort,
      );
}
