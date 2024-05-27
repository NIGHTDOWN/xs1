import 'package:flutter/material.dart';
import 'package:ng169/page/smallwidget/gifcartoon2.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/tool/global.dart';

// ignore: must_be_immutable
class GifCartoon extends StatelessWidget {
  //  List<String> loading = [
  //  'assets/images/cy/1.png',
  //   'assets/images/cy/2.png',
  //   'assets/images/cy/3.png',
  //   'assets/images/cy/4.png',
  //   'assets/images/cy/5.png',
  //   'assets/images/cy/6.png',
  //   'assets/images/cy/7.png',
  //   'assets/images/cy/8.png',
  //   'assets/images/cy/9.png',
  //   'assets/images/cy/10.png',
  //   'assets/images/cy/11.png',
  // ];
  // @override
  // Widget build(BuildContext context) {
  //   return FrameAnimationImage(
  //     imageList: loading,
  //     width: g('swidth'),
  //     // height: g('sheight'),
  //     picwidth: 50,
  //     interval: 200, bgcolor: Color.fromARGB(0, 0, 0, 0),
  //   );
  // }
  //上面的FrameAnimationImage性能太差
  Widget build(BuildContext context) {
    return GifCartoon2();
  }
}
