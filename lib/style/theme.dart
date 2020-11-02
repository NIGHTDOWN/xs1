import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';

//登入页面主题
class Theme {
  // 登录界面，定义渐变的颜色
  // static const Color loginGradientStart = const Color(0xFFfbab66);
  // static const Color loginGradientEnd = const Color(0xFFf7418c);
  // static const Color appbar = const Color(0xFFFFFFFF);
  static Color loginGradientStart = SQColor.secondary;
  static Color loginGradientEnd = SQColor.primary;
  static Color appbar = Color(0xFFFFFFFF);
  static LinearGradient primaryGradient = LinearGradient(
    colors: [loginGradientStart, loginGradientEnd],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
