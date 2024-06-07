import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/article.dart';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/reader/article_provider2.dart';
import 'package:ng169/page/reader/lastpage.dart';
import 'package:ng169/page/reader/reader_bar.dart';
import 'package:ng169/page/reader/reader_tips.dart';

import 'package:ng169/page/smallwidget/gifload2.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/jsq.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';
import 'package:ng169/tool/url.dart';

import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/t.dart' as dbt;
import 'dart:async';

import 'battery_view.dart';

import 'reader_page_agent.dart';
import 'reader_view.dart';

enum PageJumpType { stay, firstPage, lastPage }

// ignore: must_be_immutable
abstract class ReadStat extends StatefulWidget {
  late State<ReadStat> state;
  late BuildContext? context;
  bool mounted = false;
  Function setState = () {};
  Function reflash = () {};
  @override
  createState() => _ReadStatState();
  @protected
  Widget build(BuildContext context);
  int pageIndex = 0;
  int articleIndex = 0;
  bool islast = false;
  Novel? novel;
  PageController pageController =
      PageController(keepPage: false, initialPage: 1);
  bool isLoading = false, isFirst = true;
  GlobalKey readkey = new GlobalKey();
  double topSafeHeight = 0;
  late Article? preArticle = null;
  late Article? currentArticle = null;
  late Article? nextArticle = null;
  late Widget bar;
  List<Chapter> chapters = [];
  List chaptersResponse = [];
  Widget kongbai = SizedBox();
  late String fx;
  bool showload = true;
  final loadkey = GlobalKey<LoadboxState>();
  late CustomPainter mPainter;
  GlobalKey canvasKey = new GlobalKey();
  late AnimationController percentageAnimationController;
  Widget btter = SizedBox();
  late Widget box;
  Widget load = Scaffold(
    body: Container(
      color: SQColor.white,
      child: Center(
        child: Gifload2(),
      ),
    ),
  );
  bool loadflag = false;
  var page;

  void initState() {
    getfx();
    sysinit();
    pageController.addListener(onScroll);
    initaddgrombox();
    Jsq()..start();
  }

  getfx() {
    fx = isnull(getcache(readfx)) ? getcache(readfx).toString() : '1';
  }

  double getpage() {
    if (fx == '2') {
      //上下滑动
      return pageController.offset / Screen.height;
    }
    return pageController.offset / Screen.width;
  }

  onScroll() {
    //上一页

    if (pageController.page == 0.0) {
      previousPage();
      pageController.jumpToPage(1);
    }
    //下一页
    if (pageController.page == 2.0) {
      nextPage();
      pageController.jumpToPage(1);
    }

    if (pageIndex == 0 &&
        currentArticle!.preArticleId == 0 &&
        pageController.page! < 0.6) {
      show(context, lang('已经是第一页了'));
      pageController.jumpToPage(1);
      return;
    }
    if (isnull(currentArticle)) {
      if (pageIndex >= currentArticle!.pageCount - 1 &&
          currentArticle!.nextArticleId == 0 &&
          pageController.page! > 1.4) {
        golast(novel!);
        return;
      }
    }

    //当前页面
    if (pageController.page == 1.0) {}
  }

  golast(Novel novel) async {
    if (!islast) {
      islast = true;
      await gourl(context!, Lastpage(novel));
      islast = false;
    }
  }

  void dispose() {
    Jsq()..end();
    showtitlebar();
    eventBus.off('read_reflash');
    Screen.keepOn(false); //屏幕常亮
    try {
      pageController.dispose();
    } catch (e) {}
  }

  sysinit() async {
    await hidetitlebar();
    titlebarcolor(false);
    Screen.keepOn(true); //屏幕常亮
    s('isMenuVisiable', false);
    await Future.delayed(const Duration(milliseconds: 100), () {});
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    topSafeHeight = Screen.topSafeHeight;
    eventBus.on('read_reflash', (arg) {
      reflash();
    });
  }

  //获取章节页面定位
  int? getpoint(sectionId) {
    var cache = pageindexk + novel!.id + novel!.type + tostring(sectionId);
    var tmp = getcache(cache);
    if (!isnull(tmp)) return 0;
    return toint(tmp);
  }

  //获取章节内容，并且预加载前后两章
  resetContent(int index, PageJumpType jumpType) async {
    //目录定位
    //获取当前章节内容
    showload = true;
    reflash();
    currentArticle = (await fetchArticle(index));
    if (!isnull(currentArticle)) {
      //章节内容不存在，跳一章
      var v = novel;
      var tmp = await dbt
          .T('sec')
          .where({'book_id': v?.id, 'booktype': v?.type})
          .wherestring(' `index`> ' + index.toString())
          .order('`index` asc')
          .getone();
      if (isnull(tmp)) {
        currentArticle = (await fetchArticle(tmp['index']));
      }
    }
    if (!isnull(currentArticle)) {
      //重试获取下一章还是失败，则退出。
      showload = false;
      reflash();
      return;
    }
    novel!.setcur(currentArticle!.index);
    showload = false;
    reflash();

    if (jumpType == PageJumpType.firstPage) {
      //跳首页
      pageIndex = 0;
    } else if (jumpType == PageJumpType.lastPage) {
      //跳最后一页
      pageIndex = currentArticle!.pageCount - 1;
    }
    fetchPreviousArticle(currentArticle!.preArticleId);
    fetchNextArticle(currentArticle!.nextArticleId);
    showload = false;
    loadflag = true;
    reflash();
  }

  fetchPreviousArticle(int articleId) async {
    if (isnull(articleId)) {
      preArticle = (await fetchArticle(articleId))!;
    } else {
      preArticle = null;
    }
    reflash();
  }

  fetchNextArticle(int articleId) async {
    if (isnull(articleId)) {
      nextArticle = (await fetchArticle(articleId))!;
    } else {
      nextArticle = null;
    }
    reflash();
  }

  initaddgrombox() {
    box = Container(
        decoration: new BoxDecoration(
            color: SQColor.white, borderRadius: new BorderRadius.circular(10)),
        // width: 200,
        padding: EdgeInsets.only(top: 20, bottom: 10),
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                // margin: EdgeInsets.all(15),
                child: new Text(
                  lang("加入书架及时获取更新提示"),
                  style: new TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 16.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: new TextButton(
                            key: null,
                            onPressed: () {
                              pop(context);
                              pop(context);
                            },
                            // color: const Color(0xFFe0e0e0),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                return Color(0xFFe0e0e0);
                              }),
                              // foregroundColor: MaterialStateProperty.resolveWith((states) {
                              //   return Styles.getTheme()['activefontcolor'];
                              // }),
                              // shape: MaterialStateProperty.resolveWith((states) {
                              //   return RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(8));
                              // }),
                            ),
                            child: new Text(
                              lang("取消"),
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "Roboto"),
                            ))),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: new TextButton(
                            key: null,
                            onPressed: () {
                              novel!.addgroom();
                              pop(context);
                              pop(context);
                            },
                            // color: SQColor.primary,
                            style: ButtonStyle(backgroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              return SQColor.primary;
                            })),
                            child: new Text(
                              lang("加入书架"),
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: SQColor.white,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "Roboto"),
                            ))),
                    SizedBox(
                      width: 15,
                    ),
                  ])
            ]));
  }

  //获取章节内容
  Future<Article?> fetchArticle(int index) async {
    //获取章节内容，并且根据字体大小分页
    var article = await ArticleProvider2.fetchArticle(context!, novel!, index);

    if (!isnull(article)) {
      return null;
    }

    return article;
  }

  //重新渲染

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

  //屏幕点击事件
  onTap(Offset position) async {
    //点击翻页或者弹出菜单

    hidetitlebar();
    double xRate = position.dx / Screen.width;
    double yRate = position.dy / Screen.width;
    var time = 100;
    if ((xRate > 0.33 && xRate < 0.66)) {
      //显示菜单
      // isMenuVisiable = true;
      s('isMenuVisiable', true);
      reflash();
    } else if (xRate >= 0.66) {
      //下一页
      pageController.animateToPage(2,
          duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    } else {
      //上一页
      pageController.animateToPage(0,
          duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    }
  }

  //下一页
  nextPage() {
    //下一页
    if (!isnull(currentArticle)) {
      return;
    }
    if (pageIndex >= currentArticle!.pageCount - 1 &&
        currentArticle!.nextArticleId == 0) {
      golast(novel!);
      // show(context, lang('已经是最后一页了'));
      return;
    }
    setpage(1);
  }

  //上一页
  previousPage() {
    //上一页
    if (pageIndex == 0 && currentArticle!.preArticleId == 0) {
      show(context, lang('已经是第一页了'));
      return;
    }

    setpage(-1);
  }

  //翻页公共库
  setpage(int nums) async {
    int index = pageIndex + nums;
    if (!isnull(currentArticle)) {
      pageIndex = 0;
      reflash();
      return;
    }
    if (index < currentArticle!.pageCount && index >= 0) {
      pageIndex = index;
      reflash();
    }
    if (index > currentArticle!.pageCount - 1) {
      if (isnull(nextArticle)) {
        currentArticle = nextArticle;
      }

      reflash();
      if (isnull(currentArticle)) {
        resetContent(currentArticle!.index, PageJumpType.firstPage);
      }
      // pageIndex=0;
    }
    if (index < 0) {
      if (isnull(preArticle)) {
        currentArticle = preArticle!;
      }

      reflash();
      if (isnull(currentArticle)) {
        resetContent(currentArticle!.index, PageJumpType.lastPage);
      }
    }
  }

  //当前页面渲染
  pagecontent() {
    if (!isnull(currentArticle)) return kongbai;
    Widget obj = ReaderView(
        novel: novel!,
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
    if (pageIndex != 0) {
      return ReaderView(
          novel: novel!,
          article: currentArticle!,
          battery: btter,
          page: pageIndex - 1,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(preArticle)) {
        return ReaderView(
            novel: novel!,
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
          novel: novel!,
          article: currentArticle!,
          page: tmpindex,
          battery: btter,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(nextArticle)) {
        return ReaderView(
            novel: novel!,
            article: nextArticle!,
            battery: btter,
            page: 0,
            topSafeHeight: topSafeHeight);
      } else {
        return kongbai;
      }
    }
  }

  //设置阅读章节记录
  catelog(var article) async {
    var index = await article.getindex();
    Chapter.clickout(novel!.id, novel!.type, article.section_id, index);
    novel!.addreadlog(article.index);
    setpoint(article);
  }

  //设置阅读章节分页记录
  void setpoint(article) {
    var page = pageIndex;
    var cache = pageindexk + novel!.id + novel!.type + article.index.toString();
    setcache(cache, page, '-1');
  }
}

class _ReadStatState extends State<ReadStat> {
  @override
  void initState() {
    super.initState();
    widget.initState();
    widget.mounted = mounted;
  }

  void reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.mounted = mounted;
    widget.state = this;
    widget.context = context;
    widget.setState = setState;
    widget.reflash = reflash;
    // setState(() {
    // });
    return widget.build(context);
  }

  @override
  void dispose() {
    super.dispose();
    widget.dispose();
  }
}
