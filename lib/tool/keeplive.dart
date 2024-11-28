import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ng169/tool/db.dart';
import 'package:ng169/tool/im.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/thredim.dart';
import 'package:permission_handler/permission_handler.dart';
import 'function.dart';
import 'global.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

//保活
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(Keeplive());
}

class Keeplive extends TaskHandler {
  //使用flutter_foreground_task保活
  static register() async {
    FlutterForegroundTask.initCommunicationPort();
  }

  static init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service ',
        channelDescription: lang('用于离线缓存功能；以及语言阅读功能；关闭则相应功能无法使用.'),
        onlyAlertOnce: true,
        showBadge: true, // 显示角标
        showWhen: true, // 显示通知
        enableVibration: true, // 震动
        // visibility: NotificationVisibility.VISIBILITY_PRIVATE // 通知的可见性
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true, // 开机自启动
        autoRunOnMyPackageReplaced: true, // 当应用程序被替换时，重新启动服务
        allowWakeLock: true, // 允许保持唤醒状态
        allowWifiLock: true, // 允许保持唤醒状态
      ),
    );
  }

  static Future<ServiceRequestResult> startService() async {
    await checkpower();
    if (await FlutterForegroundTask.isRunningService) {
      d("重启服务 ");
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: lang('书籍缓存中..'),
        notificationText: lang('点击返回APP'),
        notificationIcon: null,
        notificationButtons: [
          // NotificationButton(
          //   id: 'btn_previous',
          //   text: 'Previous',
          //   // androidIcon: Icons.skip_previous, // 设置按钮图标为上一首图标
          // ),
          // NotificationButton(
          //   id: 'btn_play_pause',
          //   text: 'Play/Pause',
          //   // androidIcon: Icons.play_circle_fill, // 设置按钮图标为播放图标
          // ),
          // NotificationButton(
          //   id: 'btn_next',
          //   text: 'Next',
          //   // androidIcon: Icons.skip_next, // 设置按钮图标为下一首图标
          // ),
        ],
        callback: startCallback,
      );
    }
  }

/**
   * 检查应用程序的权限，并在必要时请求这些权限。
   * 这个方法会检查通知权限、悬浮窗权限、忽略电池优化权限和精确闹钟权限。
   * 如果这些权限没有被授予，它会尝试请求这些权限。
   */
  static checkpower() async {
    // 检查权限
    NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    // 如果通知权限没有被授予.
    d(notificationPermission);
    if (notificationPermission == NotificationPermission.permanently_denied) {
      // 提示用户手动开启通知权限
      showDialog(
        context: g("context"),
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('需要通知权限'),
            content: Text('为了正常使用应用功能，请手动开启通知权限。'),
            actions: <Widget>[
              TextButton(
                child: Text('去设置'),
                onPressed: () {
                  // 引导用户到系统设置页面
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    } else if (notificationPermission != NotificationPermission.granted) {
      // 请求通知权限
      await FlutterForegroundTask.requestNotificationPermission();
      // 再次检查权限
      notificationPermission =
          await FlutterForegroundTask.checkNotificationPermission();
      // 如果用户拒绝了权限请求
      if (notificationPermission == NotificationPermission.denied) {
        // 提示用户手动开启通知权限
        showDialog(
          context: g("context"),
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('需要通知权限'),
              content: Text('为了正常使用应用功能，请开启通知权限。'),
              actions: <Widget>[
                TextButton(
                  child: Text('去设置'),
                  onPressed: () {
                    // 引导用户到系统设置页面
                    Navigator.of(context).pop();
                    FlutterForegroundTask.openSystemAlertWindowSettings();
                  },
                ),
              ],
            );
          },
        );
      }
    }
    // 如果是在 Android 平台
    if (Platform.isAndroid) {
      // 如果不能绘制悬浮窗
      // if (!await FlutterForegroundTask.canDrawOverlays) {
      //   // 提示需要 `android.permission.SYSTEM_ALERT_WINDOW` 权限
      //   await FlutterForegroundTask.openSystemAlertWindowSettings();
      // }

      // 如果没有忽略电池优化
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // 提示需要 `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` 权限
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
      // 如果不能设置精确闹钟
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      //   // 打开闹钟和提醒设置
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // }
    }
  }

  static Future<ServiceRequestResult> stopService() async {
    return FlutterForegroundTask.stopService();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // TODO: implement onDestroy
    print('onDestroy');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    //包活thredim;检测im islocate任务是否执行中；如果没有则执行；
    // bool isIslocateRunning = Thredim.isIslocateRunning;
    // d(Thredim.isIslocateRunning);
    // if (Thredim.isIslocateRunning == null) {
    //   // 如果 islocate 任务没有在运行，则启动它
    //   // Thredim.run("", () {});
    // }
    timeloop();
  }

//这里做一个循环检测保活
  @override
  void onTaskResumed(DateTime timestamp) {
    print('onTaskResumed');
  }

  static timeloop() {
    // 每60秒执行一次
    Timer.periodic(Duration(seconds: 60), (timer) {
      imcheck();
      // 在这里执行你想要执行的任务
      // 例如，你可以检查某个条件是否满足，如果满足则执行某个操作
    });
  }

  static imcheck() {
    d("检查im 连接状态");
    if (!Im.checksocklive()) {
      startim();
    }
  }

  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  static startim() {
    Thredim.run("", () {});
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    d('按下: $id');
    switch (id) {
      case 'btn_previous':
        startim();
        // 处理上一首按钮点击事件
        break;
      case 'btn_play_pause':
        // 处理播放/暂停按钮点击事件
        break;
      case 'btn_next':
        Keeplive.stopService();
        // startService();
        // 处理下一首按钮点击事件
        break;
    }
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('timestamp: ${timestamp.toString()}');
      }
    }
  }
}
