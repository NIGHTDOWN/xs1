import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/reader/article_provider2.dart';
import 'package:ng169/page/reader/battery_view.dart';
import 'package:ng169/page/reader/reader_bar.dart';
import 'package:ng169/page/reader/reader_tips.dart';
import 'package:ng169/page/reader/readstat.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/t.dart';
import 'dart:async';
import 'reader_page_agent.dart';
import 'reader_view.dart';
import 'package:ng169/model/user.dart';

// ignore: must_be_immutable
class ReaderScene extends ReadStat {
  final int articleId; //章节id
  final Novel novel; //小说

  ReaderScene(this.novel, this.articleId);

  @override
  void initState() {
    super.initState();
    btter = BatteryView();
    setup();
  }

  void setup() async {
    //章节加载。。
    chaptersResponse = await Chapter.getcatecache(g("context"), novel!);
    // currentArticle = await novel!.getArticle();
    await loadfirstread();
    showload = false;
    loadflag = true;
    reflash();
  }

  //首加载
  //判断有没有闯入id；有加直接跳对应id
  //没有加那之前缓存记录
  Future<void> loadfirstread() async {
    pageIndex = getpoint(articleId)!;

    await resetContent(articleId, PageJumpType.stay);
  }

//预加载

  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (!loadflag) return load;

    if (isnull(currentArticle)) {
      bar = ReaderBar(
          novel, chaptersResponse, currentArticle!, reflash, resetContent);
    } else {
      bar = Container();
    }
    var stack = Stack(children: [
      Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(Styles.getTheme()['bg'], fit: BoxFit.cover)),
      buildPageView(),
      !isnull(getcache('bookshowtips', false)) ? Readertips() : Container(),
    ]);
    var children2 = <Widget>[
      Loadbox(
        loading: showload,
        child: stack,
        hasmask: false,
      ),
      bar
    ];

    return Scaffold(
      key: readkey,
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          // ignore: deprecated_member_use
          child: WillPopScope(
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
            ),
          )),
    );
  }

  //页面渲染
  buildPageView() {
    page = PageView(
      scrollDirection: fx == '1' ? Axis.horizontal : Axis.vertical,
      physics: BouncingScrollPhysics(),
      controller: pageController,
      children: <Widget>[
        // drag,
        pagecontent1(),
        pagecontent(),
        pagecontent2(),
      ],
    );

    return GestureDetector(
      child: page,
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

  //当前页面渲染
  pagecontent() {
    if (!isnull(currentArticle)) return kongbai;
    Widget obj = ReaderView(
        novel: novel,
        article: currentArticle!,
        battery: btter,
        page: pageIndex,
        topSafeHeight: topSafeHeight);
    catelog(currentArticle);
    return obj;
  }

  //前一页渲染
  pagecontent1() {
    if (!isnull(currentArticle)) return kongbai;

    if ((pageIndex - 1) >= 0) {
      return ReaderView(
          novel: novel,
          article: currentArticle!,
          battery: btter,
          page: pageIndex - 1,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(preArticle)) {
        return ReaderView(
            novel: novel,
            article: preArticle!,
            battery: btter,
            page: preArticle!.pageCount - 1,
            topSafeHeight: topSafeHeight);
      } else {
        return kongbai;
      }
    }
  }

  //下一页渲染
  pagecontent2() {
    var tmpindex = pageIndex + 1;
    if (!isnull(currentArticle)) return kongbai;
    int ccount = currentArticle!.pageCount - 1;

    if (tmpindex <= ccount) {
      return ReaderView(
          novel: novel,
          article: currentArticle!,
          page: tmpindex,
          battery: btter,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(nextArticle)) {
        return ReaderView(
            novel: novel,
            article: nextArticle!,
            battery: btter,
            page: 0,
            topSafeHeight: topSafeHeight);
      } else {
        return kongbai;
      }
    }
  }
}
