import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/Novelimage.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/lang.dart';

import 'bookshelf_cloud_widget.dart';

class BookshelfHeader extends StatefulWidget {
  final Novel novel;

  BookshelfHeader(this.novel);

  @override
  _BookshelfHeaderState createState() => _BookshelfHeaderState();
}

class _BookshelfHeaderState extends State<BookshelfHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  String word = '';
  int progressnum = 0;
  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    progresslk();
    progress();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }

  getbookbg2(double w, double h) {
    // double h = width / 0.75;
    var width = w;
    // double h = h;
    var img = Image.asset('assets/images/bookbg.jpg',
        width: width, height: h, fit: BoxFit.fill);
    return Container(
      width: width,
      height: h,
      child: Stack(children: [
        img,
        Positioned(
          top: h * 0.6,
          width: width,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Center(
                  child: Text(widget.novel.name,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl))),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    progress();
    var width = Screen.width;
    var bgHeight = width / 0.9;
    var height = Screen.topSafeHeight + 250;
    var pic = this.widget.novel.imgUrl;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: height - bgHeight,
            child: widget.novel.type == '3'
                ? getbookbg2(width, bgHeight)
                :
                // NgImage(
                //     pic,
                //     width: width,
                //     height: bgHeight,
                //     placeholder: Container(),
                //   ),
                // Novelimage(
                //     widget.novel,
                //     width: width,
                //     height: bgHeight,
                //   ),
                Container(
                    width: width,
                    height: bgHeight,
                    child: widget.novel.imgdom,
                  ),
            //  Image.asset(

            //    'assets/images/bookshelf_bg.png',
            //    fit: BoxFit.cover,
            //    width: width,
            //    height: bgHeight,
            //  ),
          ),
          BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: new Container(
              color: Colors.black12.withOpacity(0.3),
              // width: 300,
              // height: 300,
            ),
          ),
          Positioned(
            bottom: 0,
            child: BookshelfCloudWidget(
              animation: animation,
              width: width,
            ),
          ),
          buildContent(context),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    Novel novel = this.widget.novel;

    var width = Screen.width;
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(15, 54 + Screen.topSafeHeight, 10, 0),
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          //AppNavigator.pushNovelDetail(context, novel);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              child: widget.novel.type == '3'
                  ? getbookbg2(120, 160)
                  : Container(
                      width: 120,
                      height: 160,
                      child: novel.imgdom,
                    ),
              decoration: BoxDecoration(boxShadow: Styles.borderShadow),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40),
                  Text(novel.name,
                      style: TextStyle(
                          fontSize: 20,
                          color: SQColor.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Text(word,
                            style:
                                TextStyle(fontSize: 14, color: SQColor.paper)),
                        onTap: () {
                          widget.novel.read(context, novel.readChapter);
                        },
                      ),
                      Image.asset(
                        'assets/images/bookshelf_continue_read.png',
                        width: 15,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  progresslk() {
    word = lang('还未阅读') + "     " + lang('开始阅读');
  }

  progress() async {
    //读至0.2%     继续阅读 ',progress(),
    progressnum = await this.widget.novel.getprogress();

    if (progressnum == 0) {
      word = lang('还未阅读') + "     " + lang('开始阅读');
    } else {
      word = lang('读至') + progressnum.toString() + "%      " + lang('继续阅读');
    }
  }
}
