import 'package:flutter/services.dart';
import 'package:ng169/tool/function.dart';
import 'package:permission_handler/permission_handler.dart';

class Power {
  static Future<bool> requestPermissions() async {
    //添加需要开启的权限

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

  static Future<bool> getSdcardpower() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      return true;
      // 权限已授予，可以访问外部存储
    } else {
      return false;
      // 权限被拒绝，提示用户
    }
  }
}
