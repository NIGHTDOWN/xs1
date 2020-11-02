import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';

import 'incatalog.dart';

class ReaderCate extends StatefulWidget {
  final List<dynamic> chapters;
  final int articleIndex;
  final Novel novel;

  final VoidCallback onTap;
  final VoidCallback onPreviousArticle;
  final VoidCallback onNextArticle;
  final void Function(dynamic chapter) onToggleChapter;

  ReaderCate(
      {this.chapters,
      this.articleIndex,
      this.onTap,
      this.onPreviousArticle,
      this.onNextArticle,
      this.onToggleChapter,
      this.novel});

  @override
  _ReaderCateState createState() => _ReaderCateState();
}

class _ReaderCateState extends State<ReaderCate>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  double progressValue;
  bool isTipVisible = false;
  String title;
  //初始化动画
  @override
  initState() {
    super.initState();

    progressValue =
        this.widget.articleIndex / (this.widget.chapters.length - 1);

    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(animationController);

    animation.addListener(() {
      setState(() {});
    });
    animationController.forward();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    // progressValue =
    //     this.widget.articleIndex / (this.widget.chapters.length - 1);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //隐藏菜单
  hide() {
    animationController.reverse();
    Timer(Duration(milliseconds: 200), () {
      this.widget.onTap();
    });
    setState(() {
      isTipVisible = false;
    });
  }

  //顶部栏
  buildTopView(BuildContext context) {
    return Positioned(
      top: 0,
      left: -getScreenWidth(context) * (animation.value),
      right: getScreenWidth(context) * (.15 + .85 * animation.value),
      child: Container(
          decoration: BoxDecoration(
              color: SQColor.paper, boxShadow: Styles.bordercateShadow),
          height: getScreenHeight(context),
          // width: 50,
          child: InCataLog(
            novel: widget.novel,
            clickChapter: click,
          )),
    );
  }

  click(Chapter chapter) {
    //点击过来
    this.widget.onToggleChapter(chapter);
    hide();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTapDown: (_) {
              hide();
            },
            child: Container(color: Colors.transparent),
            //child: Container(color: Colors.red),
          ),
          buildTopView(context),
          // buildBottomView(),
        ],
      ),
    );
  }
}
