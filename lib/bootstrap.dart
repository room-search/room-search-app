import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';
import 'features/favorites/data/favorite_repository.dart';

Future<void> bootstrap() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      log.e('Flutter error', error: details.exception, stackTrace: details.stack);
    };

    await Hive.initFlutter();
    final favoriteRepo = await FavoriteRepository.open();

    if (Env.isKakaoShareEnabled) {
      KakaoSdk.init(nativeAppKey: Env.kakaoNativeAppKey);
    } else {
      log.w('Kakao share disabled: KAKAO_NATIVE_APP_KEY not provided');
    }

    try {
      await FlutterNaverMap().init(
        clientId: Env.naverMapNcpKeyId,
        onAuthFailed: (ex) {
          log.w('NaverMap auth failed: $ex');
        },
      );
    } catch (e) {
      log.w('NaverMap init skipped: $e');
    }

    runApp(
      ProviderScope(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
        ],
        child: const RoomSearchApp(),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) {
      log.e('Zone error', error: error, stackTrace: stack);
    }
  });
}
