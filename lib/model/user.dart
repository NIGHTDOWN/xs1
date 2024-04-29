import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:ng169/conf/conf.dart';
import 'package:ng169/pay/AdBridge.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/incode.dart';

class User {
  static String index = 'user';

  static get() {
    return getcache(index, false);
  }

  static int getuid() {
    var user = get();

    if (isnull(user)) {
      var id = user['id'] ?? 0;
      if (id is String) {
        return int.parse(id);
      } else {
        return id;
      }
    } else {
      return 0;
    }
  }

  static gettestinfo() async {
    //把调试信息传送服务器
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var devicesinfo;
    var data;
    String wifi = await getwifi();
    if (Platform.isAndroid) {
      //这里改写了插件，新增一个 androidjson方法
      devicesinfo = await deviceInfo.androidInfo;
      data = [
        devicesinfo.version.codename,
        devicesinfo.version.sdkInt,
        devicesinfo.version.incremental,
        devicesinfo.fingerprint,
        devicesinfo.hardware,
        devicesinfo.host,
        devicesinfo.supportedAbis.toString(),
        devicesinfo.isPhysicalDevice,
      ];
    }
    if (Platform.isIOS) {
      devicesinfo = await deviceInfo.iosInfo;
      data = [
        devicesinfo.name,
        devicesinfo.systemName,
        devicesinfo.systemVersion,
        devicesinfo.model,
        devicesinfo.localizedModel,
        devicesinfo.identifierForVendor,
        devicesinfo.isPhysicalDevice,
        devicesinfo.utsname,
      ];
    }
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    ;
    //  d(JsonMapper().toJson(times));
    String netrate = await AdBridge.call("getnet");
    times.add(netrate);
    var appstmp = [];
    data.add({'wifi': wifi});
    data.add({'qd': downqd});
    for (var app in apps) {
      appstmp.add({app.appName: app.packageName});
    }
    var user = gethead();

    String key;
    if (!isnull(user, 'token')) {
      key = 'lookstory';
    } else {
      key = user['token'];
    }

    var datatmp = {
      'requesttime': json.encode(times),
      'devicesinfo': json.encode(data),
      'apps': json.encode(appstmp),
      'utime': gettime(),
    };

    String testinfo = Incode(json.encode(datatmp), key).encode();
    // var datatmps = Incode(testinfo, key).decode();
    // d(datatmps);
    return testinfo;
  }

  static set(user) {
    setcache(index, user, '-1', false);
    //刷新书架
    eventBus.emit('rfrack');
    //刷新用户
  }

  static bindinvite(String pid) async {
    if (isnull(pid)) {
      if (pid == User.getuid().toString()) {
        return false;
      }
      var data = await http('task/edit_invite', {'inviteid': pid}, gethead());
      var data2 = getdata(g('context'), data!);
      if (isnull(data2)) {
        //更新用户界面
        var user = User.get();
        user['invite_id'] = pid;
        //更新用户界面
        User.set(user);
        // reflash();
        // pop(context);
        return true;
      }
    }
    return false;
  }

  static bool islogin() {
    var user = get();
    if (isnull(user)) return true;
    return false;
  }

  static clear() {
    setcache(index, '', '0');
    g('cache').del(index);
    eventBus.emit('rfrack');
  }

  static double getcoin() {
    var user = get();
    if (isnull(user, 'remainder')) {
      if (user['remainder'] is int) {
        return double.parse(user['remainder'].toString());
      }
      if (user['remainder'] is double) {
        return user['remainder'];
      }
      return double.parse(user['remainder']);
    }
    return 0.0;
  }

  // //增减
  // static changecoin(coin) {
  //   var user = get();
  //   user['remainder'] = coin;
  //   set(user);
  // }

  //修改
  static upcoin(coin) {
    var user = get();
    user['remainder'] = coin;
    set(user);
  }

  static addcoin(coin) {
    var user = get();
    double old = 0.0;
    if (user['remainder'] is int) {
      old = double.parse(user['remainder'].toString());
    }
    if (user['remainder'] is String) {
      old = double.parse(user['remainder']);
    }
    if (user['remainder'] is double) {
      old = user['remainder'];
    }
    var tmp = (old + double.parse(coin));
    user['remainder'] = tmp.toStringAsFixed(2);
    set(user);
  }

  static gethttpuser(context) async {
    var tmp = await http('user/userinfo', {}, gethead());
    var httpuser = getdata(context, tmp!);
    if (isnull(httpuser)) {
      Map user = get();
      user.addAll(httpuser);
      set(user);
      return httpuser;
    }
    return;
  }
}
