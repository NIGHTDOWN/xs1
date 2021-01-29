import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/tool/down.dart';
import 'package:ng169/tool/toast.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;
//import 'package:permission_handler/permission_handler.dart';

import 'global.dart';
import 'http.dart';
import 'lang.dart';
import 'notify.dart';

void d(data, [index = 1]) {
  if (!isdebug) {
    return;
  }
  Iterable<String> lines =
      StackTrace.current.toString().trimRight().split('\n');
  var line = lines.elementAt(index);
  print('输出内容');
  print(data);
  print('行号' + line);
}

//弹出消息提示
void show(BuildContext context, String msg, [ToastPostion positions]) {
  if (!isnull(context)) {
    return;
  }
  if (positions != null) {
    Toast.toast(context, msg: msg, position: positions);
  } else {
    Toast.toast(context, msg: msg, position: ToastPostion.bottom);
  }
}

showbox(
  Widget body, [
  Color bgcolor = Colors.white10,
  double radius = 10,
  bool showclosebtn = true,
  double width,
]) {
  var w = isnull(width) ? width : getScreenWidth(g('context')) * .8;
  var c = Container(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // padding: EdgeInsets.all(4),
            decoration: new BoxDecoration(
                color: bgcolor,
                borderRadius: new BorderRadius.circular(radius)),
            child: body,
            width: w,
            // height: 250,
          ),
          showclosebtn
              ? GestureDetector(
                  onTap: () {
                    pop(g('context'));
                  },
                  child: Container(
                    margin: EdgeInsets.all(14),
                    padding: EdgeInsets.all(4),
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(25),
                      border: new Border.all(color: bgcolor, width: 2),
                    ),
                    child: Icon(
                      Icons.clear,
                      size: 25,
                      color: bgcolor,
                    ),
                  ),
                )
              : Container()
        ]),
  );
  showDialog(context: g('context'), barrierDismissible: true, child: c);
}

Future msgbox(BuildContext context, Function event,
    [Widget title, Widget body, Widget canceltitle, Widget oktitle]) async {
  if (!isnull(context)) {
    return Container();
  }
  title = isnull(title) ? title : Text(lang('提示'));
  body = isnull(body) ? body : Text(lang('是否删除'));
  canceltitle = isnull(canceltitle) ? canceltitle : Text(lang('取消'));
  oktitle = isnull(oktitle) ? oktitle : Text(lang('确认'));
  final action = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: body,
        actions: <Widget>[
          FlatButton(
            child: canceltitle,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: oktitle,
            onPressed: () {
              Navigator.pop(context);
              event();
            },
          ),
        ],
      );
    },
  );
  return await action;
}

gethead() {
// apisign
  //Map m={'timestamp':gettime(),'version':g('version'),'devicetype':g('deviceid')};
  Map m = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'timestamp'.toString(): gettime().toString(),
    'version'.toString(): g('version').toString(),
    'idfa': g('idfa'),
    'lang': getlang(),
    'qd': downqd,
    'devicetype'.toString(): Platform.isAndroid ? 'android' : 'ios'
  };

  var user = User.get();
  if (isnull(user)) {
    m.addAll({
      'uid'.toString(): user['uid'].toString(),
      'token'.toString(): user['token'].toString()
    });
  }
  var ret = new Map<String, dynamic>.from(m);

  return ret;
}

// ignore: missing_return
Future<String> getwifi() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    // 网络类型为移动网络
    return 'mobile';
  } else if (connectivityResult == ConnectivityResult.wifi) {
    // 网络类型为WIFI
    return 'wifi';
  }
  return 'none';
}

Future<ui.Image> getAssetImage(String asset, {width, height}) async {
  ByteData data = await rootBundle.load(asset);

  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width, targetHeight: height);

  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}

getcache(key, [bool needid = true]) {
  var cache = g('cache');
  String name;
  if (needid) {
    int id = User.getuid();
    if (id == 0) {
      name = key;
    } else {
      name = key + id.toString();
    }
  } else {
    name = key;
  }
  // name = name + g('locallg');
  var data = cache.get(name);
  return data;
}

getuser() {
  var user = User.get();

  if (!isnull(user)) return false;
  return user;
}

getuid() {
  var user = User.get();
  if (!isnull(user)) return '0';
  return user['uid'];
}

setcache(String key, val, String time, [bool needid = true]) {
  var cache = g('cache');
  String name;

  if (User.islogin()) {
    if (needid) {
      String id = User.getuid().toString();
      name = key + id;
    } else {
      name = key;
    }
  } else {
    name = key;
  }
  // name = name + g('locallg');
  var data = cache.set(name, val, time);
  return data;
}

String gettime() {
  var tmp = new DateTime.now().millisecondsSinceEpoch;
  tmp = (tmp / 1000).round() as int;
  return tmp.toString();
}

String getmirtime() {
  var tmp = new DateTime.now().millisecondsSinceEpoch;
  // tmp = (tmp / 1000).round() as int;
  return tmp.toString();
}

titlebarcolor(bool lightDark) {
  SystemChrome.setSystemUIOverlayStyle(
      lightDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
}

//隐藏状态栏
hidetitlebar() async {
  await SystemChrome.setEnabledSystemUIOverlays([]);
}

//显示状态栏
showtitlebar() {
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.top, SystemUiOverlay.bottom]);
}

/** 复制到剪粘板 */
copyToClipboard(final String text) async {
  if (text == null) return;
  Clipboard.setData(new ClipboardData(text: text));
}

const RollupSize_Units = ["GB", "MB", "KB", "B"];
/** 返回文件大小字符 */
String getRollupSize(int size) {
  int idx = 3;
  int r1 = 0;
  String result = "";
  while (idx >= 0) {
    int s1 = size % 1024;
    size = size >> 10;
    if (size == 0 || idx == 0) {
      r1 = (r1 * 100) ~/ 1024;
      if (r1 > 0) {
        if (r1 >= 10)
          result = "$s1.$r1${RollupSize_Units[idx]}";
        else
          result = "$s1.0$r1${RollupSize_Units[idx]}";
      } else
        result = s1.toString() + RollupSize_Units[idx];
      break;
    }
    r1 = s1;
    idx--;
  }
  return result;
}

/** 返回两个日期相差的天 */
int daysBetween(DateTime a, DateTime b, [bool ignoreTime = false]) {
  if (ignoreTime) {
    int v = a.millisecondsSinceEpoch ~/ 86400000 -
        b.millisecondsSinceEpoch ~/ 86400000;
    if (v < 0) return -v;
    return v;
  } else {
    int v = a.millisecondsSinceEpoch - b.millisecondsSinceEpoch;
    if (v < 0) v = -v;
    return v ~/ 86400000;
  }
}

/** 获取屏幕宽度 */
double getScreenWidth(BuildContext context) {
  if (!isnull(context)) return 0.0;
  return MediaQuery.of(context).size.width;
}

/** 获取屏幕高度 */
double getScreenHeight(BuildContext context) {
  if (!isnull(context)) return 0.0;
  return MediaQuery.of(context).size.height;
}

/** 获取系统状态栏高度 */
double getSysStatsHeight(BuildContext context) {
  if (!isnull(context)) return 0.0;
  return MediaQuery.of(context).padding.top;
}

//判断对象是否存在
bool isnull(dynamic data, [var index]) {
  if (null == data) {
    return false;
  }
  if (data is String) {
    //d('是string');
    data = data.trim();
    if ('null' == data) {
      return false;
    }
    if ('' == data) {
      return false;
    }
    if ('0' == data) {
      return false;
    }
  }
  if (data is int) {
    if (0 == data) {
      return false;
    }
  }
  if (data is bool) {
    return data;
  }
  // if ( data  is Object ) {
  //    d('是Object');
  //   return false;
  // }
  if (data is List) {
    if (data.length == 0) {
      return false;
    }
    // d('是List');
  }

  if (data is Map || data is List) {
    if (data.isEmpty) {
      return false;
    }
    if (null != index) {
      // d(data);
      // d(index);
      // d(isnull(data[index]));
      try {
        return isnull(data[index]);
      } catch (e) {
        return false;
      }
    }
    //d('是Map');

  }
  return true;
}

pop(context, [data]) {
  if (!isnull(context)) {
    return false;
  }
  if (isnull(data)) {
    Navigator.pop(context, data);
  } else {
    Navigator.of(context).pop(1);
  }
}

//
setDeviceOrientation([DeviceOrientation fx]) {
  SystemChrome.setPreferredOrientations([fx]);

// SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeLeft, DeviceOrientation.portraitUp]);
}

void selectbox(BuildContext context, List<Widget> childrens) async {
  if (!isnull(context)) return;
  await showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) => Container(
            child: Column(mainAxisSize: MainAxisSize.min, children: childrens),
          ));
}

checkversion(context, [bool isauto = false]) {
  http('common/add_version', {}, new Map<String, dynamic>.from(gethead()))
      .then((onValue) {
    var data = getdata(context, onValue);
    //获取版本信息
    // d(data['version_code']);
    // d(g('version'));
    setcache(appupinfo, data, '-1');
    alertupinfo(context, true, isauto);
  });
}

//弹出更新提示消息
alertupinfo(BuildContext context, [bool alert = false, bool isauto = false]) {
  if (!isnull(context)) {
    return false;
  }
  var serverinfo = getcache(appupinfo);
  if (!isnull(serverinfo)) return false;

  if (!isnull(serverinfo['version_code'])) return false;
  var version = g('version').split('.').reversed.toList();

  var sversion = serverinfo['version_code'].split('.').reversed.toList();

  var k = 0;
  bool k2 = false;
  for (var item in sversion) {
    if (int.parse(item) > int.parse(version[k])) {
      k2 = true;
    }
    if (int.parse(item) < int.parse(version[k])) {
      k2 = false;
    }

    k++;
  }
  var upurl = serverinfo['apk_url'];

  if (k2) {
    //服务器版本大于当前版
    if (alert) {
      if (isauto && isnull(serverinfo['autodown'])) {
        Down.autodown(context, upurl);
      } else {
        msgbox(context, () {
          Down.downandinstall(context, upurl);
        }, null, Text(serverinfo['upgrade_point']), null, Text(lang('确定升级')));
      }
    } else {
      if (int.parse(serverinfo['types']) == 2) {
        //强制升级
        msgbox(context, () {
          Down.downandinstall(context, upurl);
        }, null, Text(serverinfo['upgrade_point']), SizedBox(),
            Text(lang('确定升级')));
      }
    }
  }
}

checkversionnum() {
  var serverinfo = getcache(appupinfo);
  if (!isnull(serverinfo)) return false;

  if (!isnull(serverinfo['version_code'])) return false;
  var version = g('version').split('.').reversed.toList();

  var sversion = serverinfo['version_code'].split('.').reversed.toList();

  var k = 0;
  bool k2 = false;
  for (var item in sversion) {
    if (int.parse(item) > int.parse(version[k])) {
      k2 = true;
    }
    if (int.parse(item) < int.parse(version[k])) {
      k2 = false;
    }

    k++;
  }
  return k2;
}

toint(var str) {
  if (str is int) {
    return str;
  }
  if (str is String) {
    return int.parse(str);
  }
  return 0;
}

sharefun(Novel novel) {
  var uid = User.getuid().toString();
  var id = novel.id;
  var info = gettime();
  var langs = getlang();
  var book =
      serverurl + 'index/share/book?uid=$uid&bid=$id&nap=$info&lang=$langs';
  var cartoon =
      serverurl + 'index/share/cartoon?uid=$uid&cid=$id&nap=$info&lang=$langs';
  var url;
  if (novel.type == '1') {
    url = book;
  } else {
    url = cartoon;
  }

  var str = novel.name + "    " + url;
  Share.share(str, subject: lang('LookStory'));
}

//获取设备唯一标识
Future<String> getUniqueId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  var cache = 'idfas';
  var idfas = getcache(cache);

  if (isnull(idfas)) {
    return idfas;
  }
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    // print("ios唯一设备码："+iosDeviceInfo.identifierForVendor);

    // StorageManager.sharedPreferences.setString(StorageManager.KEY_SERIALID, iosDeviceInfo.identifierForVendor);

    idfas = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    // print("android唯一设备码："+androidDeviceInfo.androidId);

    // StorageManager.sharedPreferences.setString(StorageManager.KEY_SERIALID, androidDeviceInfo.androidId);

    idfas = androidDeviceInfo.androidId; // unique ID on Android
  }
  if (isnull(idfas)) {
    setcache(cache, idfas, '-1');
  }

  return idfas;
}
