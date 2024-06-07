import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ng169/model/article.dart';
import 'package:ng169/model/user.dart';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/page/reader/article_provider2.dart';
import 'package:ng169/page/reader/reader_bar.dart';
import 'package:ng169/page/reader/reader_scene.dart';
import 'package:ng169/page/reader/reader_tips_car.dart';
import 'package:ng169/page/smallwidget/gifcartoon.dart';
import 'package:ng169/page/smallwidget/gifcartoon2.dart';

import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';

import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/jsq.dart';
import 'package:ng169/tool/lang.dart';

import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/t.dart';
import 'dart:async';
import 'battery_view.dart';

import 'cartoon_view.dart';
import 'readstat.dart';

class CartReaderScene extends ReadStat {
  final int articleId; //章节id
  final Novel novel; //小说

  CartReaderScene(this.novel, this.articleId);
  @override
  void initState() {
    super.initState();

    setup();
  }

  getnowpage() {
    double index = pageController.position.pixels /
        pageController.position.maxScrollExtent *
        currentArticle!.pageCount;
    if (index.toString() == 'NaN') {
      return;
    }
    if (index <= 1.0) {
      index = 1.0;
    }
    if (index >= currentArticle!.pageCount) {
      index = currentArticle!.pageCount.toDouble();
    }
    pageIndex = int.parse(index.toStringAsFixed(0));
    setpoint(currentArticle);
    reflash();
  }

  onScroll() {
    //上一页

    //当前页面

    //记录当前页面
    getnowpage();
    if (pageController.page! > 1.0) {}
  }

  Future<Article?> next() async {
    if (isnull(currentArticle!.nextArticleId)) {
      await resetContent(currentArticle!.nextArticleId, PageJumpType.firstPage);
    }
    return null;
  }

  Future<Article?> pre() async {
    if (isnull(currentArticle!.preArticleId)) {
      await resetContent(currentArticle!.preArticleId, PageJumpType.lastPage);
    }
    return null;
  }

  void setup() async {
    chaptersResponse = await Chapter.getcatecache(g("context"), novel!);
    // currentArticle = await novel!.getArticle();
    await loadfirstread();
    showload = false;
    loadflag = true;
    reflash();
  }

  Future<void> loadfirstread() async {
    pageIndex = getpoint(articleId)!;

    await resetContent(articleId, PageJumpType.stay);
  }

  Widget cartoonload() {
    // return Container();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('全屏白色背景'),
      // ),
      body: Container(
        color: SQColor.white,
        child: Center(
          child: GifCartoon2(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showload) {
      return cartoonload();
    }

    var children2 = <Widget>[
      buildPageView(),
      topinfo(),
      ReaderBar(
          novel, chaptersResponse, currentArticle!, reflash, resetContent),
      !isnull(getcache('carshowtips', false)) ? Readertipscar() : Container(),
    ];

    return Scaffold(
        // ignore: deprecated_member_use
        body: WillPopScope(
            onWillPop: () {
              if (isnull(novel.isgroom)) {
                pop(context);
              } else {
                if (User.islogin()) {
                  showbox(box, Color(0x00ffffff));
                } else {
                  pop(context);
                }
              }
              return Future.value(false);
            },
            child: Stack(
              children: children2,
            )));
  }

  topinfo() {
    Color color = Styles.getTheme()['titlefontcolor'];
    DateTime today = new DateTime.now();
    String time = today.hour.toString().padLeft(2, '0') +
        ":" +
        today.minute.toString().padLeft(2, '0');
    return Positioned(
        top: 0,
        child: Container(
          width: getScreenWidth(this.context!),
          color: Styles.getTheme()['barcolor'],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 18,
              ),
              //时间
              Text(time,
                  style: TextStyle(fontSize: fixedFontSize(11), color: color)),
              //章节
              Expanded(child: Container()),
              Text(
                  // '${widget.page + 1}/' + widget.article.pageCount.toString(),
                  currentArticle!.title,
                  style: TextStyle(fontSize: fixedFontSize(11), color: color)),
              //分页
              Expanded(child: Container()),
              Text('${pageIndex}/' + currentArticle!.pageCount.toString(),
                  style: TextStyle(fontSize: fixedFontSize(11), color: color)),
              SizedBox(
                width: 3,
              ),
              BatteryView(),
            ],
          ),
        ));
  }

  //页面渲染
  buildPageView() {
    return GestureDetector(
      child: pagecontent(),
      onTapUp: (TapUpDetails details) {
        onTap(details.globalPosition);
      },
      //下面是手势
      onPanDown: (DragDownDetails details) {
        // percentageAnimationControllerpercentageAnimationController.forward(from: 0.0);
      },
      onPanEnd: (DragEndDetails details) {
        //  d(details);
      },
      onPanUpdate: (DragUpdateDetails details) {
        // d(details);
      },
    );
  }

  //屏幕点击事件
  onTap(Offset position) async {
    //点击翻页或者弹出菜单

    //hidetitlebar();
    double xRate = position.dy / Screen.height;

    var time = 100;
    if ((xRate > 0.33 && xRate < 0.66)) {
      //显示菜单
      // isMenuVisiable = true;
      s('isMenuVisiable', true);
      reflash();
    } else if (xRate >= 0.66) {
      //下一页
      // pageController.animateToPage(2,
      //     duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    } else {
      //上一页
      // pageController.animateToPage(0,
      //     duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    }
  }

  bool islock = false;
  lock() {
    islock = true;
    reflash();
  }

  unlock() {
    islock = false;
    reflash();
  }

  showmenu() {
    // isMenuVisiable = true;
    s('isMenuVisiable', true);
    reflash();
  }

  //当前页面渲染
  pagecontent() {
    if (!isnull(currentArticle)) return kongbai;

// d(currentArticle);
    Widget obj = CartoonView(
      novel: novel,
      article: currentArticle!,
      page: pageIndex,
      topSafeHeight: topSafeHeight,
      scroll: onScroll,
      showmenu: showmenu,
      next: next,
      pre: pre,
      lock: lock,
      unlock: unlock,
      islock: islock,
      pageController: pageController,
    );
    if (!isnull(obj)) {
      return kongbai;
    }
    catelog(currentArticle);
    return obj;
  }
}
