import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/cacheimg.dart';
import 'package:ng169/page/task/ads.dart';
import 'package:ng169/pay/AdBridge.dart';
import 'package:ng169/tool/listenclip.dart';
import 'package:ng169/tool/tcp.dart';
import 'package:ng169/tool/thred.dart';
import 'package:package_info/package_info.dart';

import 'cache.dart';
import 'db.dart';
import 'function.dart';
import 'lang.dart';

Map<String, dynamic> globalKeys;

i() async {
  globalKeys = {
    'cache': new NgCache(),
    'db': new Db(),
    // 'tcp': new Tcp(),
    'user': {},
    'coin': '0',
    'admob': Ads()..init(),
    'msg': 0,

    'locallg': '',
    'downthred': Thred(),
    // 'listenclip': Thred()
  };
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  await globalKeys['cache'].init(); //加载缓存
  await globalKeys['db'].open(dbname);
  //下载线程
  globalKeys['downthred'].init(Cacheimg.islocol, true);
  // await globalKeys['listenclip'].init(ListenClip.start, true);

//  await globalKeys['tcp'].open('ws://192.168.6.6:8888');
  //MessageUtils.open('ws://192.168.6.6:8888');
//  await globalKeys['tcp'].listen();
//   globalKeys['tcp'].recv((data){
//     d(data);
//   });
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //String appName = packageInfo.appName;
  //String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  //String buildNumber = packageInfo.buildNumber;
  globalKeys['version'] = version;
  globalKeys['idfa'] = await getUniqueId();

  globalKeys['rack'] = false;

  await initmblang();

  // await inilang(); //加载语言包
  //数据库的还没加载
}

//初始化手机系统语言
initmblang() async {
  String cachename = 'locallg';
  String lang = getcache(cachename);
  if (isnull(lang)) {
    s(cachename, lang);
  } else {
    lang = Platform.localeName;
    setcache(cachename, lang, '-1');
    s(cachename, lang);
  }
  await inilang();
}

//获取语言
getlang() {
  String cachename = 'locallg';
  String lang = g(cachename);
  return lang;
}

//设置语言
setlang(String lang) async {
  String cachename = 'locallg';
  setcache(cachename, lang, '-1');
  s(cachename, lang);
  await inilang();
}

g(key) {
  if (isnull(globalKeys, key)) return globalKeys[key];
  return null;
}

s(key, val) {
  globalKeys.addAll({key: val});
  // globalKeys[key] = val;
}
