// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:ng169/page/home/book_banner.dart';
import 'package:ng169/page/home/home_banner.dart';
import 'package:ng169/page/home/home_menu.dart';
import 'package:ng169/page/home/novel_first_hybird_card.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/home/novel_list_more.dart';
import 'package:ng169/page/home/novel_normal_card.dart';
import 'package:ng169/page/home/novel_rom.dart';
import 'package:ng169/page/home/novel_second_hybird_card.dart';
import 'package:ng169/page/mall/searchpage.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/model/mock.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

import 'catepage.dart';

class Mall extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MallState();
}

class MallState extends State<Mall> {
  late List banner = [],
      newbook = [],
      newcart = [],
      hotbook = [],
      mallcache = [null, null, null, null, null],
      randdata = [];
  List<Widget> more = [SizedBox()];
  var index = 'mallload';
  var cachedata = 'mallload_data', page = 1;
  bool moredata = false, stop = false;
  ScrollController scrollController = ScrollController();
  var navAlpha = 0.0;
  var bannerapi = 'book/get_banner';
  var newBookapi = 'book/get_new_book';
  var hotbooksapi = 'book/new';
  var newCartoonsapi = 'cartoon/hot_cartoon';
  var randapi = 'book/get_randList';
  Future<dynamic>? gethttpdate(String api) async {
    var jbanner = await http(api, {}, gethead());
    var data = getdata(context, jbanner);
    if (isnull(data)) {
      return data;
    }
    // return Future.error(e);
    return null;
  }

  mock() {
    try {
      banner = Mock.get('banner');
      newbook = Mock.get('newbook');
      randdata = Mock.get('randdata');
    } catch (e) {
      dt(e);
    }
  }

  Future<void> processAsyncTasks2() async {
    List<Future> tasks = [
      setdata(null, bannerapi, 0),
      setdata(null, newBookapi, 1),
      setdata(null, newCartoonsapi, 2),
      setdata(null, hotbooksapi, 3),
      setdata(null, randapi, 4),
      // ... 更多异步任务
    ];

    Future.wait(tasks);
    // 所有异步任务都已完成，处理results
  }

  bool isdart = false;
  Future<void> gethttpdata() async {
    // await Future.wait<dynamic>([
    //   setdata(null, bannerapi, 0),
    //   setdata(null, newBookapi, 1),
    //   setdata(null, newCartoonsapi, 2),
    //   setdata(null, hotbooksapi, 3),
    //   setdata(null, randapi, 4),
    // ]);
    // List<Future<void>> futures = [
    //   setdata(null, bannerapi, 0),
    //   setdata(null, newBookapi, 1),
    //   setdata(null, newCartoonsapi, 2),
    //   setdata(null, hotbooksapi, 3),
    //   setdata(null, randapi, 4),
    // ];
    processAsyncTasks2();
    // try {
    //   await Future.wait(futures);
    //   // 所有 future 完成之后的代码
    // } catch (e) {
    //   // 异常处理
    //    dt(e);
    // }
    // await Future.wait(futures);
    mallcache = [banner, newbook, newcart, hotbook, randdata];

    setcache(cachedata, mallcache, '-1');
    more = [SizedBox()];
    stop = false;
    page = 1;
    refresh();
  }

  @override
  void deactivate() {
    super.deactivate();
    // d('切换页面');
  }

  // void didChangeMetrics() {
  //   d('切换窗口');
  // }

  @override
  void initState() {
    super.initState();
    index = index + getlang();
    cachedata = cachedata + getlang();

    mock();

    loadpage();

    scrollController.addListener(() {
      //var offset = scrollController.offset;
      var offset = scrollController.offset;

      if (offset <= 0) {
        titlebarcolor(isdart);
        if (navAlpha != 0) {
          setState(() {
            navAlpha = 0;
          });
        }
      } else if (offset < 50) {
        titlebarcolor(false);

        setState(() {
          navAlpha = 1 - (50 - offset) / 50;
        });
      } else if (navAlpha != 1) {
        setState(() {
          navAlpha = 1;
        });
      }
      loadmore();
    });
  }

  loadingstatu() {
    setState(() {
      moredata = !moredata;
    });
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // d('底部' + offset.toString());
      if (stop) {
        return false;
      }
      loadingstatu();
      var data = await http('book/new', {'page': page++}, gethead());
      var tmpmore = getdata(context, data);

      if (isnull(tmpmore)) {
        more.add(bookCardWithInfo(5, '', tmpmore));
        // page++;
      } else {
        stop = true;
      }
      loadingstatu();
      refresh();
    }
  }

  //  gethttpdata(); //加载数据
  Future<void> processAsyncTasks() async {
    List<Future> tasks = [
      setdata(mallcache, bannerapi, 0),
      setdata(mallcache, newBookapi, 1),
      setdata(mallcache, newCartoonsapi, 2),
      setdata(mallcache, hotbooksapi, 3),
      setdata(mallcache, randapi, 4),
      // ... 更多异步任务
    ];

    Future.wait(tasks);
    // 所有异步任务都已完成，处理results
  }

  //加载页面
  //先读缓存
  //在读http数据
  Future<void> loadpage() async {
    //20分钟刷新缓存数据重新加载
    var mallcachebool = getcache(index);

    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //半个小时的缓存
      setcache(index, 1, '1800');
    } else {
      mallcache = getcache(cachedata);
      // d(mallcache);
      if (isnull(mallcache)) {
        processAsyncTasks();
      } else {
        setcache(index, 0, '0');
      }
    }
  }

  setdata(List<dynamic>? cache, String api, int cacheid) async {
    // if (!isnull(cache)) return false;

    if (isnull(cache, cacheid)) {
      setval(cacheid, cache![cacheid]);
    } else {
      var tmp;
      try {
        tmp = await gethttpdate(api);
      } catch (e) {
        dt(e);
      }

      if (isnull(tmp)) {
        setval(cacheid, tmp as List);
        if (mallcache == null) {
          mallcache = [];
        }
        mallcache[cacheid] = tmp;
        setcache(cachedata, mallcache, '-1');
      }
    }
    return;
  }

  setval(int cacheid, List<dynamic> val) {
    switch (cacheid) {
      case 0:
        banner = val;
        break;
      case 1:
        newbook = val;
        break;
      case 2:
        newcart = val;
        break;
      case 3:
        hotbook = val;
        break;
      case 4:
        randdata = val;
        break;
    }
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> romget() async {
    randdata = await gethttpdate(randapi);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    //如果有4个接口请求的内容中有1个空则重新加载请求
    // mock();

    isdart = !isnull(banner) ? true : false;
    if (navAlpha == 0) {
      titlebarcolor(isdart);
    }

    var body = Container(
      //margin: EdgeInsets.only(top: 5),
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.all(0),
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            //banner

            isnull(banner)
                ? HomeBanner(banner)
                : isnull(randdata)
                    ? BookBanner(randdata)
                    : SizedBox(
                        height: 80,
                      ),
            //菜单
            HomeMenu(),
            isnull(randdata)
                ? bookCardWithInfo(6, lang('猜你喜欢'), randdata)
                : SizedBox(),
            //推荐小说
            isnull(newbook)
                ? bookCardWithInfo(2, lang('推荐小说'), newbook)
                : SizedBox(),

            //推荐漫画
            isnull(newcart)
                ? bookCardWithInfo(3, lang('推荐漫画'), newcart)
                : SizedBox(),
            //热门小说
            isnull(hotbook)
                ? bookCardWithInfo(4, lang('热门小说'), hotbook)
                : SizedBox(),
            Column(
              children: more,
            ),

            moredata ? _buildProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: SQColor.white,
      body: Stack(
        children: <Widget>[body, buildNavigationBar()],
      ),
    );
  }

  Widget buildNavigationBar() {
    var w = getScreenWidth(context);
    // var padding = EdgeInsets.fromLTRB(w * .1, Screen.topSafeHeight, w * .1, 10);
    var padding = EdgeInsets.only(top: Screen.topSafeHeight, bottom: 10);
    return Stack(
      children: <Widget>[
        Positioned(
          // right: 0,
          child: Container(
            // margin: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            padding: padding,
            child: buildserechbtn(),
          ),
        ),
        Opacity(
          opacity: navAlpha,
          child: Container(
            decoration: new BoxDecoration(
              color: SQColor.white,
              boxShadow: [
                BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
              ],
            ),
            padding: padding,
            child: buildserechbtn(),
          ),
        )
      ],
    );
  }

  //搜索框栏目
  Widget buildserechbtn() {
    var w = getScreenWidth(context);
    var c = Container(
      alignment: Alignment.center,
      width: w * 0.85,
      height: Screen.navigationBarHeight * .4,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        //    border: Border.all(
        //    color:  SQColor.white,
        // width: 1,
        //   ),
        //中间按钮背景框
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color:
            navAlpha <= 0 ? Color.fromARGB(176, 91, 93, 91) : Colors.grey[200],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.search,
                  color: navAlpha <= 0 ? SQColor.white : SQColor.primary,
                  size: 20,
                )),
            Text(
              lang("书名/作者/关键词"),
              style: TextStyle(
                  color: navAlpha <= 0 ? SQColor.white : Colors.black38,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
    var btn = GestureDetector(
      child: c,
      onTap: () {
        gourl(context, new SearchPage());
      },
    );
    var cates = Container(
        width: 35,
        height: 30,
        margin: EdgeInsets.only(top: 10, left: 6),
        child: Container(
            width: 13,
            // height: 30,
            padding: EdgeInsets.only(right: 10, left: 4),
            // color: Colors.red,
            child: Image.asset(
              'assets/images/icon_menu_catalog.png',
              fit: BoxFit.fill,
              color: navAlpha <= 0 ? SQColor.white : Colors.black38,
            ))
        //   child: Icon(
        //   Icons.subject,
        //   size: 35,
        //   color: navAlpha <= 0 ? SQColor.white : Colors.black38,
        // )
        // icon_menu_catalog
        );
    var cate = GestureDetector(
      child: cates,
      onTap: () {
        gourl(context, new CatePage());
      },
    );
    return Row(children: [cate, btn]);
  }

  Widget bookCardWithInfo(int style, String title, List json) {
    Widget card = new SizedBox();
    switch (style) {
      case 1:
        card = NovelFourGridView(title, json);
        break;
      case 2:
        card = NovelSecondHybirdCard(title, json);
        break;
      case 3:
        card = NovelFirstHybirdCard(title, json);
        break;
      case 4:
        card = NovelNormalCard(title, json);
        break;
      case 5:
        card = NovelmoreCard(json);
        break;
      case 6:
        card = NovelRomView(title, json, () {
          romget();
        });
        break;
    }
    return card;
  }

  Widget _buildProgressIndicator() {
    var circular = new CircularProgressIndicator(
      backgroundColor: SQColor.white,
      strokeWidth: 5.0,
      valueColor: AlwaysStoppedAnimation(Colors.green[200]),
    );
    var box = SizedBox(
      width: 17,
      height: 17,
      child: circular,
    );
    var kongbai = Expanded(child: SizedBox());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          kongbai,
          box,
          SizedBox(width: 9),
          Text(
            lang('加载中..'),
          ),
          kongbai
        ],
      ),
    );
  }
}
