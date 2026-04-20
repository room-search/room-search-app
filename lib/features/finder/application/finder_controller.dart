import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../theme/data/models/theme.dart';
import '../../theme/data/theme_repository.dart';
import 'finder_state.dart';

class FinderController extends Notifier<FinderState> {
  @override
  FinderState build() => const FinderState();

  void setDifficulty(RangeValues v) => state = state.copyWith(difficulty: v);
  void setFear(RangeValues v) => state = state.copyWith(fear: v);
  void setActivity(RangeValues v) => state = state.copyWith(activity: v);
  void setStory(RangeValues v) => state = state.copyWith(story: v);
  void setProblem(RangeValues v) => state = state.copyWith(problem: v);
  void setInterior(RangeValues v) => state = state.copyWith(interior: v);
  void setPlaytime(RangeValues v) => state = state.copyWith(playtime: v);
  void setPrice(RangeValues v) => state = state.copyWith(price: v);
  void setAreas(Set<String> v) => state = state.copyWith(areas: v);

  void setLocations(Set<String> v) => state = state.copyWith(locations: v);

  /// Atomic update: accepts the new area set and the map of area → valid
  /// locations so orphan locations (whose area got deselected) are dropped.
  void setRegions({
    required Set<String> areas,
    required Map<String, List<String>> areaToLocations,
  }) {
    final valid = <String>{};
    for (final a in areas) {
      valid.addAll(areaToLocations[a] ?? const <String>[]);
    }
    state = state.copyWith(
      areas: areas,
      locations: state.locations.intersection(valid),
    );
  }

  void toggleArea(String area) {
    final next = {...state.areas};
    if (next.contains(area)) {
      next.remove(area);
    } else {
      next.add(area);
    }
    state = state.copyWith(areas: next);
  }

  void toggleLocation(String loc) {
    final next = {...state.locations};
    if (next.contains(loc)) {
      next.remove(loc);
    } else {
      next.add(loc);
    }
    state = state.copyWith(locations: next);
  }

  void setOnlyOpen(bool v) => state = state.copyWith(onlyOpen: v);

  void setLevel(ExperienceLevel? v) =>
      state = state.copyWith(level: v, clearLevel: v == null);
  void setFearTolerance(FearTolerance? v) => state =
      state.copyWith(fearTolerance: v, clearFearTolerance: v == null);
  void setParty(PartyHint? v) =>
      state = state.copyWith(party: v, clearParty: v == null);

  void reset() => state = const FinderState();
}

final finderControllerProvider =
    NotifierProvider<FinderController, FinderState>(FinderController.new);

/// Live match count — debounced, uses size=1 probe.
final finderMatchCountProvider = AsyncNotifierProvider.autoDispose
    .family<FinderMatchCountController, int, FinderState>(
  FinderMatchCountController.new,
);

class FinderMatchCountController
    extends AutoDisposeFamilyAsyncNotifier<int, FinderState> {
  Timer? _debounceTimer;

  @override
  Future<int> build(FinderState arg) async {
    ref.onDispose(() => _debounceTimer?.cancel());
    return _fetch(arg);
  }

  Future<int> _fetch(FinderState s) async {
    final c = Completer<int>();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Env.searchDebounce, () async {
      try {
        final repo = ref.read(themeRepositoryProvider);
        final count = await repo.countMatches(s.toQuery(page: 0, size: 1));
        if (!c.isCompleted) c.complete(count);
      } catch (e) {
        if (!c.isCompleted) c.completeError(e);
      }
    });
    return c.future;
  }
}

/// Results: fetch filtered themes then re-rank on-device.
final finderResultsProvider = FutureProvider.autoDispose
    .family<List<EscapeTheme>, FinderState>((ref, state) async {
  final repo = ref.watch(themeRepositoryProvider);
  final page = await repo.search(state.toQuery(page: 0, size: 30));
  return page.content;
});
