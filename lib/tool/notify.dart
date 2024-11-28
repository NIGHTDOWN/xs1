//通知栏
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ng169/model/notifyfun.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';

class Notify {
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static var context;
  static var notifyid = 0;
  //设置上下文
  static setcontext(context) {
    Notify.context = context;
  }

  //初始化
  static init(String icon) async {
    Notify.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = new AndroidInitializationSettings(icon);
    // var initializationSettingsIOS = new IOSInitializationSettings(
    //     onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
      android: initializationSettingsAndroid,
      //  iOS: initializationSettingsIOS
    );
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
      onDidReceiveBackgroundNotificationResponse: onSelectNotification,
    );
  }

  // static Future<dynamic> onSelectNotification(String? payload) async {
  //   // 确保在这里 context 是可访问的，或者以参数形式传递给 Notifyfunction
  //   // 你的逻辑代码
  //   Notifyfunction(context, payload ?? ''); // 这里需要一个正确的 context 变量
  //   // 如果 payload 是 null，这里使用 ?? 操作符提供一个空字符串作为默认值
  // }
  //点击的监听
  static onSelectNotification(NotificationResponse payload) async {
//回调函数全在/model/notyfyfunction下
    // var call = 'notifyfunction_' + payload as Function;
    // d(call);
    // call.call(context);
    new Notifyfunction(context, payload);
    //payload 可作为通知的一个标记，区分点击的通知。
  }

//收到通知所作的处理的方法
  static Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

    await showDialog(
      context: Notify.context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(lang('Ok')),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) {
                  return Container();
                }
                    //builder: (context) => SecondScreen(payload),
                    ),
              );
            },
          )
        ],
      ),
    );
  }

//删除单个通知

//删除所有通知
  // ignore: unused_element
  static Future _cancelAllNotifications() async {
    await Notify.flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future showNotification(String title, String content, String callback,
      {String data = ""}) async {
    Notify.init('app_icon');
    setcache(callback, data, "-1"); //参数通过缓存传入
    //安卓的通知配置，必填参数是渠道id, 名称, 和描述, 可选填通知的图标，重要度等等。
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'LoveMsg', 'LoveMsg',
        // 'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max,
        priority: Priority.high);
    //IOS的通知配置
    // var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      // iOS: iOSPlatformChannelSpecifics
    );
    //显示通知，其中 0 代表通知的 id，用于区分通知。

    await Notify.flutterLocalNotificationsPlugin.show(
        Notify.notifyid++, title, content, platformChannelSpecifics,
        payload: callback);
  }
}
