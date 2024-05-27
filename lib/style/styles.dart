import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

class Styles {
  static List<BoxShadow> get borderShadow {
    return [BoxShadow(color: Color(0x22000000), blurRadius: 8)];
  }

  static List<BoxShadow> get bordercateShadow {
    return [BoxShadow(color: Color(0x22000000), blurRadius: 28)];
  }

  static Map th1 = {
    'bg': 'assets/images/th1.png', //背景
    // 'fontsize': 30.0, //字体大小
    'fontcolor': Color(0xFF333333), //文章字体颜色
    'titlefontcolor': Colors.black54, //章节字体颜色
    'batterycolor': Colors.black54, //电量背景颜色
    'batteryfontcolor': Colors.black, //电量字体颜色

    'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': Colors.black54, //各种弹出框字体颜色
    'activecolor': SQColor.primary, //各种进度条颜色
    'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
    'catenomal': Colors.black, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': Colors.black54, //目录已点文字颜色
  };
  static Map th2 = {
    'bg': 'assets/images/th2.jpg', //背景
    // 'fontsize': 30.0, //字体大小
    'fontcolor': Color(0xFF333333), //文章字体颜色
    'titlefontcolor': Colors.black54, //章节字体颜色
    'batterycolor': Colors.black54, //电量背景颜色
    'batteryfontcolor': Colors.black, //电量字体颜色

    'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': Colors.black54, //各种弹出框字体颜色
    'activecolor': SQColor.primary, //各种进度条颜色
    'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
    'catenomal': Colors.black, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': Colors.black54, //目录已点文字颜色
  };
  static Map th3 = {
    'bg': 'assets/images/th3.jpg', //背景
    // 'fontsize': 30.0, //字体大小
    'fontcolor': Color(0xFF333333), //文章字体颜色
    'titlefontcolor': Colors.black54, //章节字体颜色
    'batterycolor': Colors.black54, //电量背景颜色
    'batteryfontcolor': Colors.black, //电量字体颜色

    'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': Colors.black54, //各种弹出框字体颜色
    'activecolor': SQColor.primary, //各种进度条颜色
    'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
    'catenomal': Colors.black, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': Colors.black54, //目录已点文字颜色
  };
  static Map th4 = {
    'bg': 'assets/images/th4.jpg', //背景
    // 'fontsize': 30.0, //字体大小
    'fontcolor': Color(0xFF333333), //文章字体颜色
    'titlefontcolor': Colors.black54, //章节字体颜色
    'batterycolor': Colors.black54, //电量背景颜色
    'batteryfontcolor': Colors.black, //电量字体颜色

    'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': Colors.black54, //各种弹出框字体颜色
    'activecolor': SQColor.primary, //各种进度条颜色
    'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
    'catenomal': Colors.black, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': Colors.black54, //目录已点文字颜色
  };
  static Map th5 = {
    'bg': 'assets/images/th5.jpg', //背景
    // 'fontsize': 30.0, //字体大小
    'fontcolor': Color(0xFF333333), //文章字体颜色
    'titlefontcolor': Colors.black54, //章节字体颜色
    'batterycolor': Colors.black54, //电量背景颜色
    'batteryfontcolor': Colors.black, //电量字体颜色

    'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': Colors.black54, //各种弹出框字体颜色
    'activecolor': SQColor.primary, //各种进度条颜色
    'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
    'catenomal': Colors.black, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': Colors.black54, //目录已点文字颜色
  };
  //暗黑模式
  static Map th6 = {
    'bg': 'assets/images/th6.jpg', //背景
    'fontcolor': SQColor.white60, //文章字体颜色
    'titlefontcolor': SQColor.white60, //章节字体颜色
    'batterycolor': SQColor.white60, //电量背景颜色
    'batteryfontcolor': SQColor.white60, //电量字体颜色

    'barcolor': Colors.black87, //各种弹出框背景颜色
    // 'barcolor': Colors.red, //各种弹出框背景颜色
    'barfontcolor': SQColor.white60, //各种弹出框字体颜色
    'activecolor': SQColor.white, //各种进度条颜色
    'activefontcolor': Colors.black54, //各种进度条颜色
    'catenomal': SQColor.white60, //目录文字颜色
    'cateon': Colors.orange[700], //目录选中文字颜色
    'cateover': SQColor.white38, //目录已点文字颜色
  };
  static Map getTheme() {
    var cache = getcache(fontsizecache);
    Map defult = {
      'bg': 'assets/images/th1.png', //背景
      'fontsize': isnull(cache) ? cache : 20.0, //字体大小
      'fontcolor': Colors.black, //文章字体颜色
      'titlefontcolor': Colors.black54, //章节字体颜色
      'batterycolor': Colors.black54, //电量背景颜色
      'batteryfontcolor': Colors.black, //电量字体颜色

      'barcolor': Color(0xFFF5F5F5), //各种弹出框背景颜色
      // 'barcolor': Colors.red, //各种弹出框背景颜色
      'barfontcolor': Colors.black54, //各种弹出框字体颜色
      'activecolor': SQColor.primary, //各种进度条颜色
      'activefontcolor': Color(0xFFFFFFFF), //各种进度条颜色
      'catenomal': Colors.black, //目录文字颜色
      'cateon': Colors.orange[700], //目录选中文字颜色
      'cateover': Colors.black54, //目录已点文字颜色
    };
    if (isnull(getcache(themecache))) {
      switch (getcache(themecache)) {
        case 'th6':
          defult.addAll(th6);
          break;
        case 'th1':
          defult.addAll(th1);
          break;
        case 'th2':
          defult.addAll(th2);
          break;
        case 'th3':
          defult.addAll(th3);
          break;
        case 'th4':
          defult.addAll(th4);
          break;
        case 'th5':
          defult.addAll(th5);
          break;
      }
    }

    return defult;
  }
}
