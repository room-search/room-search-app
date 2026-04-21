import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/cafe/data/models/cafe.dart';
import '../../features/theme/data/models/theme.dart';
import '../config/env.dart';
import '../utils/logger.dart';

final kakaoShareServiceProvider = Provider<KakaoShareService>((ref) {
  return KakaoShareService();
});

class KakaoShareService {
  bool get isEnabled => Env.isKakaoShareEnabled;

  Future<void> shareTheme(EscapeTheme theme) async {
    final webUrl = '${Env.landingBaseUrl}/themes/${theme.refId}';
    final params = {'target': 'theme', 'id': '${theme.refId}'};
    final template = FeedTemplate(
      content: Content(
        title: theme.name,
        description: theme.description.isEmpty ? '방서치에서 보기' : theme.description,
        imageUrl: Uri.parse(theme.photoUrl),
        link: Link(
          webUrl: Uri.parse(webUrl),
          mobileWebUrl: Uri.parse(webUrl),
          androidExecutionParams: params,
          iosExecutionParams: params,
        ),
      ),
      buttons: [
        Button(
          title: '방서치에서 보기',
          link: Link(
            webUrl: Uri.parse(webUrl),
            mobileWebUrl: Uri.parse(webUrl),
            androidExecutionParams: params,
            iosExecutionParams: params,
          ),
        ),
      ],
    );
    await _send(template, fallbackWebUrl: webUrl);
  }

  Future<void> shareCafe(EscapeCafe cafe) async {
    final webUrl = '${Env.landingBaseUrl}/cafes/${cafe.id}';
    final params = {'target': 'cafe', 'id': cafe.id};
    final poster = cafe.themes.isNotEmpty ? cafe.themes.first.photoUrl : '';
    final imageUrl = poster.isEmpty
        ? '${Env.landingBaseUrl}/og/cafe-default.png'
        : poster;
    final template = FeedTemplate(
      content: Content(
        title: cafe.name,
        description: '${cafe.location} · 테마 ${cafe.themes.length}개',
        imageUrl: Uri.parse(imageUrl),
        link: Link(
          webUrl: Uri.parse(webUrl),
          mobileWebUrl: Uri.parse(webUrl),
          androidExecutionParams: params,
          iosExecutionParams: params,
        ),
      ),
      buttons: [
        Button(
          title: '방서치에서 보기',
          link: Link(
            webUrl: Uri.parse(webUrl),
            mobileWebUrl: Uri.parse(webUrl),
            androidExecutionParams: params,
            iosExecutionParams: params,
          ),
        ),
      ],
    );
    await _send(template, fallbackWebUrl: webUrl);
  }

  Future<void> _send(
    FeedTemplate template, {
    required String fallbackWebUrl,
  }) async {
    if (!isEnabled) {
      await _openWeb(fallbackWebUrl);
      return;
    }
    try {
      final installed = await ShareClient.instance.isKakaoTalkSharingAvailable();
      if (installed) {
        final uri = await ShareClient.instance.shareDefault(template: template);
        await ShareClient.instance.launchKakaoTalk(uri);
      } else {
        final uri = await WebSharerClient.instance.makeDefaultUrl(
          template: template,
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e, st) {
      log.w('Kakao share failed: $e', stackTrace: st);
      await _openWeb(fallbackWebUrl);
    }
  }

  Future<void> _openWeb(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
