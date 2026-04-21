import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/share/kakao_share_service.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/favorite_heart_button.dart';
import '../../../shared/widgets/theme_poster_card.dart';
import '../../favorites/data/favorite_repository.dart';
import '../application/cafe_detail_controller.dart';
import '../data/models/cafe.dart';
import 'widgets/cafe_mini_map.dart';

class CafeDetailPage extends ConsumerWidget {
  const CafeDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cafeDetailProvider(id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('카페'),
        actions: [
          async.maybeWhen(
            data: (cafe) => IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: '공유',
              onPressed: () =>
                  ref.read(kakaoShareServiceProvider).shareCafe(cafe),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: '카페 정보를 불러오지 못했어요',
          onRetry: () => ref.invalidate(cafeDetailProvider(id)),
        ),
        data: (cafe) => _CafeBody(cafe: cafe),
      ),
    );
  }
}

class _CafeBody extends ConsumerWidget {
  const _CafeBody({required this.cafe});
  final EscapeCafe cafe;

  Future<void> _callPhone() async {
    if (cafe.phoneNo.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cafe.phoneNo);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openHomepage() async {
    if (cafe.homepage.isEmpty) return;
    final uri = Uri.tryParse(cafe.homepage);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final repo = ref.watch(favoriteRepositoryProvider);
    ref.watch(cafeFavoritesChangedProvider);
    final isFav = repo.isCafeFavorite(cafe.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(cafe.name, style: text.headlineMedium)
                    .animate()
                    .fadeIn(duration: 260.ms)
                    .slideY(begin: 0.1, end: 0, duration: 260.ms),
              ),
              FavoriteHeartButton(
                isFavorite: isFav,
                onTap: () => repo.toggleCafe(cafe),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${cafe.location} · ${cafe.area}',
            style: text.labelMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        if (cafe.address.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(cafe.address, style: text.bodyMedium),
          ),
        ],
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CafeMiniMap(cafe: cafe)
              .animate()
              .fadeIn(duration: 300.ms, delay: 120.ms),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (cafe.phoneNo.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callPhone,
                    icon: const Icon(Icons.phone_rounded),
                    label: Text(cafe.phoneNo),
                  ),
                ),
              if (cafe.phoneNo.isNotEmpty && cafe.homepage.isNotEmpty)
                const SizedBox(width: 10),
              if (cafe.homepage.isNotEmpty)
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _openHomepage,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('홈페이지'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('테마 ${cafe.themes.length}개', style: text.titleLarge),
        ),
        const SizedBox(height: 12),
        if (cafe.themes.isEmpty)
          const EmptyView(
            title: '등록된 테마가 없어요',
            icon: Icons.casino_outlined,
          )
        else
          SizedBox(
            height: 320,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: cafe.themes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final t = cafe.themes[i];
                return ThemePosterCard(
                  theme: t,
                  onTap: () => ctx.push(
                    '/themes/${t.refId}',
                    extra: t.photoUrl,
                  ),
                )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 260.ms)
                    .slideX(
                      begin: 0.15,
                      end: 0,
                      delay: (60 * i).ms,
                      duration: 260.ms,
                    );
              },
            ),
          ),
      ],
    );
  }
}
