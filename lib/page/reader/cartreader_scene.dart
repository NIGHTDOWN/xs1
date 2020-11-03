import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ng169/model/article.dart';
import 'package:ng169/model/user.dart';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/page/reader/reader_bar.dart';
import 'package:ng169/page/reader/reader_scene.dart';
import 'package:ng169/page/reader/reader_tips_car.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';

import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/jsq.dart';
import 'package:ng169/tool/lang.dart';

import 'package:screen/screen.dart' as s2;
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/t.dart';
import 'dart:async';
import 'battery_view.dart';
import 'cartoon_provider.dart';
import 'cartoon_view.dart';

class CartReaderScene extends StatefulWidget {
  final int articleId; //章节id
  final Novel novel; //小说

  CartReaderScene(this.novel, this.articleId);

  @override
  CartReaderSceneState createState() => CartReaderSceneState();
}

class CartReaderSceneState extends State<CartReaderScene>
    with TickerProviderStateMixin {
  int pageIndex = 1;
  int articleIndex = 0;

  bool isLoading = false, isFirst = true, islock = false;

  double topSafeHeight = 0;

  Article preArticle;
  Article currentArticle;
  Article nextArticle;

  List<Chapter> chapters = [];
  List chaptersResponse = [];
  Widget kongbai = SizedBox();

  var page;
  @override
  void initState() {
    super.initState();
    sysinit();
    kongbai = FrameAnimationImage(
      interval: 100,
    );

    chaptersResponse = Chapter.get(context, this.widget.novel);
    setup();
    Jsq()..start();
  }

  getnowpage(PageController pageController) {
    double index = pageController.position.pixels /
        pageController.position.maxScrollExtent *
        currentArticle.pageCount;
    if (index.toString() == 'NaN') {
      return;
    }
    if (index <= 1.0) {
      index = 1.0;
    }
    if (index >= currentArticle.pageCount) {
      index = currentArticle.pageCount.toDouble();
    }
    pageIndex = int.parse(index.toStringAsFixed(0));
    setpoint(currentArticle);
    reflash();
  }

  lock() {
    islock = true;
    reflash();
  }

  unlock() {
    islock = false;
    reflash();
  }

  onScroll(PageController pageController) async {
    //上一页

    //当前页面

    //记录当前页面
    getnowpage(pageController);

    if (pageController.page > 1.0) {}
  }

  Future<Article> next() async {
    if (isnull(currentArticle.nextArticleId)) {
      await resetContent(currentArticle.nextArticleId, PageJumpType.firstPage);
    }
    return null;
  }

  Future<Article> pre() async {
    if (isnull(currentArticle.preArticleId)) {
      await resetContent(currentArticle.preArticleId, PageJumpType.lastPage);
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    Jsq()..end();
    showtitlebar();
    eventBus.off('read_reflash');
    s2.Screen.keepOn(false); //屏幕常亮
  }

  sysinit() async {
    await hidetitlebar();

    titlebarcolor(false);
    s2.Screen.keepOn(true); //屏幕常亮
    s('isMenuVisiable', false);
    await Future.delayed(const Duration(milliseconds: 100), () {});
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    topSafeHeight = Screen.topSafeHeight;
    eventBus.on('read_reflash', (arg) {
      reflash();
    });
  }

  void setup() async {
    List chaptersResponse =
        await Chapter.getcatecache(context, this.widget.novel);

    //章节id记录
    int tmparticleId;
    try {
      tmparticleId = isnull(this.widget.articleId)
          ? this.widget.articleId
          : int.parse(chaptersResponse[int.parse(
                  Chapter.getReadSecId(widget.novel.id, widget.novel.type))]
              ['section_id']);
    } catch (e) {
      d(e);
      return;
    }

    //获取章节索引 0开始
    articleIndex =
        int.parse(Chapter.getReadSecId(widget.novel.id, widget.novel.type));
    //章节内阅读页面
    //获取小说内容
    await resetContent(tmparticleId, PageJumpType.stay);
    //初始化指针
    pageIndex = isnull(getpoint(tmparticleId)) ? (getpoint(tmparticleId)) : 1;

    isFirst = false;
    reflash();
  }

  //获取章节页面定位
  int getpoint(sectionId) {
    var cache = 'pageindex' +
        widget.novel.id +
        widget.novel.type +
        sectionId.toString();
    var tmp = getcache(cache);
    if (!isnull(tmp)) return 1;
    if (tmp is int) {
      if (tmp < 1) {
        tmp = 1;
      }
      return tmp;
    }
    var index = int.parse(getcache(cache));
    if (index < 1) {
      index = 1;
    }
    return index;
    // return int.parse(getcache(cache));
  }

  //获取章节内容，并且预加载前后两章
  resetContent(int articleId, PageJumpType jumpType) async {
    //目录定位
    //获取当前章节内容
    // islock = true;
    // reflash();
    currentArticle = await fetchArticle(articleId);

    if (!isnull(currentArticle)) {
      //章节内容不存在，跳一章
      var v = this.widget.novel;
      var tmp = await T('sec')
          .where({'book_id': v.id, 'booktype': v.type})
          .wherestring(' section_id> ' + articleId.toString())
          .order('`section_id` asc')
          .getone();

      currentArticle = await fetchArticle(tmp['section_id']);
    }
    if (!isnull(currentArticle)) {
      //重试获取下一章还是失败，则退出。
      return;
    }
    if (jumpType == PageJumpType.firstPage) {
      //跳首页
      pageIndex = 1;
    } else if (jumpType == PageJumpType.lastPage) {
      //跳最后一页

      pageIndex = currentArticle.pageCount - 1;
    }
    if (currentArticle.preArticleId > 0) {
      //预加载上一章
      fetchArticle(currentArticle.preArticleId).then((onValue) {
        preArticle = onValue;
        reflash();
      });
    } else {
      preArticle = null;
    }

    if (currentArticle.nextArticleId > 0) {
      //预加载下一章
      fetchArticle(currentArticle.nextArticleId).then((onValuen) {
        nextArticle = onValuen;
        reflash();
      });
    } else {
      nextArticle = null;
    }

    // islock = false;
    //刷新不然翻页容易出错；
    // s('pageIndextmp', pageIndex);
    reflash();
  }

  Future<Article> resetContentdata(int articleId) async {
    //目录定位
    //获取当前章节内容

    var tmpcurrentArticle = await fetchArticle(articleId);

    if (!isnull(tmpcurrentArticle)) {
      //章节内容不存在，跳一章
      var v = this.widget.novel;
      var tmp = await T('sec')
          .where({'book_id': v.id, 'booktype': v.type})
          .wherestring(' section_id> ' + articleId.toString())
          .order('`section_id` asc')
          .getone();

      tmpcurrentArticle = await fetchArticle(tmp['section_id']);
    }
    if (!isnull(tmpcurrentArticle)) {
      //重试获取下一章还是失败，则退出。
      return null;
    }
    tmpcurrentArticle.cartoonisinit = false;
    //islock = false;
    //reflash();
    return tmpcurrentArticle;
  }

  fetchPreviousArticle(int articleId) async {
    if (preArticle != null || isLoading || articleId == 0) {
      return;
    }

    preArticle = await fetchArticle(articleId);

    reflash();
  }

  fetchNextArticle(int articleId) async {
    if (nextArticle != null || isLoading || articleId == 0) {
      return;
    }
    isLoading = true;
    nextArticle = await fetchArticle(articleId);
    isLoading = false;
    reflash();
  }

  //获取章节内容
  Future<Article> fetchArticle(int articleId) async {
    //获取章节内容，并且根据字体大小分页
    var article =
        await CartoonProvider.fetchArticle(context, widget.novel, articleId);

    if (!isnull(article)) {
      return null;
    }

    return article;
  }

  //重新渲染
  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget cartoonload() {
    return FrameAnimationImage(
      width: getScreenWidth(context),
      height: getScreenHeight(context),
      picwidth: 100,
      interval: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      return cartoonload();
    }

    var children2 = <Widget>[
      buildPageView(),
      topinfo(),
      ReaderBar(widget.novel, chaptersResponse, currentArticle, reflash,
          resetContent),
      !isnull(getcache('carshowtips', false)) ? Readertipscar() : Container(),
    ];
    var box = Container(
        decoration: new BoxDecoration(
            color: Colors.white, borderRadius: new BorderRadius.circular(10)),
        // width: 200,
        padding: EdgeInsets.only(top: 20, bottom: 10),
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                // margin: EdgeInsets.only(left: 10, right: 5),
                margin: EdgeInsets.only(left: 15, right: 15),
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
                    new RaisedButton(
                        key: null,
                        onPressed: () {
                          pop(context);
                          pop(context);
                        },
                        color: const Color(0xFFe0e0e0),
                        child: new Text(
                          lang("取消"),
                          style: new TextStyle(
                              fontSize: 12.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w200,
                              fontFamily: "Roboto"),
                        )),
                    SizedBox(
                      width: 15,
                    ),
                    new RaisedButton(
                        key: null,
                        onPressed: () {
                          widget.novel.addgroom();
                          pop(context);
                          pop(context);
                        },
                        color: SQColor.primary,
                        child: new Text(
                          lang("加入书架"),
                          style: new TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                              fontFamily: "Roboto"),
                        ))
                  ])
            ]));

    return Scaffold(
        body: WillPopScope(
            onWillPop: () {
              if (isnull(widget.novel.isgroom)) {
                pop(context);
              } else {
                if (User.islogin()) {
                  showbox(box, Color(0x00ffffff));
                } else {
                  pop(context);
                }
              }
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
          width: getScreenWidth(context),
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
                  currentArticle.title,
                  style: TextStyle(fontSize: fixedFontSize(11), color: color)),
              //分页
              Expanded(child: Container()),
              Text('${pageIndex}/' + currentArticle.pageCount.toString(),
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

  showmenu() {
    // isMenuVisiable = true;
    s('isMenuVisiable', true);
    reflash();
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

  //当前页面渲染
  pagecontent() {
    if (!isnull(currentArticle)) return kongbai;

// d(currentArticle);
    Widget obj = CartoonView(
      novel: widget.novel,
      article: currentArticle,
      page: pageIndex,
      topSafeHeight: topSafeHeight,
      scroll: onScroll,
      showmenu: showmenu,
      next: next,
      pre: pre,
      lock: lock,
      unlock: unlock,
      islock: islock,
    );
    if (!isnull(obj)) {
      return kongbai;
    }
    catelog(currentArticle);
    return obj;
  }

  //设置阅读章节记录
  catelog(var article) async {
    var index = await article.getindex();
    Chapter.clickout(
        widget.novel.id, widget.novel.type, article.section_id, index);
    this.widget.novel.addreadlog(article.section_id);
    setpoint(article);
  }

  //设置阅读章节分页记录
  void setpoint(article) {
    var page = pageIndex;
    var cache = 'pageindex' +
        widget.novel.id +
        widget.novel.type +
        article.section_id.toString();
    setcache(cache, page, '-1');
  }
}