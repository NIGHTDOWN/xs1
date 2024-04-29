import 'dart:async';
import 'dart:ui';

import 'package:ng169/obj/novel.dart';

import 'function.dart';
import 'global.dart';

class Jsq {
  static _Jsq? _instance = null;
  Jsq() {
    if (!isnull(_instance)) {
      _instance = _Jsq();
    }
  }
  start() {
    _instance!.start();
  }

  end() {
    _instance!.end();
  }

  int gettime() {
    return _instance!.gettime();
  }
}

// ignore: camel_case_types
class _Jsq {
  int seconds = 0;
  bool flag = true;
  String timecachepre = 'timecachename';
  String timecachename = 'timecachename';
  _init() {
    flag = true;
    seconds = 0;
    DateTime dateTime = DateTime.now();
    String ymd = dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString();

    timecachename = timecachepre + ymd;
    // d(timecachename);
    var sec = getcache(timecachename);

    if (!isnull(sec)) {
      setcache(timecachename, 0, '-1');
    } else {
      if (sec is int) {
        seconds = sec;
      } else {
        seconds = int.parse(sec);
      }
    }
    // d(seconds);
    //初始化
    //判断时间
    //计时
  }

  start({Novel? novel}) {
    _init();

    Timer.periodic(Duration(seconds: 1), (timer) {
      // d('计时中...$seconds');
      // d(g('gstat'));
      if (!flag) {
        timer.cancel(); // 取消重复计时
        return;
      }
      if (g('gstat') != AppLifecycleState.paused) {
        seconds++; // 秒数+1
        setcache(timecachename, seconds, '-1');
      }
    });
  }

  end() {
    flag = false;
  }

//获取今日阅读时长
  int gettime() {
    _init();
    return seconds;
  }

  clear({num = 0}) {
    _init();
    seconds = num;
    // d('清空');
    setcache(timecachename, num, '0');
  }
}
