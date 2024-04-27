import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/model/mock.dart';
import 'package:ng169/model/msg.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/task/sign.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/brige.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:dio/dio.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/incode.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/t.dart';
import 'package:ng169/tool/url.dart';
import 'bookshelf_header.dart';
import 'book_parse.dart';
import 'bookshelf_item_view.dart';

class Rack extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RackSceneState();
}

class RackSceneState extends State<Rack> {
  var api = 'groom/get_rack';
  var api2 = 'groom/to_rack';
  List<Novel> favoriteNovels = [];

  late File file;
  late IOSink isk;
  ScrollController scrollControllerrack = ScrollController();
  double navAlpha = 0;
  bool isedit = false;
  int chooseall = 1;
  List choosesbook = []; //选中的小说
  List choosescartoon = []; //选中的漫画
  List<Novel> choosenovel = []; //选中
  static Widget onimg=SizedBox();
  static Widget unimg=SizedBox();
  @override
  void initState() {
    super.initState();

    if (!isnull(onimg)) {
      onimg = Image.asset(
        'assets/images/choose_click.png',
        width: 17.0,
      );
    }
    if (!isnull(unimg)) {
      unimg = Image.asset(
        'assets/images/choose_unclick.png',
        width: 17.0,
      );
      Msg.cheack();
    }

    // var cache = g('cache');

    //先查本地，本地有加载本地书架
    //本地无加载网络书架：网络书架分登入跟非登入两种数据
    // if (!User.islogin()) {
    //   // cache.set('newapp', '1', '-1');
    //   loadhttp();
    // } else {

    // }
    mock();
    loadlocals();
    loadhttp();
    scrollControllerrack.addListener(() {
      var offset = scrollControllerrack.offset;

      if (offset < 0) {
        if (navAlpha != 0) {
          setState(() {
            navAlpha = 0;
          });
        }
      } else if (offset < 50) {
        setState(() {
          navAlpha = 1 - (50 - offset) / 50;
        });
      } else if (navAlpha != 1) {
        setState(() {
          navAlpha = 1;
        });
      }
    });
    // EventBus().on('rfrack',loadhttp);
    eventBus.on('rfrack', (arg) {
      loadhttp();
    });
    eventBus.on('xsdrsj', (arg) {
      showchoose();
    });
  }

  //本地模拟数据；防止网络加载慢的时候，数据无内容显示
  mock() {
    // String lang = getlang();
    // if (isnull(lang)) {
    //   if (lang.substring(2) != 'th') {
    //     return;
    //   }
    // }
    // var list = [
    //   {
    //     "other_name": "วิวาห์ร้อน รักหวานซึ้ง",
    //     // "bpic":
    //     //     "http://xspic.ng169.com/data/attachment/pc/201912/12/17_31/ccdc9e78a94311b3.jpg",
    //     "bpic": "mock:1-1018.png",
    //     "book_id": "1018",
    //     "type": "1",
    //     "isgroom": "1",
    //   },
    //   {
    //     "other_name": "เจ้าคือพระชายาของข้า",
    //     "bpic":
    //         // "mock:http://xspic.ng169.com/data/attachment/pc/201912/12/17_31/e22bdb07f89fd16e.jpg",
    //         "mock:1-1008.png",
    //     "book_id": "1008",
    //     "type": "1",
    //     "isgroom": "1",
    //   },
    //   {
    //     "other_name": "รักที่บินถลาเล่นลม",
    //     "bpic":
    //         // "mock:http://xspic.ng169.com/data/attachment/pc/201912/12/17_31/413f79f8528afe81.jpg",
    //         "mock:1-1009.png",
    //     "book_id": "1009",
    //     "type": "1",
    //     "isgroom": "1",
    //   },
    //   {
    //     "other_name": "surprise เธอคือเซอร์ไพรส์สุดใหญ่ของผม",
    //     // "bpic":
    //     //     "mock:http://xspic.ng169.com/data/attachment/pc/201912/12/17_40/19880cc852440ac4.jpg",
    //     "bpic": "mock:2-50014.png",
    //     "book_id": "50014",
    //     "type": "2",
    //     "isgroom": "1",
    //   },
    //   {
    //     "other_name": "ยัยหน้าเปี๋ยวของประธานซาตาน",
    //     // "bpic":
    //     //     "mock:http://xspic.ng169.com/data/attachment/pc/201912/12/17_40/127a9f96777200f1.jpg",
    //     "bpic": "mock:2-50016.png",
    //     "book_id": "50016",
    //     "type": "2",
    //     "isgroom": "1",
    //   },
    // ];
    var list = Mock.get('rack');
    if (isnull(list)) {
      for (var item in list) {
        Novel novelbook = Novel.fromJson(item);
        favoriteNovels.add(novelbook);
      }
    }
  }

  loadlocals() async {
    // var list = await T('book').where({'uid': '0'}).getall();
    var list = [];

    var user = User.get();
    if (isnull(user)) {
      //favoriteNovels = []; //重置列表
      list = await T('book')
          .where({'isgroom': '1', 'uid': getuid()})
          .order('addtime desc')
          .limit('250')
          .getall();
    } else {
      list = await T('book')
          .where({'isgroom': '1', 'uid': '0'})
          .order('addtime desc')
          .limit('250')
          .getall();
    }
    // d(favoriteNovels.length);
    // d(list.length);
    if (list.length > 0 && list.length >= favoriteNovels.length) {
      favoriteNovels = []; //重置列表
      for (var item in list) {
        Novel novelbook = Novel.fromDb(item);
        favoriteNovels.add(novelbook);
      }
      refresh();
    }
  }

  loadhttp() {
    var apitmp = '';
    if (isnull(getuid())) {
      apitmp = api;
      Msg.cheack();
    } else {
      apitmp = api2;
    }
    http(apitmp, {}, gethead(), 30).then((data) {
      // getdata
      var json = getdata(context, data);

      if (isnull(json)) {
        favoriteNovels = [];
        for (var item in json) {
          Novel noveltmp = Novel.fromJson(item);
          noveltmp..updbgroom();
          favoriteNovels.add(noveltmp);
        }
// d(json.length);
// d(favoriteNovels.length);
        loadlocals();
      } else {
        //服务器端书架已经被清空了
        loadlocals();
      }

      refresh();
    });
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchData() async {
    try {
      loadhttp();
    } catch (e) {}
  }

  Widget buildActions(Color iconColor) {
    var editbtn = Container(
      height: kToolbarHeight,
      width: 44,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/bainji.png',
        color: iconColor,
        width: 15.0,
      ),
    );
    var signbtn = Container(
        height: kToolbarHeight,
        width: 17.0,
        child: InkWell(
          child: Image.asset('assets/images/sign.png', color: iconColor),
          onTap: () async {
            //测试下载
            //  List lists=await T('book').getall();
            //  lists.forEach((f) async {
            //    Novel book=Novel.fromDb(f);
            //    await book.downbook();
            //  });
            //测试并发
            gourl(context, Sign());
          },
        ));
    bool b=false;
    if (chooseall == 2 || chooseall == 4) {
      b = true;
    }
    if (chooseall == 1 || chooseall == 0) {
      b = false;
    }
    var choseall = Container(
      height: kToolbarHeight,
      width: 44,
      alignment: Alignment.center,
      child: b ? onimg : unimg,
      // Image.asset(
      //   'assets/images/choose_unclick.png',
      //   //color: Color,
      //   width: 17.0,
      // ),
    );
    var hsz = Container(
      height: kToolbarHeight,
      width: 44,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/hsz.png',
        color: iconColor,
        width: 17.0,
      ),
    );
    var addico = GestureDetector(
      child: Container(
          height: kToolbarHeight,
          width: 15,
          alignment: Alignment.center,
          child:
              // Image.asset(
              //   'assets/images/bookshelf_add.png',
              //   color: iconColor,
              //   // width: 44.0,
              //   // height: 44.0,
              // ),
              Icon(
            Icons.library_add,
            color: iconColor,
          )),
      onTap: showchoose,
    );
    var bar1 =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      GestureDetector(
        child: signbtn,
        onTap: sign,
      ),
      isnull(favoriteNovels.length)
          ? GestureDetector(
              child: editbtn,
              onTap: edit,
            )
          : SizedBox(width: 0),
      addico,
      SizedBox(width: 15)
    ]);
    var bar2 = Row(children: <Widget>[
      GestureDetector(
        child: choseall,
        onTap: choose,
      ),
      GestureDetector(
        child: hsz,
        onTap: hs,
      ),
      SizedBox(width: 15)
    ]);
    return !isedit ? bar1 : bar2;
  }

  // GestureDetector
  Widget buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          child: Container(
            margin: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            child: buildActions(SQColor.white),
          ),
        ),
        Opacity(
          opacity: !isnull(favoriteNovels.length) ? 1.0 : navAlpha,
          child: Container(
            decoration: new BoxDecoration(
              color: SQColor.white,
              boxShadow: [
                BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
              ],
            ),
            padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            height: Screen.navigationBarHeight,
            child: Row(
              children: <Widget>[
                SizedBox(width: 103),
                Expanded(
                  child: Text(
                    lang('书架'),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                buildActions(SQColor.darkGray),
              ],
            ),
          ),
        )
      ],
    );
  }

  showchoose() {
    //导入本地小说
    //访问书城
    //取消
    var bo = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Material(
              child: InkWell(
                onTap: () {
                  pop(context);
                  eventBus.emit('EventToggleTabBarIndex', 1);
                },
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      lang('访问书城'),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: Colors.black38,
            ),
            Material(
              child: InkWell(
                onTap: () {
                  pop(context);
                  loadlocalbook();
                },
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      lang('导入本地小说'),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: Colors.black38,
            ),
            Material(
              child: InkWell(
                onTap: () {
                  pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      lang('取消'),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
    showbox(bo, Null as Color, Null as double, false, getScreenWidth(context) * .7);
  }

  loadlocalbook() async {
    String fileName;
    try {
      // File file = await FilePicker.getFile(type: FileType.any);
      //目前只支持txt
      // File file = await FilePicker.getFile(
      //     type: FileType.custom, allowedExtensions: ['txt']);
      // File file;
      FilePickerResult? files = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
      //判断是否需要上传
      File file = File(files!.files.single.path!);
      if (!isnull(file)) return;

      // var list = await file.readAsBytes();
      upfile(file);
      String text;
      // try {
      //   text = gbk.decode(list);
      // } catch (e) {
      //   text = await file.readAsString();
      //   print('text:$text');
      // }
      try {
        text = await file.readAsString();
      } catch (e) {
        d(e);
        text = 'Please import utf8 novel';
      }

      fileName = file.path.split('/').last.replaceAll('.txt', '');

      // d(fileName);
      // return;

      show(context, lang('小说') + '<$fileName>' + lang('同步中') + '...');
      bool insert = await BookParse(text).parse(fileName);
      if (insert) {
        show(context, lang('小说') + '<$fileName>' + lang('同步完成'));
        loadlocals();
        //刷新书架
      } else {
        // show(context, lang('小说') + '<$fileName>' + lang('导入失败'));
        loadlocals();
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }

    // bookShelfNotify.syncBook();
  }

  upfile(File file) async {
    //上传到server
    try {
      var checktmp = await http('upbook/needup', {}, gethead());
      var check = getdata(context, checktmp);
      if (isnull(check)) {
        String path = file.path;

        var tmp = await httpfile('upbook/up',
            {'file': await MultipartFile.fromFile(path)}, gethead());
      }
    } catch (e) {
      d(e);
    }
  }

  Widget buildFavoriteView() {
    List<Widget> children = [];
    var novels;
    // if (favoriteNovels.length <= 1) {
    //   novels = favoriteNovels; //
    // } else {
    //   novels = favoriteNovels.sublist(1); //这里是不显示顶部的
    // }

    novels = favoriteNovels; //
    //var novels = favoriteNovels; //这里是一样显示顶部最大的那个
    // d(favoriteNovels[0].lastsecnum);
    // d(favoriteNovels[0].nowsecnum);
    // d(favoriteNovels[0].upsecnum);
    novels.forEach((novel) {
      children.add(BookshelfItemView(novel));
    });
    var width = (Screen.width - 15 * 2 - 24 * 2) / 3;
    var addbtn = GestureDetector(
      onTap: () {
        //转到书城
        showchoose();
        // eventBus.emit('EventToggleTabBarIndex', 1);
      },
      child: Container(
        color: SQColor.paper,
        width: width,
        height: width / 0.75,
        child: Image.asset('assets/images/bookshelf_add.png'),
      ),
    );
    children.add(addbtn);

    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
      child: NgBrige(
        child: Wrap(
          spacing: 23,
          children: children,
        ),
        data: {'isedit': isedit, 'chooseall': chooseall},
        fun: {'chooseone': chooseone, 'clickonebook': clickonebook},
      ),
    );
  }

  reflashrack() async {
    //加入数据库有时限，异步
    // await Future.delayed(const Duration(milliseconds: 100), () {});
    loadlocals();
    // loadhttp();
    refresh();
  }

  sc() async {
    var info = await User.gettestinfo();

    var ds = await http('common/testandroid', {'data': info}, gethead());
    d(ds);
  }

  @override
  Widget build(BuildContext context) {
    // d(times);
    // favoriteNovels=[];
    //没书的时候显示加号顶部标题栏
    //有书的时候这样显示
    // sc();
    return Scaffold(
      backgroundColor: SQColor.white,
      body: AnnotatedRegion(
        value: favoriteNovels.length == 0
            ? SystemUiOverlayStyle.dark
            : navAlpha > 0.5
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
        child: Stack(children: [
          RefreshIndicator(
            onRefresh: fetchData,
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              controller: scrollControllerrack,
              physics: AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                favoriteNovels.length == 0
                    ? SizedBox(
                        height: 3,
                      )
                    : SizedBox(),
                favoriteNovels.length == 0
                    ? SizedBox(
                        height: Screen.navigationBarHeight,
                      )
                    : SizedBox(),
                favoriteNovels.length > 0
                    ? BookshelfHeader(favoriteNovels[0])
                    : Container(),
                buildFavoriteView(),
              ],
            ),
          ),
          buildNavigationBar(),
        ]),
      ),
    );
  }

  //书架编辑功能
  edit() {
    var user = User.get();
    if (!isnull(user)) {
      gourl(context, new Index());
      return false;
    }
    //开启编辑模式
    //底部出现全选，以及删除选项
    //顶部出现取消按钮
    //d(isedit);
    //show(context,'ddd');
    isedit = true;
    refresh();
  }

  hs() {
    //删除记录需要登入
    var user = User.get();
    if (!isnull(user)) {
      gourl(context, new Index());
      return false;
    }
    //开启编辑模式
    //底部出现全选，以及删除选项
    //顶部出现取消按钮
    //本地删除显示，删除数据库数据记录
    String bid = '', cid = '', lid = '';
    for (var item in choosenovel) {
      if (item.type == '1') {
        bid += "," + item.id;
      } else if (item.type == '2') {
        cid += "," + item.id;
      } else if (item.type == '3') {
        lid += "," + item.id;
      }
      // item.removegroom();
    }

    if (isnull(bid)) {
      bid = bid.substring(1);
      T('book')
          .wherestring(' bookid in (' + bid + ') ')
          .update({'isgroom': 0, 'uid': getuid()}, {'type': 1});
    }
    if (isnull(cid)) {
      cid = cid.substring(1);
      T('book')
          .wherestring(' bookid in (' + cid + ') ')
          .update({'isgroom': 0, 'uid': getuid()}, {'type': 2});
    }
    if (isnull(lid)) {
      lid = lid.substring(1);
      T('book')
          .wherestring(' bookid in (' + lid + ') ')
          .update({'isgroom': 0, 'uid': getuid()}, {'type': 3});
    }
    if (isnull(bid) || isnull(cid)) {
      http('groom/delrack', {'cartoon_id': cid, 'book_id': bid}, gethead());
    }
    favoriteNovels = [];
    loadlocals();
    isedit = false;
    // choosesbook = [];
    // choosescartoon = [];
    choosenovel = [];
    chooseall = 0;
    refresh();
    //fetchData();
    chooseall = 1;
  }

  choose() {
    // choosescartoon = [];
    // choosesbook = [];
    choosenovel = [];
    if (chooseall == 2) {
      choosenovel = [];
      chooseall = 0;
      refresh();
      return 0;
    }
    if (chooseall == 0) {
      choosenovel.addAll(favoriteNovels);
      chooseall = 2;
      refresh();

      return 0;
    }
    if (chooseall == 1) {
      choosenovel.addAll(favoriteNovels);
      chooseall = 2;
      refresh();
      return 0;
    }
    if (chooseall == 4) {
      choosenovel = [];
      chooseall = 0;
      refresh();
      return 0;
    }
  }

  //签到
  sign() {
    d('sign');
  }

  chooseone(Novel novel, bool isadd) {
    //var obj = Tmplist(bid, type);

    if (isadd) {
      if (choosenovel.indexOf(novel) == -1) {
        choosenovel.add(novel);
      }
    } else {
      choosenovel.remove(novel);
    }
  }

  clickonebook() {
    if (chooseall == 2) {
      chooseall = 4;
    }
    if (chooseall == 0) {
      chooseall = 1;
    }
    refresh();
  }

  // static callback() {
  //   httpnodeal('http://test.259459.com/api/task/read60_rewards', {}, {
  //     'token':
  //         '04c4345000bbc8c4f5eed755080c464fddc744998aa24829907e59b2c22cec22',
  //     'uid': 10
  //   });
  // }

  // tmp() {
  //   return Row(children: [
  //     FlatButton(
  //         onPressed: () async {
  //           //启动线程

  //           Supervene.init(40, callback);
  //         },
  //         child: Text('测试并发')),

  //   ]);
  // }
}
