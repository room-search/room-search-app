import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/utils/logger.dart';

const String roomLeaveAction = 'leave';

@pragma('vm:entry-point')
void roomForegroundStartCallback() {
  FlutterForegroundTask.setTaskHandler(_RoomTaskHandler());
}

class _RoomTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {
    FlutterForegroundTask.sendDataToMain({'action': id});
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}

class RoomForegroundService {
  RoomForegroundService._();

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'room_search_room',
        channelName: '방서치 방 상태',
        channelDescription: '방 접속 상태를 표시합니다.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    final notif = await FlutterForegroundTask.checkNotificationPermission();
    if (notif != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<void> start({
    required String title,
    required String text,
  }) async {
    init();
    try {
      await _requestPermissions();
    } catch (e, st) {
      log.w('notification permission request failed: $e', stackTrace: st);
    }
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: text,
        );
        return;
      }
      await FlutterForegroundTask.startService(
        serviceTypes: const [ForegroundServiceTypes.connectedDevice],
        notificationTitle: title,
        notificationText: text,
        notificationButtons: const [
          NotificationButton(id: roomLeaveAction, text: '나가기'),
        ],
        callback: roomForegroundStartCallback,
      );
    } catch (e, st) {
      log.w('foreground service start failed: $e', stackTrace: st);
    }
  }

  static Future<void> update({
    required String title,
    required String text,
  }) async {
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (e, st) {
      log.w('foreground service update failed: $e', stackTrace: st);
    }
  }

  static Future<void> stop() async {
    try {
      if (!await FlutterForegroundTask.isRunningService) return;
      await FlutterForegroundTask.stopService();
    } catch (e, st) {
      log.w('foreground service stop failed: $e', stackTrace: st);
    }
  }
}
