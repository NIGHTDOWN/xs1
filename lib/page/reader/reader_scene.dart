import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/article.dart';

import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/reader/lastpage.dart';
import 'package:ng169/page/reader/reader_bar.dart';
import 'package:ng169/page/reader/reader_tips.dart';
import 'package:ng169/page/smallwidget/gifload.dart';
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
import 'package:ng169/tool/t.dart';
import 'dart:async';
import 'article_provider.dart';
import 'battery_view.dart';

import 'reader_page_agent.dart';
import 'reader_view.dart';
import 'package:ng169/model/user.dart';

enum PageJumpType { stay, firstPage, lastPage }

class ReaderScene extends StatefulWidget {
  final int articleId; //章节id
  final Novel novel; //小说

  ReaderScene(this.novel, this.articleId);

  @override
  ReaderSceneState createState() => ReaderSceneState();
}

class ReaderSceneState extends State<ReaderScene>
    with TickerProviderStateMixin {
  int pageIndex = 0;
  int articleIndex = 0;
  bool islast = false;
  PageController pageController =
      PageController(keepPage: false, initialPage: 1);
  bool isLoading = false, isFirst = true;
  GlobalKey _readkey = new GlobalKey();
  double topSafeHeight = 0;

  late Article? preArticle;
  late Article? currentArticle;
  late Article? nextArticle;
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
  Widget  load=Container();
  bool loadflag=false;
  var page;
    loadw() {
    // return Container();
   load= Scaffold(
      // appBar: AppBar(
      //   title: Text('全屏白色背景'),
      // ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Gifload(),
        ),
      ),
    );
    // return GifCartoon();
  }
  @override
  void initState() {
    super.initState();

loadw();
   
    getfx();
    sysinit();
     resetContent(widget.articleId,PageJumpType.stay);
    pageController.addListener(onScroll);
    chaptersResponse = Chapter.get(context, this.widget.novel);
    btter = BatteryView();
    // btter = Container();
    setup();
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

    if (pageIndex >= currentArticle!.pageCount - 1 &&
        currentArticle!.nextArticleId == 0 &&
        pageController.page! > 1.4) {
      // pageIndex = currentArticle.pageCount - 1;
      golast();
      // show(context, lang('已经是最后一页了'));
      // pageController.jumpToPage(1);
      return;
    }

    //当前页面
    if (pageController.page == 1.0) {}
  }

  golast() async {
    if (!islast) {
      islast = true;
      await gourl(context, Lastpage(widget.novel));
      islast = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();

    Jsq()..end();
    pageController.dispose();
    showtitlebar();
    eventBus.off('read_reflash');
    Screen.keepOn(false); //屏幕常亮
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
       dt(e);
      return;
    }

    //获取章节索引 0开始
    articleIndex =
        int.parse(Chapter.getReadSecId(widget.novel.id, widget.novel.type));
    //章节内阅读页面
    //获取小说内容
    await resetContent(tmparticleId, PageJumpType.stay);
    //初始化指针
    //大于的时候是改变字体的时候，需要把页面大小重新调整
    pageIndex =
        (isnull(getpoint(tmparticleId)) ? (getpoint(tmparticleId)) : 0)!;

    if (pageIndex > currentArticle!.pageCount - 1) {
      pageIndex = currentArticle!.pageCount - 1;
    }
    // d(currentArticle.pageCount);
  }

  //获取章节页面定位
  int? getpoint(sectionId) {
    var cache = 'pageindex' +
        widget.novel.id +
        widget.novel.type +
        sectionId.toString();
    var tmp = getcache(cache);
    if (!isnull(tmp)) return null;
    if (tmp is int) {
      return tmp;
    }
    return int.parse(getcache(cache));
  }

  //获取章节内容，并且预加载前后两章
  resetContent(int articleId, PageJumpType jumpType) async {
    //目录定位
    //获取当前章节内容
    showload = true;
    reflash();

    currentArticle = (await fetchArticle(articleId));

// d(await currentArticle.ispay());
    if (!isnull(currentArticle)) {
      //章节内容不存在，跳一章
      var v = this.widget.novel;
      var tmp = await T('sec')
          .where({'book_id': v.id, 'booktype': v.type})
          .wherestring(' section_id> ' + articleId.toString())
          .order('`section_id` asc')
          .getone();
if(isnull(tmp)){
currentArticle = (await fetchArticle(tmp['section_id']));
}
      
    }
    if (!isnull(currentArticle)) {
      //重试获取下一章还是失败，则退出。
      return;
    }
    showload = false;
    reflash();
    if (currentArticle!.preArticleId > 0) {
      //预加载上一章
      fetchArticle(currentArticle!.preArticleId).then((onValue) {
        preArticle = onValue;
        reflash();
      });
    } else {
      preArticle = null;
    }

    if (currentArticle!.nextArticleId > 0) {
      //预加载下一章
      fetchArticle(currentArticle!.nextArticleId).then((onValuen) {
        nextArticle = onValuen;
        reflash();
      });
    } else {
      nextArticle = null;
    }
    if (jumpType == PageJumpType.firstPage) {
      //跳首页
      pageIndex = 0;
    } else if (jumpType == PageJumpType.lastPage) {
      //跳最后一页
      pageIndex = currentArticle!.pageCount - 1;
    }
    showload = false;
    loadflag=true;
    reflash();
  }

  fetchPreviousArticle(int articleId) async {
    // ignore: unnecessary_null_comparison
    if (preArticle != null || isLoading || articleId == 0) {
      return;
    }
    isLoading = true;
    preArticle = (await fetchArticle(articleId))!;
    pageController.jumpToPage(preArticle!.pageCount + pageIndex);
    isLoading = false;
    reflash();
  }

  fetchNextArticle(int articleId) async {
    // ignore: unnecessary_null_comparison
    if (nextArticle != null || isLoading || articleId == 0) {
      return;
    }
    isLoading = true;
    nextArticle = (await fetchArticle(articleId))!;
    isLoading = false;
    reflash();
  }

  //获取章节内容
  Future<Article?> fetchArticle(int articleId) async {
    //获取章节内容，并且根据字体大小分页
    var article =
        await ArticleProvider.fetchArticle(context, widget.novel, articleId);

    if (!isnull(article)) {
      return null;
    }
    // if (await article.ispay()) {
    //   //支付状态检测

    // }

    // var contentHeight = Screen.height -
    //     topSafeHeight -
    //     ReaderUtils.topOffset -
    //     Screen.bottomSafeHeight -
    //     ReaderUtils.bottomOffset -
    //     20;

    // var contentWidth = Screen.width - 15 - 10;
    article?.page = ReaderPageAgent.getPage(
      article.content,
    );

    return article;
  }

  //重新渲染
  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!loadflag)return load;
    // try {
    //   bar = ReaderBar(widget.novel, chaptersResponse, currentArticle, reflash,
    //       resetContent);
    // } catch (e) {
    //   d(e);
    //   bar = Container();
    // }
    bar = ReaderBar(
        widget.novel, chaptersResponse, currentArticle!, reflash, resetContent);
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
                              widget.novel.addgroom();
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: "Roboto"),
                            ))),
                    SizedBox(
                      width: 15,
                    ),
                  ])
            ]));

    return Scaffold(
      key: _readkey,
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.dark,
          // ignore: deprecated_member_use
          child: WillPopScope(
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
      golast();

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
  setpage(int nums) {
    int index = pageIndex + nums;
    if (index < currentArticle!.pageCount && index >= 0) {
      pageIndex = index;
      reflash();
    }
    if (index > currentArticle!.pageCount - 1) {
      currentArticle = nextArticle;
      reflash();
      if (isnull(currentArticle)) {
        resetContent(currentArticle!.id, PageJumpType.firstPage);
      }
      // pageIndex=0;
    }
    if (index < 0) {
      currentArticle = preArticle!;
      reflash();
      if (isnull(currentArticle)) {
        resetContent(currentArticle!.id, PageJumpType.lastPage);
      }
    }
  }

  //当前页面渲染
  pagecontent() {
    if (!isnull(currentArticle)) return kongbai;
    Widget obj = ReaderView(
        novel: widget.novel,
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
          novel: widget.novel,
          article: currentArticle!,
          battery: btter,
          page: pageIndex - 1,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(preArticle)) {
        return ReaderView(
            novel: widget.novel,
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
          novel: widget.novel,
          article: currentArticle!,
          page: tmpindex,
          battery: btter,
          topSafeHeight: topSafeHeight);
    } else {
      if (isnull(nextArticle)) {
        return ReaderView(
            novel: widget.novel,
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
