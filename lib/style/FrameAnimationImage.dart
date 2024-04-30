import 'package:flutter/material.dart';
// 确保这个路径是正确的
// 确保这个路径是正确的

class FrameAnimationImage extends StatefulWidget {
  final double width;
  final double height;
  final Color bgcolor;
  final int interval;
  final List<String> imageList;
  final double picwidth;

  FrameAnimationImage({
    required this.imageList,
    this.width = 150,
    this.height = 150,
    this.interval = 200,
    required this.bgcolor,
    this.picwidth = 100,
  });

  @override
  _FrameAnimationImageState createState() => _FrameAnimationImageState();
}

class _FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final int imageCount = widget.imageList.length;

    // 确保动画时长是正数
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.interval * imageCount),
    )..repeat(); // 动画重复

    _animation = Tween<double>(begin: 0.0, end: imageCount.toDouble())
        .animate(_controller);

    // 监听动画状态，以便在必要时重置动画
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0);
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _animation.addListener(() {
      // 动画每一帧更新时重建 UI
      setState(() {});
    });

    _controller.forward(); // 开始动画
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 动画值直接用作索引，因为 Tween 的 end 值是 imageCount
    final int currentFrameIndex = _animation.value.toInt() % widget.imageList.length;
    return Container(
      color: widget.bgcolor,
      width: widget.width,
      height: widget.height,
      child: Image.asset(
        widget.imageList[currentFrameIndex],
        width: widget.picwidth,
        // 可以根据图片比例设置合适的高度
        // fit: BoxFit.cover,
      ),
    );
  }
}