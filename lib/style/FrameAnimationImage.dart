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
  State<StatefulWidget> createState() => FrameAnimationImageState();
}

class FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
 late AnimationController _controller;
  int interval = 200;
  List<String> assetList = [
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
  late Color bgcolor;
  double picwidth = 100.0;
  @override
  void initState() {
    super.initState();

    // ignore: unnecessary_null_comparison
    if (widget.interval != null) {
      interval = widget.interval;
    }
    if (isnull(widget.imageList)) {
      assetList = widget.imageList;
    }
    if (isnull(widget.bgcolor)) {
      bgcolor = widget.bgcolor;
    } else {
      bgcolor = SQColor.white;
    }
    //判断卡通帧有没有大小上限
    if (isnull(widget.picwidth)) {
      picwidth = widget.picwidth;
    } else {
      picwidth = widget.width;
    }
    final int imageCount = assetList.length;
    final int maxTime = interval * imageCount;

    _controller = new AnimationController(
        duration: Duration(milliseconds: maxTime), vsync: this);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0); // 完成后重新开始
      }
    });

    _animation = new Tween<double>(begin: 0, end: imageCount.toDouble())
        .animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int ix = _animation.value.floor() % assetList.length;

    List<Widget> images = [];
    // 把所有图片都加载进内容，否则每一帧加载时会卡顿
    //判断尺寸是不是
    for (int i = 0; i < assetList.length; ++i) {
      if (i != ix) {
        images.add(Container(
            color: bgcolor,
            child: Image.asset(
              assetList[i],
              width: 0,
              height: 0,
            ),
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height));
      }
    }

    images.add(Container(
        color: bgcolor,
        child: Image.asset(
          assetList[ix],
          width: picwidth,
          //height:  600.0,
        ),
        alignment: Alignment.center,
        width: widget.width,
        height: widget.height));

    return Stack(alignment: AlignmentDirectional.center, children: images);
   
    
  }
}
