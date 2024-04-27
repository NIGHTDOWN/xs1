import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';
import 'dart:math' as math;

class Readertips extends LoginBase {
  var page;
  var textcolor = Colors.white;
  String cachenae = 'bookshowtips';
  late bool havecache, isshow = true;
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
      height: h * .8,
      width: .5,
      child: CustomPaint(
        painter: DashRectPainter(color: textcolor, strokeWidth: 1, gap: 5.0),
      ),
    );
    var cccc = Container(
      color: Colors.black87,
      width: w,
      height: h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(children: [
                  Icon(
                    Icons.navigate_before,
                    color: textcolor,
                    size: 35,
                  ),
                  Text(
                    lang('上一页'),
                    style: TextStyle(color: textcolor),
                  ),
                ])),
                line,
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      SizedBox(height: h * .15),
                      Column(children: [
                        Icon(
                          Icons.menu,
                          color: textcolor,
                          size: 35,
                        ),
                        Text(
                          lang('菜单'),
                          style: TextStyle(color: textcolor),
                        ),
                      ]),
                      SizedBox(height: h * .05),
                      Column(children: [
                        Icon(
                          Icons.touch_app,
                          color: textcolor,
                          size: 55,
                        ),
                        Text(
                          lang('点击'),
                          style: TextStyle(color: textcolor),
                        ),
                      ])
                    ])),
                line,
                Expanded(
                    child: Column(children: [
                  Icon(
                    Icons.navigate_next,
                    color: textcolor,
                    size: 35,
                  ),
                  Text(
                    lang('下一页'),
                    style: TextStyle(color: textcolor),
                  ),
                ]))
              ])
        ],
      ),
    );
    clicktips() {
      setcache(cachenae, 1, '-1',false);
      isshow=false;
      loadcache();
    }

    ;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        clicktips();
        return Future.value(false);  
        // Future<bool> canGoBack = flutterWebViewPlugin.canGoBack();
        // canGoBack.then((str) {
        //   if (str) {
        //     flutterWebViewPlugin.goBack();
        //   } else {
        //     Navigator.of(context).pop();
        //   }
        // });
      },
      child:isshow? GestureDetector(
          child: cccc,
          onTap: () {
            clicktips();
          }):SizedBox(),
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
    required math.Point<double> a,
    required math.Point<double> b,
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
          ? path.lineTo(currentPoint.x as double, currentPoint.y as double )
          : path.moveTo(currentPoint.x as double,currentPoint.y as double);
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
