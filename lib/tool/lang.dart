import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/tool/global.dart';
import 'function.dart';

var language; //全局语言
String lang(index) {
  if (null == language) {
    return index;
  }
  if (null != language[index]) {
    return language[index];
  } else {
    return index;
  }
}

Future inilang() async {
  String jsonLang;
  try {
    String lang = getlang();
   
    if (isnull(lang)) {
      lang = lang.substring(0, 2);

      // 判断
      // List tmp = ['en', 'th', 'zh', 'vi', 'id', 'ko'];
      List tmp = ['en', 'th', 'vi', 'id', 'ko','ms','zh'];
      // d(langlist.keys);
      if (tmp.indexOf(lang) == -1) {
        //找不到语言包的时候加载默认
        d('这里加载默认语言' + delanguage);
        jsonLang = await rootBundle
            .loadString('assets/lang/$delanguage.json'); //加载语言文件
      } else {
        d('这里加载语言' + lang);
        jsonLang =
            await rootBundle.loadString('assets/lang/$lang.json'); //加载语言文件
      }
    } else {
      d('这里加载默认语言' + delanguage);
      jsonLang =
          await rootBundle.loadString('assets/lang/$delanguage.json'); //加载语言文件
    }
  } catch (e) {
    jsonLang = null;

    d('语言包加载错误');
    return false;
  }

  language = json.decode(jsonLang);
}