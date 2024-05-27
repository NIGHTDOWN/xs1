import 'package:flutter/material.dart';

class SQBar {
  // static Color primary = Color(0xFF23B38E);
  // static Color primary4 = Color(0xFF51DEC6);
  static Widget gettitlebar() {
    return Container(
      width: 3, // 填充父容器宽度
      height: 20, // 长方形的高度
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, // 渐变开始位置
          end: Alignment.bottomCenter, // 渐变结束位置
          colors: [Colors.red, Colors.red.withOpacity(0.2)], // 渐变颜色列表
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)), // 可选：设置圆角
      ),
    );
  }
}
