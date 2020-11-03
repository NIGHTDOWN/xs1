import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';
import 'dart:math' as math;

class Readertipscar extends LoginBase {
  var page;
  var textcolor = Colors.white;
  double sizes = 40;
  String cachenae = 'carshowtips';
  bool havecache, isshow = true;
  @override
  void initState() {
    super.initState();
    // loadcache();
  }

  loadcache() {
  havecache = isnull(getcache(cachenae,false));
    // d(havecache);
    reflash();
  }

  @override
  Widget build(BuildContext context) {
    var w = getScreenWidth(context);
    var h = getScreenHeight(context);
    // return Text('data');
    var line = Container(
      height: .5,
      width: w * .8,
      child: CustomPaint(
        painter: DashRectPainter(color: textcolor, strokeWidth: 1, gap: 5.0),
      ),
    );
    var cccc = Container(
      color: Colors.black87,
      width: w,
      height: h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      // Icon(
                      //   Icons.navigate_before,
                      //   color: textcolor,
                      //   size: sizes,
                      // ),
                      Image.asset(
                        'assets/images/sup.png',
                        color: textcolor,
                        width: sizes,
                      ),
                      SizedBox(height: 3),
                      Text(
                        lang('上滑'),
                        style: TextStyle(color: textcolor),
                      ),
                    ])),
                line,
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      // SizedBox(height: h * .15),

                      Icon(
                        Icons.menu,
                        color: textcolor,
                        size: sizes,
                      ),
                      SizedBox(height: 3),
                      Text(
                        lang('菜单'),
                        style: TextStyle(color: textcolor),
                      ),

                      // Icon(
                      //   Icons.touch_app,
                      //   color: textcolor,
                      //   size: 55,
                      // ),
                      // Text(
                      //   lang('点击隐藏'),
                      //   style: TextStyle(color: textcolor),
                      // ),
                    ])),
                line,
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Image.asset(
                        'assets/images/sdown.png',
                        color: textcolor,
                        width: sizes,
                      ),
                      SizedBox(height: 3),
                      Text(
                        lang('下滑'),
                        style: TextStyle(color: textcolor),
                      ),
                    ]))
              ])
        ],
      ),
    );
    clicktips() {
      setcache(cachenae, 1, '-1',false);
      isshow = false;
      loadcache();
    }

    ;
    return WillPopScope(
      onWillPop: () {
        clicktips();
        return;
        // Future<bool> canGoBack = flutterWebViewPlugin.canGoBack();
        // canGoBack.then((str) {
        //   if (str) {
        //     flutterWebViewPlugin.goBack();
        //   } else {
        //     Navigator.of(context).pop();
        //   }
        // });
      },
      child: isshow
          ? GestureDetector(
              child: cccc,
              onTap: () {
                clicktips();
              })
          : SizedBox(),
    );
  }
}

class DashRectPainter extends CustomPainter {
  double strokeWidth;
  Color color;
  double gap;

  DashRectPainter(
      {this.strokeWidth = 5.0, this.color = Colors.red, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path _topPath = getDashedPath(
      a: math.Point(0, 0),
      b: math.Point(x, 0),
      gap: gap,
    );

    Path _rightPath = getDashedPath(
      a: math.Point(x, 0),
      b: math.Point(x, y),
      gap: gap,
    );

    Path _bottomPath = getDashedPath(
      a: math.Point(0, y),
      b: math.Point(x, y),
      gap: gap,
    );

    Path _leftPath = getDashedPath(
      a: math.Point(0, 0),
      b: math.Point(0.001, y),
      gap: gap,
    );

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);
  }

  Path getDashedPath({
    @required math.Point<double> a,
    @required math.Point<double> b,
    @required gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    num radians = math.atan(size.height / size.width);

    num dx = math.cos(radians) * gap < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    num dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x, currentPoint.y)
          : path.moveTo(currentPoint.x, currentPoint.y);
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(
        currentPoint.x + dx,
        currentPoint.y + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
