import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

// 帧动画Image
// ignore: must_be_immutable
class FrameAnimationImage extends StatefulWidget {
  final double width;
  final double height;
  final Color bgcolor;
  final double picwidth;
  int interval = 200;
  List<String> imageList;
  FrameAnimationImage(
      {required this.imageList,
      this.width = 150,
      this.height = 150,
      this.interval = 200,
      required this.bgcolor,
      this.picwidth = 100});

  @override
  State<StatefulWidget> createState() => _FrameAnimationImageState();
}
// class FrameAnimationImageState extends State<FrameAnimationImage>
//     with SingleTickerProviderStateMixin {
//   late Animation<double> _animation;
//  late AnimationController _controller;
//   int interval = 200;
//   List<String> assetList = [
  
//   ];
//   late Color bgcolor;
//   double picwidth = 100.0;
//   @override
//   void initState() {
//     super.initState();

//     // ignore: unnecessary_null_comparison
//     if (widget.interval != null) {
//       interval = widget.interval;
//     }
//     if (isnull(widget.imageList)) {
//       assetList = widget.imageList;
//     }
//     if (isnull(widget.bgcolor)) {
//       bgcolor = widget.bgcolor;
//     } else {
//       bgcolor = SQColor.white;
//     }
//     //判断卡通帧有没有大小上限
//     if (isnull(widget.picwidth)) {
//       picwidth = widget.picwidth;
//     } else {
//       picwidth = widget.width;
//     }
//     final int imageCount = assetList.length;
//     final int maxTime = interval * imageCount;

//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: widget.interval * widget.imageList.length),
//     )..repeat();

//     _animation = Tween<double>(begin: 0.0, end: widget.imageList.length - 1)
//         .animate(_controller);

//     // 动画完成后重置
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _controller.reset();
//       }
//     });

//     // 动画更新时不重建整个 Widget，只更新图片索引
//     _animation.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });

//     // 预加载图片资源
//     final Completer<void> preloader = Completer<void>();
//     for (final String image in widget.imageList) {
//       Image.asset(image).then((file) {
//         preloader.complete();
//       });
//     }
//     preloader.future.then((_) => _controller.forward());
//     // _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // int ix = _animation.value.floor() % assetList.length;

//     // List<Widget> images = [];
//     // // 把所有图片都加载进内容，否则每一帧加载时会卡顿
//     // //判断尺寸是不是
//     // for (int i = 0; i < assetList.length; ++i) {
//     //   if (i != ix) {
//     //     images.add(Container(
//     //         color: bgcolor,
//     //         child: Image.asset(
//     //           assetList[i],
//     //             width: picwidth,
//     //           // height: 0,
//     //         ),
//     //         alignment: Alignment.center,
//     //         width: widget.width,
//     //         height: widget.height));
//     //   }
//     // }

//     // images.add(Container(
//     //     color: bgcolor,
//     //     child: Image.asset(
//     //       assetList[ix],
//     //       width: picwidth,
//     //       //height:  600.0,
//     //     ),
//     //     alignment: Alignment.center,
//     //     width: widget.width,
//     //     height: widget.height));

//     // return Stack(alignment: AlignmentDirectional.center, children: images);
//     // Widget imageWidget = Transform.scale(
//     //   scale: picwidth / widget.imageList.length,
//     //   child: Image.asset(
//     //     widget.imageList[_animation.value.round()],
//     //     width: picwidth,
//     //     // height: ... 设置合适的高度
//     //   ),
//     // );
//     // return Container(
//     //   color: bgcolor,
//     //   width: widget.width,
//     //   height: widget.height,
//     //   child: Stack(
//     //     alignment: Alignment.center,
//     //     children: <Widget>[
//     //       // ... 其他 Widget
//     //       imageWidget,
//     //     ],
//     //   ),
//     // );
//     int currentIndex = (_animation.value % widget.imageList.length).toInt();

//     return Container(
//       color: widget.bgcolor,
//       width: widget.width,
//       height: widget.height,
//       child: Stack(
//         alignment: Alignment.center,
//         children: <Widget>[
//           Opacity(
//             // 使用动画值来设置透明度，实现平滑过渡
//             opacity: _animation.value == currentIndex ? 1.0 : 0.0,
//             child: Image.asset(
//               widget.imageList[currentIndex],
//               width: widget.width,
//               // 可以根据需要设置合适的高度或者保持宽高比
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// class FrameAnimationImage extends StatefulWidget {
//   final double width;
//   final double height;
//   final Color bgcolor;

//  final int interval ;
//   final List<String> imageList;

//   FrameAnimationImage({
//     required this.width,
//     required this.height,
//     required this.bgcolor,
//       this.interval=200,
//     required this.imageList,
//   });

//   @override
//   _FrameAnimationImageState createState() => _FrameAnimationImageState();
// }

class _FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.interval ~/ 1000 * widget.imageList.length),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: widget.imageList.length - 1)
        .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = (_animation.value % widget.imageList.length).toInt();

    return Container(
      color: widget.bgcolor,
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Image.asset(
          //   widget.imageList[currentIndex],
          //   width: widget.width,
          //   // height: widget.height, // 根据需要设置高度
          //   fit: BoxFit.cover,
          // ),
           Opacity(
            // 使用动画值来设置透明度，实现平滑过渡
            opacity: _animation.value == currentIndex ? 1.0 : 0.0,
            child: Image.asset(
              widget.imageList[currentIndex],
              width: widget.width,
               fit: BoxFit.cover,
              // 可以根据需要设置合适的高度或者保持宽高比
            ),
          ),
        ],
      ),
    );
  }
}