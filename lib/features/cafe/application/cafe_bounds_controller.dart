import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cafe_repository.dart';
import '../data/models/cafe.dart';

class BoundsQuery {
  const BoundsQuery({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    this.onlyOpen,
  });

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final bool? onlyOpen;
}

class CafeBoundsState {
  const CafeBoundsState({
    this.cafes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<EscapeCafe> cafes;
  final bool isLoading;
  final Object? error;

  CafeBoundsState copyWith({
    List<EscapeCafe>? cafes,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) =>
      CafeBoundsState(
        cafes: cafes ?? this.cafes,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class CafeBoundsController extends Notifier<CafeBoundsState> {
  @override
  CafeBoundsState build() => const CafeBoundsState();

  Future<void> loadForBounds(BoundsQuery q) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(cafeRepositoryProvider);
      final result = await repo.byBounds(
        minLat: q.minLat,
        maxLat: q.maxLat,
        minLng: q.minLng,
        maxLng: q.maxLng,
        onlyOpen: q.onlyOpen,
      );
      state = state.copyWith(cafes: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

final cafeBoundsControllerProvider =
    NotifierProvider<CafeBoundsController, CafeBoundsState>(
  CafeBoundsController.new,
);
