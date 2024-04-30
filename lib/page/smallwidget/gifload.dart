import 'package:flutter/material.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/tool/global.dart';

// ignore: must_be_immutable
class Gifload extends StatelessWidget {
   List<String> loading = [
    'assets/images/loading/1.png',
    'assets/images/loading/2.png',
    'assets/images/loading/3.png',
    'assets/images/loading/4.png',
    'assets/images/loading/5.png',
  ];
  @override
  Widget build(BuildContext context) {
    return FrameAnimationImage(
      imageList: loading,
      width: g('swidth'),
      // height: g('sheight'),
      picwidth: 50,
      interval: 200, bgcolor: Color.fromARGB(0, 0, 0, 0),
    );
  }
}