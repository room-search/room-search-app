import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/theme_search_controller.dart';
import '../data/models/theme_search_query.dart';
import 'widgets/sort_option.dart';
import 'widgets/theme_card.dart';
import 'widgets/theme_filter_sheet.dart';

class ThemeSearchPage extends ConsumerStatefulWidget {
  const ThemeSearchPage({super.key});

  @override
  ConsumerState<ThemeSearchPage> createState() => _ThemeSearchPageState();
}

class _ThemeSearchPageState extends ConsumerState<ThemeSearchPage> {
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    _scrollCtl.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _scrollCtl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scrollCtl.position.pixels > _scrollCtl.position.maxScrollExtent - 200) {
      ref.read(themeSearchControllerProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debouncer(() {
      ref.read(themeSearchControllerProvider.notifier).setSearch(value);
    });
  }

  Future<void> _openFilter() async {
    final cur = ref.read(themeSearchControllerProvider).query;
    final next = await showThemeFilterSheet(context, initial: cur);
    if (next != null && mounted) {
      ref.read(themeSearchControllerProvider.notifier).applyQuery(next);
    }
  }

  Future<void> _openSortSheet() async {
    final current = ref.read(themeSearchControllerProvider).query.sort;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text('정렬', style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final o in ThemeSortOption.all)
              ListTile(
                title: Text(o.label),
                trailing: o.apiValue == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, o.apiValue),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      ref.read(themeSearchControllerProvider.notifier).setSort(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(themeSearchControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final activeFilters = _activeFilterCount(state.query);
    final sortOption = ThemeSortOption.findByApi(state.query.sort) ??
        ThemeSortOption.defaultSort;
    final highlightKey = sortOption.scoreKey;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              'assets/images/app_icon_transparent.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('방서치'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '필터',
            onPressed: _openFilter,
            icon: Badge(
              label: activeFilters > 0 ? Text('$activeFilters') : null,
              isLabelVisible: activeFilters > 0,
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '테마명/카페 검색',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.query.search != null && state.query.search!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtl.clear();
                          ref.read(themeSearchControllerProvider.notifier).setSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.page.totalElements > 0
                        ? '전체 ${state.page.totalElements}개'
                        : '',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openSortSheet,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(sortOption.label),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(state, scheme, highlightKey),
          ),
        ],
      ),
    );
  }

  int _activeFilterCount(ThemeSearchQuery query) {
    int c = 0;
    if (query.startDifficulty != null || query.endDifficulty != null) c++;
    if (query.startFear != null || query.endFear != null) c++;
    if (query.startActivity != null || query.endActivity != null) c++;
    if (query.startStory != null || query.endStory != null) c++;
    if (query.startProblem != null || query.endProblem != null) c++;
    if (query.startPlaytime != null || query.endPlaytime != null) c++;
    if (query.startPrice != null || query.endPrice != null) c++;
    if (query.onlyOpen == true) c++;
    if (query.areas.isNotEmpty || query.locations.isNotEmpty) c++;
    return c;
  }

  Widget _buildBody(ThemeSearchState state, ColorScheme scheme, String? highlightKey) {
    if (state.error != null && state.page.content.isEmpty) {
      return ErrorView(
        message: '테마를 불러오지 못했어요\n${state.error}',
        onRetry: () => ref.read(themeSearchControllerProvider.notifier).refresh(),
      );
    }
    if (state.isLoading && state.page.content.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.page.empty && !state.isLoading) {
      return const EmptyView(
        title: '검색 결과가 없어요',
        subtitle: '필터를 완화하거나 다른 검색어를 시도해 보세요.',
        icon: Icons.search_off_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(themeSearchControllerProvider.notifier).refresh(),
      child: AnimationLimiter(
        child: ListView.separated(
          controller: _scrollCtl,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: state.page.content.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            if (i >= state.page.content.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final t = state.page.content[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 420),
              child: SlideAnimation(
                verticalOffset: 20,
                child: FadeInAnimation(
                  child: ThemeCard(
                    theme: t,
                    highlightScoreKey: highlightKey,
                    onTap: () =>
                        context.push('/themes/${t.refId}', extra: t.photoUrl),
                  ),
                ),
              ),
            );
          },
        ).animate().fadeIn(duration: 180.ms),
      ),
    );
  }
}
