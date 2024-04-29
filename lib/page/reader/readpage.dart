
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Readpage extends StatefulWidget {
  Widget obj;
  Readpage(this.obj);

  @override
  ReadpageState createState() => ReadpageState();
}

class ReadpageState extends State<Readpage> with TickerProviderStateMixin {
  late AnimationController controller;

  late bool isOpenState;
  @override
  void initState() {
    // 初始化动画控制器，这里限定动画时常为200毫秒
    controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    // vsync对象会绑定动画的定时器到一个可视的widget，所以当widget不显示时，动画定时器将会暂停，当widget再次显示时，动画定时器重新恢复执行，这样就可以避免动画相关UI不在当前屏幕时消耗资源。
    // 当使用vsync: this的时候，State对象必须with SingleTickerProviderStateMixin或TickerProviderStateMixin；TickerProviderStateMixin适用于多AnimationController的情况。

    // 设置动画曲线，就是动画插值器
    // 通过这个链接可以了解更多差值器，https://docs.flutter.io/flutter/animation/Curves-class.html，我们这里使用带回弹效果的bounceOut。
    CurvedAnimation curve =
        new CurvedAnimation(parent: controller, curve: Curves.bounceOut);

    // 增加动画监听，当手势结束的时候通过动态计算到达目标位置的距离实现动画效果。curve.value为当前动画的值，取值范围0~1。
    curve.addListener(() {
      double animValue = curve.value;
      double offset = dragUpDownX - dragDownX;
      double toPosition;

      // 右滑
      if (offset > 0) {
        if (offset > maxDragX / 5) {
          // 打开
          toPosition = maxDragX;
          isOpenState = true;
        } else {
          if (isOpenState) {
            toPosition = maxDragX;
            isOpenState = true;
          } else {
            toPosition = 0.0;
            isOpenState = false;
          }
        }
      } else {
        if (offset < (-maxDragX / 2.0)) {
          // 关
          toPosition = 0.0;
          isOpenState = false;
        } else {
          if (isOpenState) {
            toPosition = maxDragX;
            isOpenState = true;
          } else {
            toPosition = 0.0;
            isOpenState = false;
          }
        }
      }

      dragOffset = (toPosition - dragUpDownX) * animValue + dragUpDownX;
      // 刷新位置
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
  }

  double dragDownX = 0.0;
  void _onViewDragDown(DragDownDetails callback) {
    dragDownX = callback.globalPosition.dx;
  }

  /**
   * 最大可拖动位置
   */
  final double maxDragX = 230.0;
  double dragOffset = 0.0;
  void _onViewDrag(DragUpdateDetails callback) {
    double tmpOffset = callback.globalPosition.dx - dragDownX;

    if (tmpOffset < 0) {
      tmpOffset += maxDragX;
    }

    // 边缘检测
    if (tmpOffset < 0) {
      tmpOffset = 0.0;
    } else if (tmpOffset >= maxDragX) {
      tmpOffset = maxDragX;
    }

    // 刷新
    if (dragOffset != tmpOffset) {
      dragOffset = tmpOffset;
      setState(() {});
    }
  }

  /**
   * 脱手时候的位置
   */
  double dragUpDownX = 0.0;
  void _onViewDragUp(DragEndDetails callback) {
    dragUpDownX = dragOffset;
    // 执行动画，每次都从第0帧开始执行
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dragOffset, 0.0),
      child: Container(
        child: GestureDetector(
          onHorizontalDragDown: _onViewDragDown,
          onVerticalDragDown: _onViewDragDown,
          onHorizontalDragUpdate: _onViewDrag,
          onVerticalDragUpdate: _onViewDrag,
          onHorizontalDragEnd: _onViewDragUp,
          onVerticalDragEnd: _onViewDragUp,
          child: this.widget.obj,
        ),
      ),
    );
  }
}
