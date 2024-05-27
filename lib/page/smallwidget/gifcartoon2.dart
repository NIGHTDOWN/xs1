import 'package:flutter/material.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/tool/global.dart';

// ignore: must_be_immutable
class GifCartoon2 extends StatelessWidget {
  List<String> loading = [
    'assets/images/cy/1.png',
    'assets/images/cy/2.png',
    'assets/images/cy/3.png',
    'assets/images/cy/4.png',
    'assets/images/cy/5.png',
    'assets/images/cy/6.png',
    'assets/images/cy/7.png',
    'assets/images/cy/8.png',
    'assets/images/cy/9.png',
    'assets/images/cy/10.png',
    'assets/images/cy/11.png',
  ];
  @override
  Widget build(BuildContext context) {
    var img = Image(
      width: 150,
      height: 150,
      image: AssetImage('assets/images/gif/loading.gif'), // 替换为你的GIF文件路径
    );
    return Container(
      child: img,
      width: 150,
    );
  }
}
