import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/env.dart';
import '../utils/logger.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
});

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> start(GoRouter router) async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(router, initial);
    } catch (e) {
      log.w('DeepLink initial link read failed: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handle(router, uri),
      onError: (Object e) => log.w('DeepLink stream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void _handle(GoRouter router, Uri uri) {
    final isOurScheme = uri.scheme == Env.appScheme;
    final isKakaoScheme =
        Env.isKakaoShareEnabled &&
        uri.scheme == 'kakao${Env.kakaoNativeAppKey}';
    if (!isOurScheme && !isKakaoScheme) return;
    final route = _resolve(uri);
    if (route != null) {
      router.push(route);
    }
  }

  String? _resolve(Uri uri) {
    // Path form: roomsearch://themes/123
    if (uri.host.isNotEmpty && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      switch (uri.host) {
        case 'themes':
          return '/themes/$id';
        case 'cafes':
          return '/cafes/$id';
      }
    }
    // Query form from Kakao executionParams: roomsearch://?target=theme&id=123
    final target = uri.queryParameters['target'];
    final id = uri.queryParameters['id'];
    if (target != null && id != null && id.isNotEmpty) {
      if (target == 'theme') return '/themes/$id';
      if (target == 'cafe') return '/cafes/$id';
    }
    return null;
  }
}
