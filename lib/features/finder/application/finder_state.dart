import 'package:flutter/material.dart';

import '../../theme/data/models/theme_search_query.dart';

enum PartyHint {
  couple,
  twoFriends,
  smallGroup,
  bigGroup,
  family,
  solo,
  colleagues,
  activity,
}

enum ExperienceLevel {
  first,
  novice,
  intermediate,
  advanced,
  expert,
  master,
}

enum FearTolerance { none, mild, moderate, strong, lover }

class FinderState {
  const FinderState({
    this.difficulty = const RangeValues(0, 5),
    this.fear = const RangeValues(0, 5),
    this.activity = const RangeValues(0, 5),
    this.story = const RangeValues(0, 5),
    this.problem = const RangeValues(0, 5),
    this.interior = const RangeValues(0, 5),
    this.playtime = const RangeValues(30, 120),
    this.price = const RangeValues(10000, 50000),
    this.areas = const <String>{},
    this.locations = const <String>{},
    this.onlyOpen = true,
    this.party,
    this.level,
    this.fearTolerance,
  });

  final RangeValues difficulty;
  final RangeValues fear;
  final RangeValues activity;
  final RangeValues story;
  final RangeValues problem;
  final RangeValues interior;
  final RangeValues playtime;
  final RangeValues price;
  final Set<String> areas;
  final Set<String> locations;
  final bool onlyOpen;
  final PartyHint? party;
  final ExperienceLevel? level;
  final FearTolerance? fearTolerance;

  FinderState copyWith({
    RangeValues? difficulty,
    RangeValues? fear,
    RangeValues? activity,
    RangeValues? story,
    RangeValues? problem,
    RangeValues? interior,
    RangeValues? playtime,
    RangeValues? price,
    Set<String>? areas,
    Set<String>? locations,
    bool? onlyOpen,
    PartyHint? party,
    bool clearParty = false,
    ExperienceLevel? level,
    bool clearLevel = false,
    FearTolerance? fearTolerance,
    bool clearFearTolerance = false,
  }) =>
      FinderState(
        difficulty: difficulty ?? this.difficulty,
        fear: fear ?? this.fear,
        activity: activity ?? this.activity,
        story: story ?? this.story,
        problem: problem ?? this.problem,
        interior: interior ?? this.interior,
        playtime: playtime ?? this.playtime,
        price: price ?? this.price,
        areas: areas ?? this.areas,
        locations: locations ?? this.locations,
        onlyOpen: onlyOpen ?? this.onlyOpen,
        party: clearParty ? null : (party ?? this.party),
        level: clearLevel ? null : (level ?? this.level),
        fearTolerance:
            clearFearTolerance ? null : (fearTolerance ?? this.fearTolerance),
      );

  RangeValues effectiveDifficulty() {
    RangeValues r = difficulty;
    const level2range = <ExperienceLevel, RangeValues>{
      ExperienceLevel.first: RangeValues(0.0, 2.0),
      ExperienceLevel.novice: RangeValues(1.0, 2.5),
      ExperienceLevel.intermediate: RangeValues(2.0, 3.5),
      ExperienceLevel.advanced: RangeValues(2.5, 4.0),
      ExperienceLevel.expert: RangeValues(3.0, 4.5),
      ExperienceLevel.master: RangeValues(3.5, 5.0),
    };
    final bounds = level2range[level];
    if (bounds != null) r = _intersect(r, bounds);
    if (party == PartyHint.family) {
      r = _intersect(r, const RangeValues(1.0, 3.0));
    }
    if (party == PartyHint.colleagues) {
      r = _intersect(r, const RangeValues(1.5, 3.5));
    }
    return r;
  }

  RangeValues effectiveFear() {
    RangeValues r = fear;
    const tolerance2range = <FearTolerance, RangeValues>{
      FearTolerance.none: RangeValues(0.0, 1.0),
      FearTolerance.mild: RangeValues(0.0, 2.0),
      FearTolerance.moderate: RangeValues(1.5, 3.5),
      FearTolerance.strong: RangeValues(2.5, 4.5),
      FearTolerance.lover: RangeValues(3.5, 5.0),
    };
    final bounds = tolerance2range[fearTolerance];
    if (bounds != null) r = _intersect(r, bounds);

    const party2fear = <PartyHint, RangeValues>{
      PartyHint.couple: RangeValues(0.0, 3.0),
      PartyHint.family: RangeValues(0.0, 1.5),
      PartyHint.colleagues: RangeValues(0.0, 2.5),
    };
    final pf = party2fear[party];
    if (pf != null) r = _intersect(r, pf);
    return r;
  }

  RangeValues effectiveActivity() {
    RangeValues r = activity;
    const party2act = <PartyHint, RangeValues>{
      PartyHint.activity: RangeValues(3.0, 5.0),
      PartyHint.family: RangeValues(0.0, 2.5),
      PartyHint.bigGroup: RangeValues(2.0, 5.0),
      PartyHint.couple: RangeValues(0.0, 3.0),
    };
    final bounds = party2act[party];
    if (bounds != null) r = _intersect(r, bounds);
    return r;
  }

  static RangeValues _intersect(RangeValues a, RangeValues b) {
    final lo = a.start > b.start ? a.start : b.start;
    final hi = a.end < b.end ? a.end : b.end;
    if (lo > hi) return RangeValues(hi, hi);
    return RangeValues(lo, hi);
  }

  ThemeSearchQuery toQuery({int page = 0, int size = 20}) {
    final d = effectiveDifficulty();
    final f = effectiveFear();
    final a = effectiveActivity();

    double? startOrNull(double v) => v <= 0 ? null : v;
    double? endOrNull(double v) => v >= 5 ? null : v;

    return ThemeSearchQuery(
      startDifficulty: startOrNull(d.start),
      endDifficulty: endOrNull(d.end),
      startFear: startOrNull(f.start),
      endFear: endOrNull(f.end),
      startActivity: startOrNull(a.start),
      endActivity: endOrNull(a.end),
      startStory: startOrNull(story.start),
      endStory: endOrNull(story.end),
      startProblem: startOrNull(problem.start),
      endProblem: endOrNull(problem.end),
      startInterior: startOrNull(interior.start),
      endInterior: endOrNull(interior.end),
      startPlaytime: playtime.start <= 30 ? null : playtime.start.round(),
      endPlaytime: playtime.end >= 120 ? null : playtime.end.round(),
      startPrice: price.start <= 10000 ? null : price.start.round(),
      endPrice: price.end >= 50000 ? null : price.end.round(),
      areas: areas.toList(),
      locations: locations.toList(),
      onlyOpen: onlyOpen ? true : null,
      sort: 'satisfy,desc',
      page: page,
      size: size,
    );
  }

  Map<String, double> midpoints() {
    double mid(RangeValues r) => (r.start + r.end) / 2.0;
    final d = effectiveDifficulty();
    final f = effectiveFear();
    final a = effectiveActivity();
    return {
      'difficulty': mid(d),
      'fear': mid(f),
      'activity': mid(a),
      'story': mid(story),
      'problem': mid(problem),
      'interior': mid(interior),
    };
  }

  Map<String, double> weights() {
    final w = <String, double>{
      'difficulty': 1.4,
      'fear': 1.4,
      'activity': 1.0,
      'story': 1.0,
      'problem': 1.0,
      'interior': 0.6,
    };
    if (level != null) w['difficulty'] = 2.0;
    if (fearTolerance != null) w['fear'] = 2.0;
    if (party == PartyHint.activity) w['activity'] = 2.0;
    return w;
  }
}
