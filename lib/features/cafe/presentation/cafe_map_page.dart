import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/cafe_bounds_controller.dart';
import '../data/models/cafe.dart';

class CafeMapPage extends ConsumerStatefulWidget {
  const CafeMapPage({super.key});

  @override
  ConsumerState<CafeMapPage> createState() => _CafeMapPageState();
}

class _CafeMapPageState extends ConsumerState<CafeMapPage> {
  NaverMapController? _map;
  bool _showRefresh = false;
  NCameraPosition? _pendingCamera;

  static const _seoul = NLatLng(37.5665, 126.9780);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cafeBoundsControllerProvider);

    ref.listen<CafeBoundsState>(cafeBoundsControllerProvider, (prev, next) {
      if (next.cafes != prev?.cafes) {
        _renderMarkers(next.cafes);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: _seoul, zoom: 12),
              locationButtonEnable: true,
              consumeSymbolTapEvents: false,
            ),
            onMapReady: (ctrl) async {
              _map = ctrl;
              await _refreshForCurrentBounds();
            },
            onCameraChange: (reason, animated) {
              if (!mounted) return;
              setState(() => _showRefresh = true);
            },
            onCameraIdle: () async {
              if (!mounted || _map == null) return;
              _pendingCamera = await _map!.getCameraPosition();
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _GlassIcon(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(6),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_showRefresh)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 0,
              right: 0,
              child: Center(
                child: FilledButton.icon(
                  onPressed: _refreshForCurrentBounds,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('이 지역 재검색'),
                )
                    .animate(key: ValueKey('${_pendingCamera?.target.latitude}'))
                    .fadeIn(duration: 220.ms)
                    .slideY(begin: -0.5, end: 0, duration: 260.ms),
              ),
            ),
          if (state.cafes.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CafePeek(cafes: state.cafes),
            ),
        ],
      ),
    );
  }

  Future<void> _refreshForCurrentBounds() async {
    if (_map == null) return;
    final region = await _map!.getContentRegion();
    double minLat = region.first.latitude, maxLat = region.first.latitude;
    double minLng = region.first.longitude, maxLng = region.first.longitude;
    for (final p in region) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    setState(() => _showRefresh = false);
    await ref.read(cafeBoundsControllerProvider.notifier).loadForBounds(
          BoundsQuery(
            minLat: minLat,
            maxLat: maxLat,
            minLng: minLng,
            maxLng: maxLng,
          ),
        );
  }

  Future<void> _renderMarkers(List<EscapeCafe> cafes) async {
    if (_map == null) return;
    await _map!.clearOverlays();
    for (final c in cafes) {
      if (c.lat == 0 && c.lng == 0) continue;
      final marker = NMarker(
        id: c.id,
        position: NLatLng(c.lat, c.lng),
        caption: NOverlayCaption(text: c.name),
      );
      marker.setOnTapListener((overlay) {
        if (mounted) context.push('/cafe-detail/${c.id}');
      });
      await _map!.addOverlay(marker);
    }
  }
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon),
        ),
      ),
    );
  }
}

class _CafePeek extends StatelessWidget {
  const _CafePeek({required this.cafes});
  final List<EscapeCafe> cafes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemBuilder: (ctx, i) {
          final c = cafes[i];
          return _PeekCard(cafe: c);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: cafes.length,
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _PeekCard extends StatelessWidget {
  const _PeekCard({required this.cafe});
  final EscapeCafe cafe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/cafe-detail/${cafe.id}'),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cafe.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${cafe.location} · ${cafe.area}',
                style: text.labelMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.casino_rounded, size: 14, color: scheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '테마 ${cafe.themes.length}',
                    style: text.labelMedium,
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: scheme.onSurface.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
