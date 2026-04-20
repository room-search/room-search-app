import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';
import 'update_info.dart';

class UpdateService {
  UpdateService({Dio? dio, this.owner = 'room-search', this.repo = 'room-search-app'})
      : _dio = dio ?? Dio();

  final Dio _dio;
  final String owner;
  final String repo;

  String get _latestReleaseUrl =>
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version;

      final res = await _dio.getUri<Map<String, dynamic>>(
        Uri.parse(_latestReleaseUrl),
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final data = res.data;
      if (data == null) return null;

      final tag = (data['tag_name'] as String?) ?? '';
      final body = (data['body'] as String?) ?? '';
      final htmlUrl = (data['html_url'] as String?) ?? '';
      final assets = (data['assets'] as List?) ?? const [];
      String? apkUrl;
      for (final a in assets) {
        if (a is Map && a['name'] is String && (a['name'] as String).endsWith('.apk')) {
          apkUrl = a['browser_download_url'] as String?;
          break;
        }
      }

      if (tag.isEmpty || apkUrl == null) return null;

      return UpdateInfo(
        latestVersion: tag,
        currentVersion: currentVersion,
        apkUrl: apkUrl,
        releaseNotes: body,
        releaseUrl: htmlUrl,
      );
    } catch (e, st) {
      log.w('Update check failed: $e', stackTrace: st);
      return null;
    }
  }

  Future<File> downloadApk({
    required String url,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await getTemporaryDirectory();
    final fileName = Uri.parse(url).pathSegments.last;
    final path = '${dir.path}/$fileName';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _dio.download(
      url,
      path,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: Options(
        headers: {'Accept': 'application/octet-stream'},
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    return file;
  }
}
