import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'dart:async';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/commect/addcomment.dart';
import 'package:ng169/page/commect/wrong.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/style/screen.dart' as screenstyle;

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

import '../../style/screen.dart';

class ReaderMenu extends StatefulWidget {
  final List<dynamic> chapters;
  final int articleIndex;
  final Novel novel;

  final VoidCallback onTap;
  final VoidCallback onPreviousArticle;
  final VoidCallback onNextArticle;
  final VoidCallback showcate;
  final VoidCallback showset;
  final void Function(dynamic chapter) onToggleChapter;
  final void Function(String theme) onToggleTheme;

  ReaderMenu(
      {required this.chapters,
      required this.articleIndex,
      required this.onTap,
      required this.onPreviousArticle,
      required this.onNextArticle,
      required this.onToggleChapter,
      required this.novel,
      required this.showcate,
      required this.showset,
      required this.onToggleTheme});

  @override
  _ReaderMenuState createState() => _ReaderMenuState();
}

class _ReaderMenuState extends State<ReaderMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  double progressValue = 1;
  bool isTipVisible = false;
  String title = "";
  late List<dynamic> chapters;
  double lightValue = 0.0;
  late int size;
  //初始化动画
  @override
  initState() {
    super.initState();

    chapters = this.widget.chapters ?? [];
    if (!isnull(chapters)) {
      size = this.widget.novel.chapterCount - 1;
    } else {
      size = chapters.length - 1;
    }

    if (size < 1) {
      size = 1;
    }
    progressValue = checkpross(this.widget.articleIndex / size);
    initpross();
    getUserBrightnessConfig();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animation.addListener(() {
      setState(() {});
    });
    animationController.forward();
  }

  checkpross(progressValue) {
    if (progressValue < 0) {
      progressValue = 0.0;
    }
    if (progressValue > 1) {
      progressValue = 1.0;
    }
    return progressValue;
  }

  initpross() async {
    if (!isnull(this.widget.chapters)) {
      chapters = await Chapter.getcatecache(context, this.widget.novel);

      if (isnull(chapters) && chapters.length > 1) {
      } else {}
    } else {}

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(ReaderMenu oldWidget) {
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
      top: -screenstyle.Screen.navigationBarHeight * (1 - animation.value),
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
            color: Styles.getTheme()['barcolor'],
            boxShadow: Styles.borderShadow),
        height: screenstyle.Screen.navigationBarHeight,
        padding: EdgeInsets.fromLTRB(5, screenstyle.Screen.topSafeHeight, 5, 0),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Styles.getTheme()['barfontcolor'],
                  )),
            ),
            Expanded(child: Container()),
            // Icon(Icons.report),
            GestureDetector(
              onTap: () {
                Chapter chapter = Chapter.fromJson(
                    chapters[currentArticleIndex()], currentArticleIndex());
                gourl(
                    context,
                    AddWrong(
                        novel: this.widget.novel, secid: chapter.section_id));
              },
              child: Container(
                width: 44,
                child: Icon(
                  Icons.error_outline,
                  color: Styles.getTheme()['barfontcolor'],
                ),
              ),
            ),
            Container(
              width: 44,
              child: GestureDetector(
                  onTap: share,
                  child: Icon(
                    Icons.share,
                    color: Styles.getTheme()['barfontcolor'],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  share() {
    this.widget.onTap();
    sharefun(widget.novel);
  }

  //获取当前章节索引
  int currentArticleIndex() {
    return ((chapters.length - 1) * progressValue).toInt();
  }

//显示选中章节标题
  buildProgressTipView() {
    if (!isTipVisible) {
      return Container();
    }

    Chapter chapter = Chapter.fromJson(
        chapters[currentArticleIndex()], currentArticleIndex());

    double percentage = chapter.index / size * 100;
    return Container(
      decoration: BoxDecoration(
          color: Styles.getTheme()['activecolor'],
          borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              isnull(title) ? title : chapter.title,
              style: TextStyle(
                  color: Styles.getTheme()['activefontcolor'], fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                  color: Styles.getTheme()['activefontcolor'], fontSize: 12)),
        ],
      ),
    );
  }

  previousArticle() async {
    if (this.widget.articleIndex == 0) {
      show(context, lang('已经是第一章了'));
      return;
    }
    this.widget.onPreviousArticle();
    var index =
        int.parse(Chapter.getReadSecId(widget.novel.id, widget.novel.type));
    setState(() {
      title = chapters[index - 1]['title'];

      isTipVisible = true;
    });
  }

  nextArticle() async {
    if (this.widget.articleIndex == chapters.length - 1) {
      show(context, lang('已经是最后一章了'));
      // gourl(context, Lastpage(widget.novel));
      return;
    }
    this.widget.onNextArticle();
    var index =
        int.parse(Chapter.getReadSecId(widget.novel.id, widget.novel.type));
    setState(() {
      title = chapters[index + 1]['title'];
      isTipVisible = true;
    });
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  buildProgressView() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: previousArticle,
            child: Container(
              padding: EdgeInsets.all(20),
              // child: Image.asset(
              //   'assets/images/read_icon_chapter_previous.png',
              //   color: Styles.getTheme()['barfontcolor'],
              // ),
              child: Icon(Icons.keyboard_arrow_left,
                  size: 30, color: Styles.getTheme()['barfontcolor']),
            ),
          ),
          Expanded(
            child: Slider(
              value: progressValue,
              onChanged: (double value) {
                setState(() {
                  title = '';
                  isTipVisible = true;
                  progressValue = value;
                });
              },
              onChangeEnd: (double value) {
                //Chapter chapter = this.widget.chapters[currentArticleIndex()];
                Chapter chapter = Chapter.fromJson(
                    chapters[currentArticleIndex()], currentArticleIndex());
                this.widget.onToggleChapter(chapter);
              },
              activeColor: Styles.getTheme()['activecolor'],
              inactiveColor: Styles.getTheme()['barfontcolor'],
            ),
          ),
          GestureDetector(
            onTap: nextArticle,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Icon(Icons.keyboard_arrow_right,
                  size: 30, color: Styles.getTheme()['barfontcolor']),
              // child: Image.asset(
              //   'assets/images/read_icon_chapter_next.png',
              //   color: Styles.getTheme()['barfontcolor'],
              // ),
            ),
          )
        ],
      ),
    );
  }

  buildlightProgressView() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: setUserBrightnessjian,
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
              child: Icon(
                Icons.brightness_low,
                color: Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: lightValue,
              min: 0,
              max: 10,
              onChanged: (double value) {
                setUserBrightnessConfig(value);
                setState(() {
                  isTipVisible = true;
                });
              },
              onChangeEnd: (double value) {
                setUserBrightnessConfig(value);
                setState(() {
                  isTipVisible = true;
                });
              },
              activeColor: Styles.getTheme()['activecolor'],
              inactiveColor: Styles.getTheme()['barfontcolor'],
            ),
          ),
          GestureDetector(
            onTap: setUserBrightnessadd,
            child: Container(
              //padding: EdgeInsets.all(20),
              child: Icon(
                Icons.brightness_high,
                // 'assets/images/read_icon_chapter_next.png',
                color: Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: setUserBrightnessauto,
            child: Container(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.brightness_auto,
                // 'assets/images/read_icon_chapter_next.png',
                color: isnull(getcache(autolight))
                    ? Styles.getTheme()['activecolor']
                    : Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildBottomView() {
    return Positioned(
      bottom:
          -(screenstyle.Screen.bottomSafeHeight + 110) * (1 - animation.value),
      left: 0,
      right: 0,
      child: Column(
        children: <Widget>[
          buildProgressTipView(),
          Container(
            decoration: BoxDecoration(
                color: Styles.getTheme()['barcolor'],
                boxShadow: Styles.borderShadow),
            padding:
                EdgeInsets.only(bottom: screenstyle.Screen.bottomSafeHeight),
            child: Column(
              children: <Widget>[
                widget.novel.type == '2'
                    ? buildlightProgressView()
                    : Container(),
                buildProgressView(),
                //漫画添加亮度控制

                buildBottomMenus(),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildBottomMenus() {
    if (widget.novel.type == '2') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: buildBottomItem2(lang('目录'), Icons.menu),
            onTap: () {
              // hide();
              widget.showcate();
            },
          ),
          GestureDetector(
            child: !isnull(getcache(isnight))
                ? buildBottomItem2(lang('夜间'), Icons.brightness_4)
                : buildBottomItem2(lang('日间'), Icons.wb_sunny),
            onTap: () {
              widget.onToggleTheme('th6');
              setState(() {});
            },
          ),
          GestureDetector(
            onTap: () {
              hide();
              gourl(
                  context,
                  AddComment(
                    novel: widget.novel,
                  ));
            },
            child: buildBottomItem2(lang('评论'), Icons.message),
          ),
        ],
      );
    }
    if (widget.novel.type == '3') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: buildBottomItem2(lang('目录'), Icons.menu),
            onTap: () {
              // hide();
              widget.showcate();
            },
          ),
          GestureDetector(
            child: !isnull(getcache(isnight))
                ? buildBottomItem2(lang('夜间'), Icons.brightness_4)
                : buildBottomItem2(lang('日间'), Icons.wb_sunny),
            onTap: () {
              widget.onToggleTheme('th6');
              setState(() {});
            },
          ),
          GestureDetector(
            child: buildBottomItem2(lang('设置'), Icons.settings),
            onTap: widget.showset,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        GestureDetector(
          child: buildBottomItem2(lang('目录'), Icons.menu),
          onTap: () {
            // hide();
            widget.showcate();
          },
        ),
        GestureDetector(
          child: !isnull(getcache(isnight))
              ? buildBottomItem2(lang('夜间'), Icons.brightness_4)
              : buildBottomItem2(lang('日间'), Icons.wb_sunny),
          onTap: () {
            widget.onToggleTheme('th6');
            setState(() {});
          },
        ),
        GestureDetector(
          child: buildBottomItem2(lang('设置'), Icons.settings),
          onTap: widget.showset,
        ),
        GestureDetector(
          onTap: () {
            hide();
            gourl(
                context,
                AddComment(
                  novel: widget.novel,
                ));
          },
          child: buildBottomItem2(lang('评论'), Icons.message),
        ),
      ],
    );
  }

  buildBottomItem2(String title, IconData incons) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          // Image.asset(icon),
          Icon(
            incons,
            color: Styles.getTheme()['barfontcolor'],
          ),
          SizedBox(height: 5),
          Text(title,
              style: TextStyle(
                  fontSize: fixedFontSize(12),
                  color: Styles.getTheme()['barfontcolor'])),
        ],
      ),
    );
  }

  buildBottomItem(String title, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          Image.asset(icon),
          SizedBox(height: 5),
          Text(title,
              style: TextStyle(
                  fontSize: fixedFontSize(12), color: SQColor.darkGray)),
        ],
      ),
    );
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
          ),
          widget.novel.type == '3' ? SizedBox() : buildTopView(context),
          buildBottomView(),
        ],
      ),
    );
  }

  Future<double> getUserBrightnessConfig() async {
    lightValue = await Screen.brightness;
    return lightValue;
  }

  void setUserBrightnessConfig(double data) async {
    Screen.setBrightness(data);
    lightValue = data;
    setcache(autolight, 0, '-1');
    reflash();
  }

  void setUserBrightnessadd() async {
    lightValue = lightValue + 0.05;
    if (lightValue > 1) {
      lightValue = 1.0;
    }
    setcache(autolight, 0, '-1');
    Screen.setBrightness(lightValue);
    reflash();
  }

  void setUserBrightnessauto() async {
    if (!isnull(getcache(autolight))) {
      setcache(autolight, 1, '-1');
      Screen.setBrightness(-1.0);
    } else {
      setcache(autolight, 0, '-1');
      Screen.setBrightness(lightValue);
    }

    reflash();
  }

  void setUserBrightnessjian() async {
    lightValue = lightValue - 0.05;
    if (lightValue <= 0) {
      lightValue = 0.0;
    }
    setcache(autolight, 0, '-1');
    Screen.setBrightness(lightValue);

    reflash();
  }
}
