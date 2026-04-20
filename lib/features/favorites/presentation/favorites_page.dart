import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_view.dart';
import '../data/favorite_repository.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Subscribe to favorite change streams so both tabs live-refresh.
    ref.watch(themeFavoritesChangedProvider);
    ref.watch(cafeFavoritesChangedProvider);
    final repo = ref.watch(favoriteRepositoryProvider);
    final themes = repo.listThemes();
    final cafes = repo.listCafes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: '테마 ${themes.length}'),
            Tab(text: '카페 ${cafes.length}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ThemeList(themes: themes),
          _CafeList(cafes: cafes),
        ],
      ),
    );
  }
}

class _ThemeList extends ConsumerWidget {
  const _ThemeList({required this.themes});
  final List<Map<String, dynamic>> themes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (themes.isEmpty) {
      return const EmptyView(
        title: '즐겨찾기한 테마가 없어요',
        subtitle: '마음에 드는 테마의 하트를 눌러 저장해 보세요.',
        icon: Icons.favorite_border_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: themes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final t = themes[i];
        final refId = t['refId'] as int? ?? 0;
        final name = t['name'] as String? ?? '';
        final photoUrl = t['photoUrl'] as String? ?? '';
        final playtime = t['playtime'] as int? ?? 0;
        final price = t['price'] as int? ?? 0;
        return _FavoriteThemeTile(
          refId: refId,
          name: name,
          photoUrl: photoUrl,
          playtime: playtime,
          price: price,
          onTap: () =>
              ctx.push('/themes/$refId', extra: photoUrl),
          onRemove: () {},
        )
            .animate()
            .fadeIn(duration: 260.ms, delay: (i * 40).ms)
            .slideX(begin: 0.05, end: 0, duration: 260.ms, delay: (i * 40).ms);
      },
    );
  }
}

class _FavoriteThemeTile extends ConsumerWidget {
  const _FavoriteThemeTile({
    required this.refId,
    required this.name,
    required this.photoUrl,
    required this.playtime,
    required this.price,
    required this.onTap,
    required this.onRemove,
  });

  final int refId;
  final String name;
  final String photoUrl;
  final int playtime;
  final int price;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl.isEmpty
                    ? Icon(Icons.casino_rounded, color: scheme.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${formatPlaytime(playtime)} · ${formatPriceWon(price)}',
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded),
                color: scheme.error,
                onPressed: () => ref
                    .read(favoriteRepositoryProvider)
                    .removeTheme(refId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CafeList extends ConsumerWidget {
  const _CafeList({required this.cafes});
  final List<Map<String, dynamic>> cafes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cafes.isEmpty) {
      return const EmptyView(
        title: '즐겨찾기한 카페가 없어요',
        subtitle: '관심 있는 카페의 하트를 눌러 저장해 보세요.',
        icon: Icons.favorite_border_rounded,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: cafes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final c = cafes[i];
        final id = c['id'] as String? ?? '';
        final name = c['name'] as String? ?? '';
        final area = c['area'] as String? ?? '';
        final location = c['location'] as String? ?? '';
        final themeCount = c['themeCount'] as int? ?? 0;
        return _FavoriteCafeTile(
          id: id,
          name: name,
          area: area,
          location: location,
          themeCount: themeCount,
          onTap: () => ctx.push('/cafes/$id'),
        )
            .animate()
            .fadeIn(duration: 260.ms, delay: (i * 40).ms)
            .slideX(begin: 0.05, end: 0, duration: 260.ms, delay: (i * 40).ms);
      },
    );
  }
}

class _FavoriteCafeTile extends ConsumerWidget {
  const _FavoriteCafeTile({
    required this.id,
    required this.name,
    required this.area,
    required this.location,
    required this.themeCount,
    required this.onTap,
  });

  final String id;
  final String name;
  final String area;
  final String location;
  final int themeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.storefront_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '$location · $area · 테마 $themeCount',
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded),
                color: scheme.error,
                onPressed: () =>
                    ref.read(favoriteRepositoryProvider).removeCafe(id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
