import 'package:flutter/material.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/tool/global.dart';

// ignore: must_be_immutable
class Gifload2 extends StatelessWidget {
  List<String> loading = [
    'assets/images/loading/1.png',
    'assets/images/loading/2.png',
    'assets/images/loading/3.png',
    'assets/images/loading/4.png',
    'assets/images/loading/5.png',
  ];
  @override
  Widget build(BuildContext context) {
    return Image(
      width: 150,
      image: AssetImage('assets/images/gif/loadingBook.gif'), // 替换为你的GIF文件路径
    );
  }
}
