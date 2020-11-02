import 'package:flutter/material.dart';
import 'package:ng169/page/home/novel_first_hybird_card.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/home/novel_list_more.dart';
import 'package:ng169/page/home/novel_normal_card.dart';
import 'package:ng169/page/home/novel_second_hybird_card.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/global.dart';

class MallPage extends StatefulWidget {
  final String api;
  final String title;

  const MallPage({Key key, this.api, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() => MallPageState();
}

class MallPageState extends State<MallPage> {
  List hotbook, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'mallpage_';
  var cachedata = 'mallpage_data_', page = 1;
  String api;
  bool moredata = false, stop = false, lock = false;
  ScrollController scrollController = ScrollController();

  Future<void> gethttpdata() async {
    var hotbooks = await http(api, null, gethead());
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
    api = this.widget.api;
    var hascode = api.toString().hashCode;
    index = index + hascode.toString();
    index = index + getlang();
    cachedata = cachedata + hascode.toString();
    loadpage();
    scrollController.addListener(() {
      loadmore();
    });
  }

  loadingstatu() {
    if (!mounted) return false;

    moredata = !moredata;
    refresh();
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // d('底部' + offset.toString());
      if (stop) {
        return false;
      }
      if (lock) {
        return false;
      }
      lock = true;
      loadingstatu();
      var data = await http(api, {'page': page}, gethead());
      var tmpmore = getdata(context, data);
      lock = false;
      if (isnull(tmpmore)) {
        more.add(bookCardWithInfo(5, '', tmpmore));
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
    //20分钟刷新缓存数据重新加载
    var mallcachebool = getcache(index);
    //先直接拿缓存
    mallcache = getcache(cachedata);
    if (isnull(mallcache)) {
      hotbook = mallcache[0];
    } else {
      setcache(index, 0, '0');
    }
    //判断缓存是不是过时了，过时就重新获取
    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //半个小时的缓存
      setcache(index, 1, '1800');
    } else {
      // mallcache = getcache(cachedata);

      // if (isnull(mallcache)) {
      //   hotbook = mallcache[0];
      // } else {
      //   setcache(index, 0, '0');
      // }
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

    var body = Container(
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            isnull(hotbook)
                ? bookCardWithInfo(4, null, hotbook)
                : Column(
                    children: [
                      SizedBox(
                        height: g('sheight') * 0.14,
                      ),
                      Image.asset(
                        'assets/images/noexist.png',
                        width: g('swidth') * 0.6,
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
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
        title: Text(this.widget.title),
      ),
      backgroundColor: SQColor.white,
      body: body,
    );
  }

  Widget bookCardWithInfo(int style, String title, List json) {
    Widget card;
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
