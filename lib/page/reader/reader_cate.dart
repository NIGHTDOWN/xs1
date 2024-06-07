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
      {required this.chapters,
      required this.articleIndex,
      required this.onTap,
      required this.onPreviousArticle,
      required this.onNextArticle,
      required this.onToggleChapter,
      required this.novel});

  @override
  _ReaderCateState createState() => _ReaderCateState();
}

class _ReaderCateState extends State<ReaderCate>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  late double progressValue;
  bool isTipVisible = false;
  late String title;
  //初始化动画
  @override
  initState() {
    super.initState();

    progressValue =
        this.widget.articleIndex / (this.widget.chapters.length + 1);

    animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(animationController);

    animation.addListener(() {
      setState(() {});
    });
    animationController.forward();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
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
            // child: Container(color: Colors.red),
          ),
          buildTopView(context),
          // buildBottomView(),
        ],
      ),
    );
  }
}
