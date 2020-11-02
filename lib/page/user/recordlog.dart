import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

import 'loglist.dart';

class RecordLog extends LoginBase {
   String api= 'log/record';
   String title;

  bool needlogin = true;
  RecordLog({Key key});
//   @override
//   State<StatefulWidget> createState() => RecordLogState();
// }

// class RecordLogState extends State<RecordLog> {
  List htppdata, mallcache;
  List<Widget> more = [SizedBox()];
  var index = 'RecordLog_';
  var cachedata = 'RecordLog_data_', page = 1;
  //String api2 = 'log/record';
  bool moredata = false, stop = false;
  ScrollController scrollController = ScrollController();

  Future<void> gethttpdata() async {
    var httpdatatmp = await http(api, null, gethead());
    var data2 = getdata(context, httpdatatmp);
    if (isnull(data2)) {
      htppdata = data2;
    }
    mallcache = [htppdata];
    setcache(cachedata, mallcache, '-1');
    more = [SizedBox()];
    stop = false;
    page = 1;
    reflash();
  }

  @override
  void initState() {
    super.initState();
    var hascode = api.toString().hashCode;
    
    index = index + hascode.toString();
    cachedata = cachedata + hascode.toString();

    loadpage();
    // gethttpdata();
    scrollController.addListener(() {
      loadmore();
    });
    gethttpdata();
  }

  loadingstatu() {
    moredata = !moredata;
    reflash();
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      
      if (stop) {
        return false;
      }
      loadingstatu();
      var data = await http(api, {'page': page++}, gethead());
      var tmpmore = getdata(context, data);

      if (isnull(tmpmore)) {
        more.add(objectBlock(tmpmore));
        // page++;
      } else {
        stop = true;
      }
      loadingstatu();
      reflash();
    }
  }
  //  gethttpdata(); //加载数据

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    //20分钟刷新缓存数据重新加载
    mallcache = getcache(cachedata);

    if (isnull(mallcache)) {
      htppdata = mallcache[0];
    } else {
      setcache(index, 0, '0');
    }

    var mallcachebool = getcache(index);
    //判断是否过期，过期就重新远程拉取
    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //3分钟的缓存
      setcache(index, 1, '180');
    } else {}
  }

  

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    var body = Container(
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView(
          controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            isnull(htppdata) ? objectBlock(htppdata) : SizedBox(),
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
        title: Text(lang("奖励记录")),
      ),
      backgroundColor: SQColor.white,
      body: body,
    );
  }

  Widget objectBlock(List json) {
    return LogList(json, 3);
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
