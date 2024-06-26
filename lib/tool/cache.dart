import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NgCache {
  late SharedPreferences cache;
  int outtime = 86400; //有效时间
  NgCache();
  void init() async {
    cache = await SharedPreferences.getInstance();
  }

  dynamic get(String key) {
    Object? data = cache.get(key);
    //d(data);
    if (data == null || data is! String) {
      return null;
    }

    // 将 Object 类型的 data 强制转换为 String
    String dataString = data;

    // 检查 dataString 是否为空字符串
    if (dataString.isEmpty) {
      return null;
    }
    var js;
    try {
      js = jsonDecode(data);
    } catch (e) {
      return null;
    }

    if (js == '') {
      return null;
    }
    var time = (js['time']);
    if (time <= 0) {
      return js['data'];
    }

    var now = int.parse(
        new DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10));
    if (time >= now) {
      return js['data'];
    } else {
      del(key);
      return false;
    }
  }

  set(String key, dynamic val, [String? expretimes]) async {
    int expretime;
    if (expretimes != null) {
      expretime = int.parse(expretimes);
    } else {
      expretime = 0;
    }

    if (expretime < 0) {
      // expretime = 0;
    } else if (expretime == 0) {
      expretime = int.parse(new DateTime.now()
              .millisecondsSinceEpoch
              .toString()
              .substring(0, 10)) +
          outtime;
    } else {
      expretime = int.parse(new DateTime.now()
              .millisecondsSinceEpoch
              .toString()
              .substring(0, 10)) +
          expretime;
    }
    dynamic data = {'data': val, 'time': expretime};

    await cache.setString(key, jsonEncode(data)).then((bools) {
      //d(data);//这里缓存更新后的回调结果
      // d(bools);//这里缓存更新后的回调结果
    });
  }

  del(String key) {
    cache.remove(key);
  }
}
