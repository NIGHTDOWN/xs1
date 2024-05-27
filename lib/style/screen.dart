import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart' as s2;

import 'dart:ui' as ui show window;

class Screen {
  static double get width {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.width;
  }

  static double get height {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.height;
  }

  static double get scale {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.devicePixelRatio;
  }

  static double get textScaleFactor {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.textScaleFactor;
  }

  static double get navigationBarHeight {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top + kToolbarHeight;
  }

  static double get topSafeHeight {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top;
  }

  static double get bottomSafeHeight {
    // ignore: deprecated_member_use
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.bottom;
  }

  static updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static void keepOn(bool bool) {
    // s2.Screen.keepOn(bool);
    s2.FlutterScreenWake.keepOn(bool);
  }

  static void setBrightness(double data) {
    s2.FlutterScreenWake.setBrightness(data);
  }

  // static void getBrightness(double data) {
  //    s2.FlutterScreenWake.brightness;
  // }
  static Future<double> get brightness async {
    double ld = await s2.FlutterScreenWake.brightness;

    double rounded = (ld * 100).round() / 100;
    return rounded;
  }
}
