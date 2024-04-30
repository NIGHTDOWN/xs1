
import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/model/cate.dart';
import 'package:ng169/page/home/novel_first_hybird_card.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/home/novel_list_more_choose.dart';
import 'package:ng169/page/home/novel_normal_card.dart';
import 'package:ng169/page/home/novel_second_hybird_card.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';

// ignore: must_be_immutable
class CatePage extends LoginBase {
  bool needlogin = false;
  late List hotbook, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'mallcate_';
  var cachedata = 'mallcate_data_', page = 1;
  var cachehittory = 'cachecatehittory';
  //List searchword = new List(16);
  List searchword = [];
  String sapi = 'cate/get';
  //String api = 'common/book_search';
  bool load = true;
  bool moredata = false, stop = false, showsearch = false, haveword = false;
  // int max_search_history = 12;
  ScrollController scrollController = ScrollController();
  double boxSize = 80.0;
  TextEditingController searword = new TextEditingController();

  var cate;
  getpost() {
    var data = {
      "c1": selecttype,
      "c2": selectc1,
      "c3": selectc2,
      "c4": selectc3,
    };

    return data;
  }

  gethttpdata() async {
    //显示状态
    //清空page
    showsearch = true;
    load = true;
    more = [SizedBox()];
    scrollController.jumpTo(0);
    reflash();
    gettagheight();
    page = 0;
    Map<String, dynamic> datap = getpost();
    datap.addAll({'page': page});
    var datatmp = loadpage(datap);
    var data;

    if (isnull(datatmp, 0)) {
      data = datatmp[1];
    } else {
      var tmpsearchdata = await http(sapi, datap, gethead());
      data = getdata(context, tmpsearchdata!);

      if (isnull(data)) {
        setpagecache(datap, data);
      }
    }

    if (isnull(data)) {
      var w = bookCardWithInfo(5, '', data);
      more.add(w);
      load = false;
      reflash();
    } else {
      //搜索无结果换个关键词试试
      more = [nonepage()];
      load = false;
      reflash();
    }
  }

  Widget nonepage() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: tagHeight * .273,
          ),
          Container(
              margin: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.book,
                color: Colors.grey[200],
                size: 130,
              )),
          Text(lang('书籍还没整理进来哦')),
          Text(lang('等待整理哦'))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    var hascode = 'catepage'.hashCode;
    index = index + hascode.toString();
    index = index + getlang();
    cachedata = cachedata + hascode.toString();

    cachehittory = cachehittory + hascode.toString();

    loadcate();

    scrollController.addListener(() {
      listenscrool();
      loadmore();
    });
  }

  GlobalKey listGlobalKey = GlobalKey();
  var tagHeight;
  listenscrool() {
    var offset = scrollController.offset;
    gettagheight();
    showixed1 = false;
    if (offset >= tagHeight) {
      // d('显示漂浮');
      showixed = true;
    } else if (offset < tagHeight) {
      // d('隐藏漂浮');
      showixed = false;
    }
    reflash();
  }

  gettagheight() {
    try {
      var tt = listGlobalKey.currentContext
          ?.findRenderObject()
          ?.semanticBounds
          .size
          .height;
      if (isnull(tt) && tt != tagHeight) {
        tagHeight = tt;
      }
    } catch (e) {
       dt(e);
    }
  }

  loadcate() async {
    try {
      cate = await Catemodel.getcate();
      cateleft = cate[0]['child'];
      selectc1 = cate[0]['child'][0]['category_id'];
      tag = cate[0]['child'][0]['child'];
      gethttpdata();
      setState(() {});
    } catch (e) {
       dt(e);
    }
  }

  loadingstatu() {
    setState(() {
      moredata = !moredata;
    });
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (!showsearch) {
        //进入搜索页面才加载
        return false;
      }
      if (stop) {
        //尾部停止
        return false;
      }
      loadingstatu();
      Map<String, dynamic> datap = getpost();
      datap.addAll({'page': page++});

      var data = await http(sapi, datap, gethead());
      var tmpmore = getdata(context, data!);
      if (isnull(tmpmore)) {
        more.add(bookCardWithInfo(5, '', tmpmore));
        // page++;
      } else {
        stop = true;
      }
      loadingstatu();
    }
  }

  //加载页面
  //先读缓存
  //在读http数据
  loadpage(Map<String, dynamic> data) {
    //20分钟刷新缓存数据重新加载

    String lang = getlang();
    String hascode = data.toString().hashCode.toString() + lang;
    var indextmp = index + hascode;
    var cachedatatmp = cachedata + hascode;
    d(cachedatatmp);
    var mallcachebool = getcache(indextmp);
    var f1, f2;
    if (!isnull(mallcachebool)) {
      f1 = false;
      f2 = false;
    } else {
      f1 = true;
      mallcache = getcache(cachedatatmp);

      if (isnull(mallcache)) {
        f2 = mallcache;
      } else {
        f1 = false;
        setcache(indextmp, 0, '0');
      }
    }
    return [f1, f2];
  }

  setpagecache(Map<String, dynamic> data, save) {
    String lang = getlang();

    String hascode = data.toString().hashCode.toString() + lang;
    var indextmp = index + hascode;
    var cachedatatmp = cachedata + hascode;
    setcache(indextmp, 1, '3600');
    d(cachedatatmp);
    setcache(cachedatatmp, save, '-1');
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang('分类')),
      ),
      body: Loadbox(
        bgColor: SQColor.white,
        loading: !isnull(cate),
        child: Column(
          children: <Widget>[
            gettop(),
            Expanded(
                child: Row(
              children: <Widget>[
                getleft(),
                getcenter(),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget gettop() {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: SQColor.white,
          border: Border(
              // 四个值 top right bottom left
              bottom: BorderSide(
                  // 设置单侧边框的样式
                  color: SQColor.white,
                  width: 1,
                  style: BorderStyle.solid))),
      child: Row(
        children: <Widget>[
          gettbtn(lang('女生'), 1),
          gettbtn(lang('男生'), 2),
          gettbtn(lang('女漫'), 3),
          gettbtn(lang('男漫'), 4)
        ],
      ),
    );
  }

  var selectc1, selectc2 = 0, selectc3 = 1, selecttype = 1;
  List cateleft = [], tag = [];
  Widget gettbtn(String title, int type) {
    var btn = TextButton(
      child: Text(title),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (selecttype != type) {
            return SQColor.lightGray;
          }
          return SQColor.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (selecttype == type) {
            return SQColor.white;
          }
          return SQColor.darkGray;
        }),
        shape: WidgetStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(borderRadius: BorderRadius.circular(7));
        }),
      ),

      // color: selecttype != type ? SQColor.lightGray : SQColor.primary,
      // textColor: selecttype == type ? SQColor.white : SQColor.darkGray,
      // // elevation: 20,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      onPressed: () {
        if (selecttype == type) return;
        var s;
        switch (type) {
          case 1:
            s = cate[0];
            break;
          case 2:
            s = cate[1];
            break;
          case 3:
            s = cate[0];
            break;
          case 4:
            s = cate[1];
            break;
          default:
            ;
        }
        selecttype = type;
        cateleft = s['child'];
        selectc1 = cateleft[0]['category_id'];
        selectc2 = 0;
        tag = cateleft[0]['child'];
        gethttpdata();
        reflash();
      },
    );
    var c = Container(
      child: btn,
      margin: EdgeInsets.all(3),
    );

    return Expanded(
      child: c,
    );
  }

  Widget getlbtn(cateobj) {
    // GestureDetector
    bool isselect = selectc1 == cateobj['category_id'];
    var btn = Container(
      child: Text(lang('c' + cateobj['category_id']),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: !isselect ? SQColor.darkGray : SQColor.primary,
          )),
      padding: EdgeInsets.only(top: 15, bottom: 15),
      decoration: BoxDecoration(
          color: isselect ? SQColor.lightGray : SQColor.white,
          border: Border(
              // 四个值 top right bottom left
              left: BorderSide(
                  // 设置单侧边框的样式
                  color: !isselect ? SQColor.white : SQColor.primary,
                  width: 4,
                  style: BorderStyle.solid))),
    );
    var c = GestureDetector(
      child: ClipRRect(
        child: btn,
        borderRadius: BorderRadius.only(topRight: Radius.circular(10.0)),
      ),
      onTap: () {
        if (isselect) return;
        selectc1 = cateobj['category_id'];
        tag = cateobj['child'];
        selectc2 = 0;
        gethttpdata();
        reflash();
      },
      // margin: EdgeInsets.all(3),
    );
    return c;
  }

  Widget getleft() {
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        color: SQColor.white,
        child: ListView.builder(
          itemCount: cateleft.length,
          itemBuilder: (context, index) {
            return getlbtn(cateleft[index]);
          },
        ),
      ),
      flex: 1,
    );
  }

  bool showixed = false, showixed1 = false;
  Widget getfixed() {
    if (!showixed) return Container();
    if (showixed1) {
      return Container(
          height: tagHeight + 3,
          decoration: new BoxDecoration(
            color: SQColor.white,
            border: Border(
                bottom: BorderSide(
                    // 设置单侧边框的样式
                    color: Colors.transparent,
                    width: 1,
                    style: BorderStyle.solid)), // 边色与边宽度
          ),
          child: Column(children: [
            alltag(),
            alltag2(),
          ]));
    }
    return Container(
        decoration: new BoxDecoration(
          color: SQColor.white,
          border: Border(
              bottom: BorderSide(
                  // 设置单侧边框的样式
                  color: Colors.transparent,
                  width: 1,
                  style: BorderStyle.solid)), // 边色与边宽度
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gettag1text(),
              gettag2text(),
              GestureDetector(
                  onTap: () {
                    showixed1 = true;
                    reflash();
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: SQColor.primary,
                    size: 23,
                  ))
            ]));
  }

  gettag1text() {
    String str;
    if (selectc2 == 0) {
      str = lang('全部');
    } else {
      str = lang('t' + selectc2.toString());
    }

    return Container(
      margin: EdgeInsets.only(left: 8, right: 5, bottom: 5),
      child: Text(
        str,
        style: TextStyle(
          fontSize: 13,
          color: SQColor.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  gettag2text() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 5, bottom: 5),
      child: Text(
        tag2[selectc3 - 1],
        style: TextStyle(
          fontSize: 13,
          color: SQColor.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget getcenter() {
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
          // margin: EdgeInsets.all(5.0),
          color: SQColor.white,
          child: Loadbox(
            loading: load,
            // bgColor: SQColor.white,
            hasmask: false,
            child: Stack(children: [
              ListView(controller: scrollController, children: [
                Column(key: listGlobalKey, children: [
                  alltag(),
                  alltag2(),
                ]),
                // alltag(),
                // alltag2(),
                Column(
                  children: more,
                ),
                isnull(showsearch && moredata)
                    ? _buildProgressIndicator()
                    : SizedBox()
              ]),
              getfixed(),
            ]),
          ) // color: SQColor.orange,
          ),
      flex: 3,
    );
  }

  Widget gettagbtn(obj) {
    return GestureDetector(
      child: gtext(lang('t' + obj['category_name']), obj['category_name']),
      // child: Container(
      //     margin: EdgeInsets.only(left: 5, right: 5, top: 3),
      //     child: Text(
      //       lang('t' + obj['category_name']),
      //       style: TextStyle(
      //         fontSize: 13,
      //         fontWeight: checktagon(obj['category_name'])
      //             ? FontWeight.bold
      //             : FontWeight.w100,
      //         color: checktagon(obj['category_name'])
      //             ? SQColor.primary
      //             : SQColor.darkGray,
      //       ),
      //     )),
      onTap: () {
        stag(obj['category_name']);
      },
    );
  }

  bool checktagon(id) {
    if (id is String) {
      id = int.parse(id);
    }
    if (id == selectc2) {
      return true;
    } else {
      return false;
    }
  }

  bool checktagon2(id) {
    if (id is String) {
      id = int.parse(id);
    }
    if (id == selectc3) {
      return true;
    } else {
      return false;
    }
  }

  Widget alltag() {
    List<Widget> list = [];

    tag.forEach((element) {
      var obj = gettagbtn(element);
      if (isnull(obj)) {
        list.add(obj);
      }
    });

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: gtext(lang('全部'), 0),
            onTap: () {
              stag(0);
            },
          ),
          Expanded(child: Wrap(children: list)),
        ]);
  }

  List tag2 = [lang('最新'), lang('最热'), lang('完结')];
  Widget alltag2() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: gtext2(tag2[0], 1),
            onTap: () {
              stag2(1);
            },
          ),
          GestureDetector(
            child: gtext2(tag2[1], 2),
            onTap: () {
              stag2(2);
            },
          ),
          GestureDetector(
            child: gtext2(tag2[2], 3),
            onTap: () {
              stag2(3);
            },
          ),
          // Expanded(child: Wrap(children: list)),
        ]);
  }

  Widget gtext(name, id) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 5, top: 10),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 13,
          color: checktagon(id) ? SQColor.primary : SQColor.darkGray,
          fontWeight: checktagon(id) ? FontWeight.bold : FontWeight.w100,
        ),
      ),
    );
  }

  Widget gtext2(name, id) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 5, top: 5, bottom: 5),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 13,
          color: checktagon2(id) ? SQColor.primary : SQColor.darkGray,
          fontWeight: checktagon2(id) ? FontWeight.bold : FontWeight.w100,
        ),
      ),
    );
  }

  stag(tagid) {
    if (tagid is String) {
      tagid = int.parse(tagid);
    }
    if (selectc2 == tagid) return;
    selectc2 = tagid;
    gethttpdata();
    reflash();
  }

  stag2(tagid) {
    if (tagid is String) {
      tagid = int.parse(tagid);
    }
    if (selectc3 == tagid) return;
    selectc3 = tagid;
    gethttpdata();
    reflash();
  }

  Widget bookCardWithInfo(int style, String title, List json) {
    Widget card=new SizedBox();
    switch (style) {
      case 1:
        card = NovelFourGridView(title, json, false);
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
        card = NovelmorechooseCard(json, searword.text, false);
        break;
    }
    return card;
  }

  Widget _buildProgressIndicator() {
    var circular = new CircularProgressIndicator(
      backgroundColor: Colors.white,
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
      padding: EdgeInsets.all(12.0),
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
