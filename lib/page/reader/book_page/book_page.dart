import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'dart:ui' as ui;

import 'book_painter.dart';
import 'cal_point.dart';

class BookPage extends StatefulWidget {
  Article preArticle, currentArticle, nextArticle;
  int pageIndex;
  BookPage(
      this.preArticle, this.currentArticle, this.nextArticle, this.pageIndex);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage>
    with SingleTickerProviderStateMixin {
  CalPoint curPoint = CalPoint.data(-1, -1);
  CalPoint prePoint = CalPoint.data(-1, -1);
  String content, content2;
  PositionStyle style = PositionStyle.STYLE_LOWER_RIGHT;
  double width;
  double height;
  AnimationController animationController;
  Animation cancelAnim;
  Tween cancelValue;
  bool needCancelAnim = true;

  ui.Image bgimage;

  toNormal([_]) {
    if (needCancelAnim) {
      startCancelAnim();
    } else {
      setState(() {
        style = PositionStyle.STYLE_LOWER_RIGHT;
        prePoint = CalPoint.data(-1, -1);
        curPoint = CalPoint.data(-1, -1);
      });
    }
  }

  toDragUpdate(d) {
    var x = d.localPosition.dx;
    var y = d.localPosition.dy;
    setState(() {
      curPoint = CalPoint.data(x, y);
    });
  }

  toDown(TapDownDetails dd) {
    prePoint = CalPoint.data(-1, -1);
    var dy = dd.localPosition.dy;
    var dx = dd.localPosition.dx;

    if (dx <= width / 3) {
      //左
      d(1);
      style = PositionStyle.STYLE_LEFT;
    } else if (dx > width / 3 && dy <= height / 3) {
      //上
      style = PositionStyle.STYLE_TOP_RIGHT;
    } else if (dx > width * 2 / 3 && dy > height / 3 && dy <= height * 2 / 3) {
      //右
      style = PositionStyle.STYLE_RIGHT;
    } else if (dx > width / 3 && dy > height * 2 / 3) {
      //下
      d('下');
      style = PositionStyle.STYLE_LOWER_RIGHT;
    } else if (dx > width / 3 &&
        dx < width * 2 / 3 &&
        dy > height / 3 &&
        dy < height * 2 / 3) {
      //中
      d('中');
      // style = PositionStyle.STYLE_MIDDLE;
    }

    var x = dd.localPosition.dx;
    var y = dd.localPosition.dy;
    setState(() {
      curPoint = CalPoint.data(x, y);
    });
  }

  startCancelAnim() {
    double dx, dy;
    if (style == PositionStyle.STYLE_TOP_RIGHT) {
      dx = (width - 1 - prePoint.x);
      dy = (1 - prePoint.y);
    } else if (style == PositionStyle.STYLE_LOWER_RIGHT) {
      dx = (width - 1 - prePoint.x);
      dy = (height - 1 - prePoint.y);
    } else {
      dx = prePoint.x - width;
      dy = -prePoint.y;
    }
    cancelValue =
        Tween(begin: Offset(prePoint.x, prePoint.y), end: Offset(dx, dy));
    animationController.forward();
  }

  _initCancelAnim() {
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    cancelAnim = animationController.drive(CurveTween(curve: Curves.linear));
    cancelAnim
      ..addListener(() {
        if (animationController.isAnimating) {
          setState(() {
            var bdx = cancelValue.begin.dx;
            var bdy = cancelValue.begin.dy;

            var edx = cancelValue.end.dx;
            var edy = cancelValue.end.dy;

            curPoint = CalPoint.data(
                bdx + edx * cancelAnim.value, bdy + edy * cancelAnim.value);
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            style = PositionStyle.STYLE_LOWER_RIGHT;
            prePoint = CalPoint.data(-1, -1);
            curPoint = CalPoint.data(-1, -1);
            animationController.reset();
          });
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _initCancelAnim();
    getimg();
    initstringx();
  }

  initstringx() {
    // content = widget.currentArticle.stringAtPageIndex(widget.pageIndex);
    if(!isnull(widget.currentArticle)){
      return ;
    }
    int ccount = widget.currentArticle.pageCount - 1;
   
    int page2 = widget.pageIndex + 1;
    //未支付的显示截取部分
    if (widget.currentArticle.pay) {
      content = widget.currentArticle.stringAtPageIndex(widget.pageIndex);
      if (ccount >= page2) {
        content2 = widget.currentArticle.stringAtPageIndex(page2);
      } else {
        if (widget.nextArticle.pay) {
          content2 = widget.nextArticle.stringAtPageIndex(0);
        } else {
          content2 = widget.nextArticle.contenttmp;
        }
      }
    } else {
      content = widget.currentArticle.contenttmp;
      if (widget.nextArticle.pay) {
        content2 = widget.nextArticle.stringAtPageIndex(0);
      } else {
        content2 = widget.nextArticle.contenttmp;
      }
    }
  }

  getimg() async {
    bgimage = (await getAssetImage(Styles.getTheme()['bg']));
    // reflash();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    initstringx();
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Color bgColor = Colors.white;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: GestureDetector(
          onTapDown: toDown,
          onTapUp: toNormal,
          onPanEnd: toNormal,
          onPanCancel: toNormal,
          onPanUpdate: toDragUpdate,
          child: CustomPaint(
            painter: BookPainter(
              text: content,
              text2: content2,
              viewWidth: width,
              viewHeight: height,
              cur: curPoint,
              pre: prePoint,
              style: style,
              bgColor: bgColor,
              frontColor: Color(0x00333333),
              limitAngle: true,
              changedPoint: (pre) {
                // d(pre);
                prePoint = pre;
              },
              images: bgimage,
            ),
          ),
        ),
      ),
    );
  }
}

// const content = """林语堂\n
// 一、腰有十文钱必振衣作响；\n

// 二、每与人言必谈及贵戚；\n

// 三、遇美人必急索登床；\n

// 四、见到问路之人必作傲睨之态；\n

// 五、与朋友相聚便喋喋高吟其酸腐诗文；\n

// 六、头已花白却喜唱艳曲；\n

// 七、施人一小惠便广布于众；\n

// 八、与人交谈便借刁言以逞才；\n

// 九、借人之债时其脸如丐，被人索偿时则其态如王；\n

// 十、见人常多蜜语而背地却常揭人短处。""";

// const content2 = """林语堂\n
// 1.人本过客来无处，休说故里在何方。随遇而安无不可，人间到处有芳香。——林语堂\n
// 2.人生不过如此，且行且珍惜。自己永远是自己的主角，不要总在别人的戏剧里充当着配角。——林语堂《人生不过如此》\n
// 3.最明亮时总是最迷茫，最繁华时也是最悲凉。——林语堂《京华烟云》\n
// 4.理想的人并不是完美的人，通常只是受人喜爱，并且通情达理的人，而我只是努力去接近于此罢了。——林语堂""";

// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BookPage extends StatefulWidget {
//   @override
//   _LALPageNewsState createState() => _LALPageNewsState();
// }

// class _LALPageNewsState extends State<BookPage> {
//   Uint8List imageMemory;//先定义一个uint8list对象
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           //点击按钮，点击后显示
//           RaisedButton(
//               onPressed:() async{
//                 ui.PictureRecorder pictureRecorder = new ui.PictureRecorder(); // 图片记录仪
//                 Canvas canvas = new Canvas(pictureRecorder); //canvas接受一个图片记录仪
//                 //第一个ui.image对象 给canvas.drawimage使用
//                 ui.Image images = await getAssetImage('assets/images/th4.jpg'); // 使用方法获取ui.Image格式的图片
//                 Paint _linePaint = new Paint()
//                   ..color = Colors.blue
//                   ..style = PaintingStyle.fill
//                   ..isAntiAlias = true//抗锯齿
//                   ..strokeCap = StrokeCap.round//线条末端的处理方式
//                   ..strokeWidth =20.0;
//                 // 绘制图片
//                 canvas.drawImage(images, Offset(0, 0), _linePaint); // 直接画图
// 			  //第二个 ui.Image对象 由pictureRecorder结束记录后返回  toImage裁剪图片
//                 ui.Image picture = await pictureRecorder.endRecording().toImage(500, 1334);//设置生成图片的宽和高
//                 //ByteData对象 转成 Uint8List对象 给 Image.memory() 使用来显示
//                 ByteData pngImageBytes = await picture.toByteData(format: ui.ImageByteFormat.png);
//                 //Uint8List imgBytes = Uint8List.view(pngImageBytes.buffer); //这一行和下面这一行都是生成Uint8List格式的图片
//                 Uint8List pngBytes = pngImageBytes.buffer.asUint8List();
//                 setState(() {
//                   imageMemory = pngBytes;
//                 });
//               },
//             child: Text("生成图片"),
//           ),
//           imageMemory != null ? Image.memory(imageMemory) : Text('loading...'),
//         ],
//       ),
//     );
//   }
// }
// //返回ui.Image
// Future<ui.Image> getAssetImage(String asset,{width,height}) async {
//   ByteData data = await rootBundle.load(asset);
//   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetWidth: 		width,targetHeight: height);
//   ui.FrameInfo fi = await codec.getNextFrame();
//  return fi.image;
// }
