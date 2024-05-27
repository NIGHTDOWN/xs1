import 'package:flutter/material.dart';

import 'package:ng169/page/home/novel_history.dart';

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/t.dart';

class HistoryPage extends StatefulWidget {
  final String api;
  final String title;

  const HistoryPage({Key? key, required this.api, required this.title})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  late List hotbook, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'mallpage_';
  var cachedata = 'mallpage_data_', page = 1, pagesize = 5;
  late String api;
  bool moredata = false, stop = false;
  ScrollController scrollController = ScrollController();

  Future<void> gethttpdata() async {
    stop = false;
    page = 1;
    loadpage();
    // refresh();
  }

  @override
  void initState() {
    super.initState();
    hotbook = [];
    loadpage();
    scrollController.addListener(() {
      loadmore();
    });
  }

  loadingstatu() {
    if (mounted) {
      setState(() {
        moredata = !moredata;
      });
    }
  }

  loadmore() async {
    //读数据库分页
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (stop) {
        return false;
      }
      loadingstatu();
      // var data = await http(api, {'page': page}, gethead());
      // var tmpmore = getdata(context, data);
      var tmpmore =
          await T('read as v left join book as b on v.bookid=b.bookid')
              .wherestring('v.uid=' + getuid() + " group by b.bookid")
              .limit((page * pagesize).toString() + ',5')
              .order('readtime desc')
              .getall();
      if (isnull(tmpmore)) {
        more.add(bookCardWithInfo(4, tmpmore));
        page++;
      } else {
        stop = true;
      }
      loadingstatu();
      refresh();
    }
  }
  //  gethttpdata(); //加载数据

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    //读数据库
    more = [];
    hotbook = await T('read as v left join book as b on v.bookid=b.bookid')
        .wherestring(
            'v.uid=' + getuid() + " and v.type in (1,2) group by b.bookid")
        .limit('5')
        .order('readtime desc')
        .getall();
    refresh();
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    var body = Container(
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            isnull(hotbook) ? bookCardWithInfo(4, hotbook) : SizedBox(),
            // SizedBox(height: 1000,child: Text('data'),),
            Column(
              children: more,
            ),
            moredata ? _buildProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('阅读历史')),
      ),
      backgroundColor: SQColor.white,
      body: body,
    );
  }

  Widget bookCardWithInfo(int style, List json) {
    Widget card = Container();
    d(json);
    switch (style) {
      case 4:
        card = NovelHistory(json);
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
