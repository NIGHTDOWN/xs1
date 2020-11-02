import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'function.dart';

class Loadbox extends StatefulWidget {
  final bool loading;
  final Widget child;
  final double height;
  final double width;
  final Color color;
  final Color bgColor;
  final int count;
  final int speed;
  final double opacity;

  final bool hasmask;

  Loadbox(
      {Key key,
      @required this.loading,
      @required this.child,
      this.color = Colors.blue,
      this.bgColor = Colors.black45,
      this.width = 80,
      this.height = 80,
      this.count = 12,
      this.speed = 80,
      this.hasmask = true,
      this.opacity = 0.2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadboxState();
  }
}

class LoadboxState extends State<Loadbox> {
  Timer timer;

  // Widget child;
  double height;
  double width;
  Color color;
  Color bgColor;
  int count;
  int speed;
  double opacity;

  List<Offset> offsetList = [];
  List<double> radiusList = [];
  List<double> radianList = [];
  double moveViewSize;
  double moveSize;
  double w;
  double r;

  void updateLoad(bool loading) {
    if (!mounted) return;
    setState(() {});
  }

  void updateChild(Widget child) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    this.width = widget.width;
    this.height = widget.height;
    this.color = widget.color;
    this.bgColor = widget.bgColor;
    this.count = widget.count;
    this.speed = widget.speed;
    this.opacity = widget.opacity;

    this.moveViewSize = 1;
    this.moveSize = 1;

    this.timer =
        Timer.periodic(new Duration(milliseconds: this.speed), (timer) {
      if (!mounted) return;
      setState(() {
        double r = this.width;
        if (r > this.height) {
          r = this.height;
        }
        r = r / 2.0;
        r = r * this.moveSize;
        double w = r * sin(2 * pi / this.count) / 2.0;

        r -= (w / 2.0);
        w = w * this.moveViewSize;
        this.r = r;
        this.w = w;
        List<Offset> oList = [];
        List<double> rList = [];
        List<double> radianList = [];

        for (int i = 1; i < this.count + 1; i++) {
          w = this.w * i / this.count;

          double radian = (pi * 2.0 / this.count) * i;
          Offset offset = Offset(this.width / 2.0 + this.r * cos(radian),
              this.r * sin(radian) + this.height / 2.0);
          if (this.radianList.length > 0) {
            radian = this.radianList[i - 1] + pi * 2.0 / (2.0 * this.count);
            offset = Offset(this.width / 2.0 + this.r * cos(radian),
                this.height / 2.0 + this.r * sin(radian));
          }

          oList.add(offset);
          rList.add(w / 2.0);
          radianList.add(radian);
        }
        this.offsetList = oList;
        this.radiusList = rList;
        this.radianList = radianList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [];

    //如果正在加载，则显示加载添加加载中布局
    if (widget.loading) {
      if (isnull(widget.child)) {
        widgetList.add(widget.child);
      }

      //增加一层黑色背景透明度为0.8
      if (widget.hasmask) {
        widgetList.add(
          Opacity(
              opacity: this.opacity,
              child: ModalBarrier(
                color: Colors.black,
              )),
        );
      }

      //环形进度条
      widgetList.add(Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
              //黑色背景
              color: this.bgColor,
              //圆角边框
              borderRadius: BorderRadius.circular(10.0)),
          child: CustomPaint(
            painter: RoundPainter(
                offsetList: this.offsetList,
                radiusList: this.radiusList,
                color: this.color),
            size: Size(this.width, this.height),
          ),
        ),
      ));
    } else {
      widgetList = [];
      widgetList.add(widget.child);
    }
    return GestureDetector(
      child: Stack(
        children: widgetList,
      ),
      onTap: () {
        //loading = false;
        reflash();
      },
    );
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    this.timer.cancel();
  }
}

class RoundPainter extends CustomPainter {
  List<Offset> offsetList;
  List<double> radiusList;
  Color color;

  RoundPainter({this.offsetList, this.radiusList, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < this.offsetList.length; i++) {
      var paint = new Paint()
        ..color = this.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(this.offsetList[i], this.radiusList[i], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// import 'dart:math';

// import 'package:flutter/material.dart';

// import 'function.dart';

// class Loadbox extends StatefulWidget {
//   final Progress progress;

//   Loadbox({Key key, this.progress}) : super(key: key);

//   @override
//   _LoadboxState createState() => _LoadboxState();
// }

// ///信息描述类 [value]为进度，在0~1之间,进度条颜色[color]，
// ///未完成的颜色[backgroundColor],圆的半径[radius],线宽[strokeWidth]
// ///小点的个数[dotCount] 样式[style] 完成后的显示文字[completeText]
// class Progress {
//   double value;
//   Color color;
//   Color backgroundColor;
//   double radius;
//   double strokeWidth;
//   int dotCount;
//   TextStyle style;
//   String completeText;

//   Progress(
//       {this.value,
//       this.color,
//       this.backgroundColor,
//       this.radius,
//       this.strokeWidth,
//       this.completeText = "OK",
//       this.style,
//       this.dotCount = 40});
// }

// class _LoadboxState extends State<Loadbox> {
//   @override
//   Widget build(BuildContext context) {
//     var progress = Container(
//       width: widget.progress.radius * 2,
//       height: widget.progress.radius * 2,
//       child: CustomPaint(
//         painter: ProgressPainter(widget.progress),
//       ),
//     );
//     String txt = "${(100 * widget.progress.value).toStringAsFixed(1)} %";
//     var text = Text(
//       widget.progress.value == 1.0 ? widget.progress.completeText : txt,
//       style: widget.progress.style ??
//           TextStyle(fontSize: widget.progress.radius / 6),
//     );
//     return Stack(
//       alignment: Alignment.center,
//       children: <Widget>[progress, text],
//     );
//   }
// }

// class ProgressPainter extends CustomPainter {
//   Progress _progress;
//   Paint _paint;
//   Paint _arrowPaint;
//   Path _arrowPath;
//   double _radius;

//   ProgressPainter(
//     this._progress,
//   ) {
//     _arrowPath = Path();

//     _arrowPaint = Paint();
//     _paint = Paint();
//     _radius = _progress.radius - _progress.strokeWidth / 2;
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     Rect rect = Offset.zero & size;
//     canvas.clipRect(rect); //裁剪区域
//     canvas.translate(_progress.strokeWidth / 2, _progress.strokeWidth / 2);

//     drawProgress(canvas);
//     //drawArrow(canvas);
//     //drawDot(canvas);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }

//   drawProgress(Canvas canvas) {
//     //   for (int i = 0; i < this.offsetList.length; i++) {
//     //   var paint = new Paint()
//     //   ..color = this.color
//     //   ..style = PaintingStyle.fill;
//     //   canvas.drawCircle(this.offsetList[i], this.radiusList[i], paint);
//     // }
//     canvas.save();
//     _paint //背景
//       ..style = PaintingStyle.stroke
//       ..color = _progress.backgroundColor
//       ..strokeWidth = _progress.strokeWidth;
//     canvas.drawCircle(Offset(_radius, _radius), _radius, _paint);

//     _paint //进度
//       ..color = _progress.color
//       ..strokeWidth = _progress.strokeWidth * 1.2
//       ..strokeCap = StrokeCap.round;
//     double sweepAngle = _progress.value * 360; //完成角度
//     print(sweepAngle);
//     canvas.drawArc(Rect.fromLTRB(0, 0, _radius * 2, _radius * 2),
//         -90 / 180 * pi, sweepAngle / 180 * pi, false, _paint);
//     canvas.restore();
//   }

//   drawArrow(Canvas canvas) {
//     canvas.save();
//     canvas.translate(_radius, _radius); // 将画板移到中心
//     canvas.rotate((180 + _progress.value * 360) / 180 * pi); //旋转相应角度
//     var half = _radius / 2; //基点
//     var eg = _radius / 50; //单位长
//     _arrowPath.moveTo(0, -half - eg * 2);
//     _arrowPath.relativeLineTo(eg * 2, eg * 6);
//     _arrowPath.lineTo(0, -half + eg * 2);
//     _arrowPath.lineTo(0, -half - eg * 2);
//     _arrowPath.relativeLineTo(-eg * 2, eg * 6);
//     _arrowPath.lineTo(0, -half + eg * 2);
//     _arrowPath.lineTo(0, -half - eg * 2);
//     canvas.drawPath(_arrowPath, _arrowPaint);
//     canvas.restore();
//   }

//   void drawDot(Canvas canvas) {
//     canvas.save();
//     int num = _progress.dotCount;
//     canvas.translate(_radius, _radius);
//     for (double i = 0; i < num; i++) {
//       canvas.save();
//       double deg = 360 / num * i;
//       canvas.rotate(deg / 180 * pi);
//       _paint
//         ..strokeWidth = _progress.strokeWidth / 2
//         ..color = _progress.backgroundColor
//         ..strokeCap = StrokeCap.round;
//       if (i * (360 / num) <= _progress.value * 360) {
//         _paint..color = _progress.color;
//       }
//       canvas.drawLine(
//           Offset(0, _radius * 3 / 4), Offset(0, _radius * 4 / 5), _paint);
//       canvas.restore();
//     }
//     canvas.restore();
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class Loadbox extends StatelessWidget {
//   const Loadbox({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     var boxw = getScreenWidth(context);
//     var boxh = getScreenHeight(context);
//     var boxsize = boxw > boxh ? boxh : boxw;
//     boxsize /= 3.5;
//     Animation<Color> color = ColorTween(
//       begin: Colors.blue[300],
//       end: Colors.blue[900],
//     ).animate(
//       CurvedAnimation(
//         // parent: _controller,
//         curve: Interval(
//           0.5,
//           0.75,
//           curve: Curves.linear,
//         ),
//       ),
//     );
//     var fontstyle = new TextStyle(
//         color: Colors.white,
//         fontSize: 15.0,
//         fontWeight: FontWeight.w100,
//         letterSpacing: 0,
//         height: 1,
//         wordSpacing: 0,
//         decoration: TextDecoration.none);
//     var theam = Container(
//       height: boxsize,
//       width: boxsize,
//       decoration: new BoxDecoration(
//         //背景
//         color: Colors.blue,
//         //设置四周圆角 角度
//         borderRadius: BorderRadius.all(Radius.circular(5.0)),
//         //设置四周边框
//         //border: new Border.all(width: 1, color: Colors.red),
//       ),
//       child: Column(
//         children: <Widget>[
//           Expanded(
//             child: Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: boxsize / 4,
//                 ),
//                 SizedBox(
//                   height: boxsize / 2.5,
//                   width: boxsize / 2.5,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 5.0,
//                     backgroundColor: Colors.blue,
//                     // value: Down.progress,
//                     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),

//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//               child: Center(
//             child: Column(
//               children: <Widget>[
//                 SizedBox(
//                   height: boxsize / 20,
//                 ),
//                 Container(
//                   child: Text(
//                     lang('Loading') + '...',
//                     style: fontstyle,
//                   ),
//                 ),
//               ],
//             ),
//           )),
//           SizedBox(height: 7)
//         ],
//       ),
//     );
//     return Center(child: theam);

//   }
// }
