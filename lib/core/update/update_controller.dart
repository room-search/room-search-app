import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';
import 'update_info.dart';
import 'update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

enum UpdatePhase { idle, checking, available, downloading, installing, dismissed, error }

class UpdateState {
  const UpdateState({
    this.phase = UpdatePhase.idle,
    this.info,
    this.received = 0,
    this.total = 0,
    this.error,
  });

  final UpdatePhase phase;
  final UpdateInfo? info;
  final int received;
  final int total;
  final String? error;

  double get progress => total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;

  UpdateState copyWith({
    UpdatePhase? phase,
    UpdateInfo? info,
    int? received,
    int? total,
    String? error,
  }) {
    return UpdateState(
      phase: phase ?? this.phase,
      info: info ?? this.info,
      received: received ?? this.received,
      total: total ?? this.total,
      error: error,
    );
  }
}

class UpdateController extends StateNotifier<UpdateState> {
  UpdateController(this._service) : super(const UpdateState());

  final UpdateService _service;
  CancelToken? _cancelToken;

  Future<void> check() async {
    if (!Platform.isAndroid) return;
    if (state.phase == UpdatePhase.checking || state.phase == UpdatePhase.downloading) {
      return;
    }
    state = state.copyWith(phase: UpdatePhase.checking, error: null);
    final info = await _service.checkForUpdate();
    if (info == null) {
      state = const UpdateState();
      return;
    }
    if (info.hasUpdate) {
      state = UpdateState(phase: UpdatePhase.available, info: info);
    } else {
      state = const UpdateState();
    }
  }

  void dismiss() {
    state = state.copyWith(phase: UpdatePhase.dismissed);
  }

  Future<void> downloadAndInstall() async {
    final info = state.info;
    if (info == null) return;
    _cancelToken = CancelToken();
    state = state.copyWith(phase: UpdatePhase.downloading, received: 0, total: 0, error: null);

    try {
      final file = await _service.downloadApk(
        url: info.apkUrl,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          state = state.copyWith(received: received, total: total);
        },
      );

      state = state.copyWith(phase: UpdatePhase.installing);
      await _ensureInstallPermission();
      final result = await OpenFilex.open(file.path, type: 'application/vnd.android.package-archive');
      log.i('APK install launch: ${result.type} ${result.message}');
    } catch (e, st) {
      if (e is DioException && CancelToken.isCancel(e)) {
        state = UpdateState(phase: UpdatePhase.available, info: info);
        return;
      }
      log.e('Update download/install failed', error: e, stackTrace: st);
      state = state.copyWith(phase: UpdatePhase.error, error: e.toString());
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('user-cancelled');
  }

  Future<void> _ensureInstallPermission() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      await Permission.requestInstallPackages.request();
    }
  }
}

final updateControllerProvider =
    StateNotifierProvider<UpdateController, UpdateState>((ref) {
  return UpdateController(ref.watch(updateServiceProvider));
});
