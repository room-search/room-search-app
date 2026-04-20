import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/spring_page.dart';
import '../data/cafe_repository.dart';
import '../data/models/cafe.dart';

class CafeSearchParams {
  const CafeSearchParams({
    this.search,
    this.area,
    this.location,
    this.onlyOpen,
    this.page = 0,
    this.size = 20,
  });

  final String? search;
  final String? area;
  final String? location;
  final bool? onlyOpen;
  final int page;
  final int size;

  CafeSearchParams copyWith({
    String? search,
    String? area,
    String? location,
    bool? onlyOpen,
    int? page,
    int? size,
    bool clearArea = false,
    bool clearLocation = false,
  }) =>
      CafeSearchParams(
        search: search ?? this.search,
        area: clearArea ? null : (area ?? this.area),
        location: clearLocation ? null : (location ?? this.location),
        onlyOpen: onlyOpen ?? this.onlyOpen,
        page: page ?? this.page,
        size: size ?? this.size,
      );
}

class CafeSearchState {
  const CafeSearchState({
    required this.params,
    required this.page,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final CafeSearchParams params;
  final SpringPage<EscapeCafe> page;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  CafeSearchState copyWith({
    CafeSearchParams? params,
    SpringPage<EscapeCafe>? page,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) =>
      CafeSearchState(
        params: params ?? this.params,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class CafeSearchController extends Notifier<CafeSearchState> {
  @override
  CafeSearchState build() {
    Future.microtask(() => _load(resetPage: true));
    return CafeSearchState(
      params: const CafeSearchParams(),
      page: SpringPage.empty$<EscapeCafe>(),
      isLoading: true,
    );
  }

  Future<void> _load({required bool resetPage}) async {
    final repo = ref.read(cafeRepositoryProvider);
    try {
      final next = resetPage ? state.params.copyWith(page: 0) : state.params;
      if (resetPage) {
        state = state.copyWith(
          params: next,
          isLoading: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(isLoadingMore: true);
      }
      final result = await repo.search(
        area: next.area,
        location: next.location,
        search: next.search,
        onlyOpen: next.onlyOpen,
        page: next.page,
        size: next.size,
      );
      if (resetPage) {
        state = state.copyWith(
          page: result,
          isLoading: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          page: SpringPage<EscapeCafe>(
            content: [...state.page.content, ...result.content],
            totalPages: result.totalPages,
            totalElements: result.totalElements,
            number: result.number,
            size: result.size,
            first: false,
            last: result.last,
            empty: result.empty && state.page.empty,
          ),
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e,
      );
    }
  }

  Future<void> refresh() => _load(resetPage: true);

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.page.last) return;
    state = state.copyWith(
      params: state.params.copyWith(page: state.page.number + 1),
    );
    await _load(resetPage: false);
  }

  void setSearch(String value) {
    state = state.copyWith(params: state.params.copyWith(search: value, page: 0));
    _load(resetPage: true);
  }

  void setArea(String? area) {
    state = state.copyWith(
      params: state.params.copyWith(
        area: area,
        clearArea: area == null,
        location: null,
        clearLocation: true,
        page: 0,
      ),
    );
    _load(resetPage: true);
  }

  void setLocation(String? location) {
    state = state.copyWith(
      params: state.params.copyWith(
        location: location,
        clearLocation: location == null,
        page: 0,
      ),
    );
    _load(resetPage: true);
  }

  void setOnlyOpen(bool? value) {
    state = state.copyWith(params: state.params.copyWith(onlyOpen: value, page: 0));
    _load(resetPage: true);
  }
}

final cafeSearchControllerProvider =
    NotifierProvider<CafeSearchController, CafeSearchState>(
  CafeSearchController.new,
);
