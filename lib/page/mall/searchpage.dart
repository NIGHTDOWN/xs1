import 'package:flutter/material.dart';
import 'package:ng169/page/home/novel_first_hybird_card.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/home/novel_list_more_choose.dart';
import 'package:ng169/page/home/novel_normal_card.dart';
import 'package:ng169/page/home/novel_second_hybird_card.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

class SearchPage extends StatefulWidget {
  // final String api;
  // final String title;

  // const SearchPage({Key key, this.api, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late List hotbook, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'mallsearch_';
  var cachedata = 'mallsearch_data_', page = 1;
  var cachehittory = 'cachehittory';
  //List searchword = new List(16);
  List searchword = [];
  String api = 'book/get_randList', sapi = 'common/book_search';
  //String api = 'common/book_search';

  bool moredata = false, stop = false, showsearch = false, haveword = false;
  int max_search_history = 12;
  ScrollController scrollController = ScrollController();
  double boxSize = 80.0;
  TextEditingController searword = new TextEditingController();
  Future<void> gethttpdata() async {
    var hotbooks = await http(api, {}, gethead());
    var data2 = getdata(context, hotbooks);
    if (isnull(data2)) {
      hotbook = data2;
    }
    mallcache = [hotbook];
    setcache(cachedata, mallcache, '-1');
    more = [SizedBox()];
    stop = false;
    page = 1;
    refresh();
  }

  @override
  void initState() {
    super.initState();
    var hascode = 'searchpage'.hashCode;
    index = index + hascode.toString();
    index = index + getlang();
    cachedata = cachedata + hascode.toString();

    cachehittory = cachehittory + hascode.toString();
    var tmpsearchword = getcache(cachehittory);
    if (isnull(tmpsearchword)) {
      searchword = tmpsearchword;
    } else {
      searchword = [];
    }
    loadpage();
    scrollController.addListener(() {
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
      if (!showsearch) {
        //进入搜索页面才加载
        return false;
      }
      if (stop) {
        //尾部停止
        return false;
      }
      loadingstatu();
      var data =
          await http(sapi, {'page': page++, 'keyword': searword.text}, gethead());
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

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    //20分钟刷新缓存数据重新加载
    var mallcachebool = getcache(index);
    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //半个小时的缓存
      setcache(index, 1, '1800');
    } else {
      mallcache = getcache(cachedata);
      if (isnull(mallcache)) {
        hotbook = mallcache[0];
      } else {
        setcache(index, 0, '0');
      }
    }
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    var lchid = ListView(
      controller: showsearch ? scrollController : null,
      children: <Widget>[
        //历史记录
        //大家都在搜索
        //搜索变化
        !isnull(showsearch) ? defultPage() : SizedBox(),
        // isnull(hotbook) ? bookCardWithInfo(4, null, hotbook) : SizedBox(),
        isnull(showsearch)
            ? Column(
                children: more,
              )
            : SizedBox(),
        isnull(showsearch && moredata) ? _buildProgressIndicator() : SizedBox(),
      ],
    );

    var bodys = Container(
      padding: EdgeInsets.only(top: Screen.navigationBarHeight * .63), //顶部间距
      child: showsearch
          ? lchid
          : RefreshIndicator(
              onRefresh: gethttpdata,
              child: lchid,
            ),
    );
    return Scaffold(
      backgroundColor: SQColor.white,
      body: Stack(
        children: <Widget>[bodys, buildNavigationBar()],
      ),
    );
  }

  Widget buildNavigationBar() {
    var padding = EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 0, 12);
    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            decoration: BoxDecoration(
              //  border: Border(left: BorderSide(color: Color(0XFF302F4F),width: 0.0))
              color: SQColor.white,
              boxShadow: [
                BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
              ],
            ),
            padding: padding,
            child: buildserechbtn(),
          ),
        ),
      ],
    );
  }

  //搜索框栏目
  Widget buildserechbtn() {
    var w = getScreenWidth(context);
    var color = Colors.black;
    var textFormField2 = new TextFormField(
      maxLines: 1,
      //  maxLength:20,
      //关联焦点
      // autovalidate:true,
      // focusNode: emailFocusNode,
      controller: searword,
      onChanged: (str) {
        if (isnull(str)) {
          if (!haveword) {
            haveword = true;
            refresh();
          }
        } else {
          if (haveword) {
            haveword = false;
            showsearch = false;
            refresh();
          }
        }
        // ? haveword = true : haveword = false;
      },
      onEditingComplete: () {
        _search();
        // if (focusScopeNode == null) {
        //   focusScopeNode = FocusScope.of(context);
        // }
        // focusScopeNode.requestFocus(passwordFocusNode);
      },

      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0),
          hintText: lang("书名/作者/关键词"),
          border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String? value) {
        // if (value.isEmpty) {
        //   cansubmit = cansubmit && false;
        //   return lang('请填写账号');
        // }
        return '';
      },
      onSaved: (value) {},
    );

    var textFormField = textFormField2;
    var c = Container(
      //alignment: Alignment.centerLeft,
      // width: w * 0.85,
      height: Screen.navigationBarHeight * .4,
      margin: EdgeInsets.only(top: 12, left: w * .05),
      decoration: BoxDecoration(
          //中间按钮背景框
          // borderRadius: BorderRadius.all(Radius.circular(25)),
          // color: Color(0x552B2B2B),
          ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: Container(
                  width: 30,
                  margin: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_back,
                    color: color,
                  )
                  // ImageIcon(
                  //   AssetImage("assets/images/pub_back_gray.png",),
                  //   size: 25,
                  //   color: color,
                  // )
                  ),
              onTap: () {
                pop(context);
              },
            ),
            Expanded(
              child: textFormField,
            ),
            haveword
                ? GestureDetector(
                    child: Container(
                        margin: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[200],
                          size: 30,
                        )),
                    onTap: _clearword,
                  )
                : SizedBox(),
            SizedBox(
              width: 2,
              height: 20,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey[200]),
              ),
            ),
            GestureDetector(
              onTap: _search,
              child: Container(
                  // decoration: BoxDecoration(
                  //     border: Border(
                  //         left:
                  //             BorderSide(color: Colors.black, width: 2.0))),
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.search,
                    color: color,
                    size: 30,
                  )),
            ),
          ],
        ),
      ),
    );
    return c;
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
        card = NovelmorechooseCard(json, searword.text);
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

  //默认页面
  Widget defultPage() {
    var style1 = new TextStyle(
        fontSize: 18, color: Colors.black, fontWeight: FontWeight.w800);

    return Column(
      children: <Widget>[
        isnull(searchword)
            ? Container(
                padding: EdgeInsets.fromLTRB(8, 15, 8, 15),
                margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // var textStyle = new TextStyle(fontSize: 16, color: Colors.black);
                      children: <Widget>[
                        Text(
                          lang('最近搜索'),
                          style: style1,
                        ),
                        GestureDetector(
                          child: Container(
                              margin: EdgeInsets.only(top: 5, right: 3),
                              //margin: EdgeInsets.all(16),
                              child: Icon(
                                Icons.delete,
                                color: Colors.black38,
                                size: 20,
                              )),
                          onTap: _clearhistory,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      children: searchword.reversed
                          .map((str) => serword(str))
                          .toList(),
                      spacing: 10,
                    ),
                    // SearchItemView(),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: getScreenWidth(context),
                      height: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xdddddddd)),
                      ),
                    )
                  ],
                ))
            : SizedBox(),
        isnull(hotbook)
            ? bookCardWithInfo(1, lang('大家都在搜'), hotbook)
            : SizedBox(),
        //大家都在搜索
      ],
    );
  }

  Widget serword(String str) {
    var b = Container(
      constraints: BoxConstraints(
          // maxWidth: getScreenWidth(context) * .2,
          // maxHeight: 50,
          ),
      child: GestureDetector(
        child: Chip(
          label: Text(str),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onTap: () {
          _searhhistory(str);
        },
      ),
    );
    return b;
  }

  _clearword() {
    //切换显示为默认页面
    //按钮隐藏
    //清空文本
    haveword = false;
    searword.clear();
    showsearch = false;
    refresh();
  }

  _search() {
    //加入搜索历史
    //显示搜索列表
    //锁定下拉
    var word = searword.text;
    if (!isnull(word)) return false;
    _addhistory(word);
    _httpserach(word);
    refresh();
  }

  _clearhistory() {
//清空历史记录
//清空缓存
    searchword = [];
    setcache(cachehittory, searchword, '-1');
    // _httpserach(searword.text);
    refresh();
  }

  _addhistory(str) {
    int index = searchword.indexOf(str).toInt();
    //List.removeAt

    if (index >= 0) {
      searchword.removeAt(index);
    }

    searchword.add(str);
    if (searchword.length >= max_search_history) {
      searchword.removeAt(0);
    }
    // searchword=searchword.reversed;
    setcache(cachehittory, searchword, '-1');
  }

  _searhhistory(str) {
    _addhistory(str);
    searword.text = str;
    _httpserach(str);
    haveword = true;
    refresh();
  }

  _httpserach(str) async {
    //显示状态
    //清空page
    showsearch = true;

    page = 0;
    var tmpsearchdata =
        await http(sapi, {'keyword': str, 'page': 0}, gethead());
    var data = getdata(context, tmpsearchdata);
    if (isnull(data)) {
      more = [SizedBox()];
      var w = bookCardWithInfo(5, '', data);
      more.add(w);
      // more.add(bookCardWithInfo(5, '', data));
      refresh();
    } else {
      //搜索无结果换个关键词试试
      more = [nonepage()];
      refresh();
    }
  }

  Widget nonepage() {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: getScreenHeight(context) * .273,
          ),
          Container(
              margin: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.book,
                color: Colors.grey[200],
                size: 130,
              )),
          Text(lang('搜索无结果')),
          Text(lang('换个关键词试试？'))
        ],
      ),
    );
  }

}
