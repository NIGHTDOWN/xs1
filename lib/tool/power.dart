import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class Power {
  static Future<bool> requestPermissions() async {
    //添加需要开启的权限
    //  unknown,

    // /// Android: Calendar
    // /// iOS: Calendar (Events)
    // calendar,

    // /// Android: Camera
    // /// iOS: Photos (Camera Roll and Camera)
    // camera,

    // /// Android: Contacts
    // /// iOS: AddressBook
    // contacts,

    // /// Android: Fine and Coarse Location
    // /// iOS: CoreLocation (Always and WhenInUse)
    // location,

    // /// Android: Microphone
    // /// iOS: Microphone
    // microphone,

    // /// Android: Phone
    // /// iOS: Nothing
    // phone,

    // /// Android: Nothing
    // /// iOS: Photos
    // photos,

    // /// Android: Nothing
    // /// iOS: Reminders
    // reminders,

    // /// Android: Body Sensors
    // /// iOS: CoreMotion
    // sensors,

    // /// Android: Sms
    // /// iOS: Nothing
    // sms,

    // /// Android: External Storage
    // /// iOS: Nothing
    // storage,

    // /// Android: Microphone
    // /// iOS: Speech
    // speech,

    // /// Android: Fine and Coarse Location
    // /// iOS: CoreLocation - Always
    // locationAlways,

    // /// Android: Fine and Coarse Location
    // /// iOS: CoreLocation - WhenInUse
    // locationWhenInUse,

    // /// Android: None
    // /// iOS: MPMediaLibrary
    // mediaLibrary
    //androidX需要实例化对象，低版本的是静态方法
    // PermissionHandler obj = new PermissionHandler();
    // // PermissionHandler obj = PermissionHandlerPlatform.get;
    // Map<PermissionGroup, PermissionStatus> permissions =
    //     await obj.requestPermissions([
    //   PermissionGroup.storage,
    //   PermissionGroup.location,
    // ]);
Map<Permission, PermissionStatus> permissions = await [
  Permission.location,
  Permission.storage,
].request();









    List<bool> results = permissions.values.toList().map((status) {
      //var PermissionStatus;
      return status == PermissionStatus.granted;
    }).toList();

    return !results.contains(false);
  }
}

class AppUtils {
  static Future<void> popApp() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static Future checkUpgrade() async {
    try {
      final bool result =
          await ApplicationMethodChannel.main.invokeMethod('checkUpgrade');
      print('result=$result');
    } on PlatformException {
      print('faied');
    }
  }
}

class ApplicationMethodChannel {
  static MethodChannel main = MethodChannel('main');
}
