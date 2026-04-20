import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/spring_page.dart';
import '../data/models/theme.dart';
import '../data/models/theme_search_query.dart';
import '../data/theme_repository.dart';

class ThemeSearchState {
  const ThemeSearchState({
    required this.query,
    required this.page,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final ThemeSearchQuery query;
  final SpringPage<EscapeTheme> page;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  ThemeSearchState copyWith({
    ThemeSearchQuery? query,
    SpringPage<EscapeTheme>? page,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
  }) =>
      ThemeSearchState(
        query: query ?? this.query,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class ThemeSearchController extends Notifier<ThemeSearchState> {
  @override
  ThemeSearchState build() {
    Future.microtask(_initialLoad);
    return ThemeSearchState(
      query: const ThemeSearchQuery(),
      page: SpringPage.empty$<EscapeTheme>(),
      isLoading: true,
    );
  }

  Future<void> _initialLoad() async {
    await _load(resetPage: true);
  }

  Future<void> _load({required bool resetPage}) async {
    final repo = ref.read(themeRepositoryProvider);
    try {
      final nextQuery = resetPage ? state.query.copyWith(page: 0) : state.query;
      if (resetPage) {
        state = state.copyWith(
          isLoading: true,
          query: nextQuery,
          clearError: true,
        );
      } else {
        state = state.copyWith(isLoadingMore: true);
      }
      final result = await repo.search(nextQuery);
      if (resetPage || nextQuery.page == 0) {
        state = state.copyWith(
          page: result,
          isLoading: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          page: SpringPage<EscapeTheme>(
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
      query: state.query.copyWith(page: state.page.number + 1),
    );
    await _load(resetPage: false);
  }

  void setSearch(String value) {
    state = state.copyWith(
      query: state.query.copyWith(search: value, page: 0),
    );
    _load(resetPage: true);
  }

  void setOnlyOpen(bool? value) {
    state = state.copyWith(
      query: state.query.copyWith(onlyOpen: value, page: 0),
    );
    _load(resetPage: true);
  }

  void applyQuery(ThemeSearchQuery next) {
    state = state.copyWith(query: next.copyWith(page: 0), clearError: true);
    _load(resetPage: true);
  }

  void setSort(String apiValue) {
    state = state.copyWith(
      query: state.query.copyWith(sort: apiValue, page: 0),
    );
    _load(resetPage: true);
  }
}

final themeSearchControllerProvider =
    NotifierProvider<ThemeSearchController, ThemeSearchState>(
  ThemeSearchController.new,
);
