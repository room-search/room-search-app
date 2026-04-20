import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/cafe_search_controller.dart';
import '../data/cafe_repository.dart';
import 'widgets/cafe_card.dart';

class CafeSearchPage extends ConsumerStatefulWidget {
  const CafeSearchPage({super.key});

  @override
  ConsumerState<CafeSearchPage> createState() => _CafeSearchPageState();
}

class _CafeSearchPageState extends ConsumerState<CafeSearchPage> {
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 350));

  @override
  void initState() {
    super.initState();
    _scrollCtl.addListener(() {
      if (_scrollCtl.position.pixels >
          _scrollCtl.position.maxScrollExtent - 200) {
        ref.read(cafeSearchControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _scrollCtl.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cafeSearchControllerProvider);
    final locationsAsync = ref.watch(cafeLocationsProvider);
    final ctl = ref.read(cafeSearchControllerProvider.notifier);

    final areas = locationsAsync.maybeWhen(
      data: (list) => <String>{...list.map((e) => e.area)}.toList()..sort(),
      orElse: () => <String>[],
    );
    final locations = locationsAsync.maybeWhen(
      data: (list) => list
          .where((e) => state.params.area == null || e.area == state.params.area)
          .map((e) => e.location)
          .toSet()
          .toList()
        ..sort(),
      orElse: () => <String>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('카페'),
        actions: [
          IconButton(
            tooltip: '지도로 보기',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchCtl,
              decoration: InputDecoration(
                hintText: '카페명/지역 검색',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.params.search?.isNotEmpty == true
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtl.clear();
                          ctl.setSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => _debouncer(() => ctl.setSearch(v)),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('영업중'),
                  selected: state.params.onlyOpen == true,
                  onSelected: (v) => ctl.setOnlyOpen(v ? true : null),
                ),
                const SizedBox(width: 8),
                _DropdownChip(
                  label: '지역',
                  value: state.params.area,
                  options: areas,
                  onChanged: ctl.setArea,
                ),
                const SizedBox(width: 8),
                _DropdownChip(
                  label: '구역',
                  value: state.params.location,
                  options: locations,
                  onChanged: ctl.setLocation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(CafeSearchState state) {
    if (state.error != null && state.page.content.isEmpty) {
      return ErrorView(
        message: '카페를 불러오지 못했어요',
        onRetry: () => ref.read(cafeSearchControllerProvider.notifier).refresh(),
      );
    }
    if (state.isLoading && state.page.content.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.page.empty && !state.isLoading) {
      return const EmptyView(
        title: '검색 결과가 없어요',
        subtitle: '지역/검색어를 바꿔 보세요.',
        icon: Icons.storefront_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(cafeSearchControllerProvider.notifier).refresh(),
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
            final c = state.page.content[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 420),
              child: SlideAnimation(
                verticalOffset: 20,
                child: FadeInAnimation(
                  child: CafeCard(
                    cafe: c,
                    onTap: () => context.push('/cafes/${c.id}'),
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

class _DropdownChip extends StatelessWidget {
  const _DropdownChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = value != null;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: options.isEmpty
          ? null
          : () async {
              final picked = await showModalBottomSheet<String?>(
                context: context,
                showDragHandle: true,
                builder: (_) => ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text('전체 $label'),
                      trailing: value == null ? const Icon(Icons.check) : null,
                      onTap: () => Navigator.pop(context, null),
                    ),
                    const Divider(height: 1),
                    for (final o in options)
                      ListTile(
                        title: Text(o),
                        trailing: o == value ? const Icon(Icons.check) : null,
                        onTap: () => Navigator.pop(context, o),
                      ),
                  ],
                ),
              );
              if (picked == null && value == null) return;
              onChanged(picked);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? scheme.primary.withValues(alpha: 0.12) : null,
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: [
            Text(
              value ?? label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? scheme.primary : null,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
            ),
            const SizedBox(width: 4),
            Icon(
              selected ? Icons.close_rounded : Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: selected ? scheme.primary : scheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}
