import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../data/models/cafe.dart';

class CafeMiniMap extends StatelessWidget {
  const CafeMiniMap({super.key, required this.cafe, this.height = 180});

  final EscapeCafe cafe;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (cafe.lat == 0 && cafe.lng == 0) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '위치 정보 없음',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
      );
    }
    final position = NLatLng(cafe.lat, cafe.lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(target: position, zoom: 15),
            scrollGesturesEnable: false,
            zoomGesturesEnable: false,
            rotationGesturesEnable: false,
            tiltGesturesEnable: false,
            logoClickEnable: false,
            scaleBarEnable: false,
            indoorEnable: false,
          ),
          onMapReady: (ctrl) async {
            final marker = NMarker(
              id: cafe.id,
              position: position,
              caption: NOverlayCaption(text: cafe.name),
            );
            await ctrl.addOverlay(marker);
          },
        ),
      ),
    );
  }
}
