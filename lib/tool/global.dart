import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/cacheimg.dart';
import 'package:ng169/model/msg.dart';

import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/im.dart';
import 'package:ng169/tool/keeplive.dart';

import 'package:ng169/tool/thred.dart';
import 'package:ng169/tool/thredim.dart';
import 'package:package_info/package_info.dart';

import 'cache.dart';
import 'db.dart';
import 'function.dart';
import 'lang.dart';

Map<String, dynamic> globalKeys = {};
PackageInfo? packageInfo;
//dsl状态
bool dslStatus = false;
isolocateinit() async {
  globalKeys = {
    'cache': new NgCache()
    // , "db": new Db()
  };
  await globalKeys['cache'].init(); //加载缓存
  // globalKeys['db'].open(dbname);
}

//dsl域名
String dslDomain = '';
i() async {
  globalKeys = {
    'cache': new NgCache(),
    'db': new Db(),
    // 'tcp': new Tcp(),
    'user': {},
    'coin': '0',
    // 'admob': Ads()..init(),
    'msg': 0,
    'locallg': '',
    'downthred': Thred(),
    'im': "",
    'inmsgpage': "0",
  };
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  await globalKeys['cache'].init(); //加载缓存
  Msg.cheack();
  // await globalKeys['db'].open(dbname);
  // packageInfo = await PackageInfo.fromPlatform();
  // await initmblang();
  //连接ws
  await Future.wait<dynamic>([
    //耗时操作，同步执行
    globalKeys['db'].open(dbname),
    initpackinfo(),
    initmblang(),

    initidfa(),
  ]);

  //dsl状态非必要加载
  getdsl();
  Keeplive.register(); //后台任务
  Keeplive.init(); //后台任务
  //后台任务
  //下载线程
  globalKeys['downthred'].init(Cacheimg.islocol, true);

//  await globalKeys['tcp'].open('ws://192.168.6.6:8888');
  //MessageUtils.open('ws://192.168.6.6:8888');
//  await globalKeys['tcp'].listen();
//   globalKeys['tcp'].recv((data){
//     d(data);
//   });

// await Future.wait<dynamic>([demo1,demo2,demo3])
  //String appName = packageInfo.appName;
  //String packageName = packageInfo.packageName;
  String version = packageInfo!.version;
  //String buildNumber = packageInfo.buildNumber;
  globalKeys['version'] = version;

  globalKeys['rack'] = false;
  // Im.init();
  Thredim.run("", () {});

  // await inilang(); //加载语言包
  //数据库的还没加载
}

//获取dsl信息，域名，以及状态
getdsl() async {
  var cachename = 'dsldamin';
  var cache = getcache(cachename);
  if (isnull(cache)) {
    dslDomain = cache;
    dslStatus = true;
  } else {
    dslDomain = '';
    dslStatus = false;
  }
  var domian = await http('index/dsl', {}, gethead());
  domian = getdata(g('context'), domian!);
  if (isnull(domian)) {
    dslDomain = domian!;
    dslStatus = true;
  } else {
    // dslDomain=domian;
    dslDomain = '';
    dslStatus = false;
  }
  setcache(cachename, domian, '-1');
}

initidfa() async {
  globalKeys['idfa'] = await getUniqueId();
}

initpackinfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}

//初始化手机系统语言
initmblang() async {
  String cachename = 'locallg';
  String? lang = getcache(cachename);
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
  String? lang = g(cachename);
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
