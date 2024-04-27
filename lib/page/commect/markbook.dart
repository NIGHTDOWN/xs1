import 'package:flutter/material.dart';
import 'package:ng169/model/cate.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/home/home_section_view.dart';

import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/page/commect/mark_detail_header.dart';

class MarkBook extends StatefulWidget {
  final Novel novel;

  const MarkBook({Key? key, required this.novel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MarkBookState();
}

class MarkBookState extends State<MarkBook> {
  TextEditingController comments = new TextEditingController();
  double star = 10.0;
  String api = 'mark/getcategory';
  String subapi = 'task/mark';
  var groupValue;
  var groupValue2;
  List groupValue3 = [];
  late List cate;
  List w2 = [];
  List w3 = [];
  // String cachedata = 'category_data_';
  // String cachedatatime = 'category_data_time';
  @override
  initState() {
    super.initState();
    loadcate();
    // if (isnull(getcache(cachedata))) {
    //   cate = getcache(cachedata);
    //   if (!isnull(getcache(cachedatatime))) {
    //     httpget();
    //   }
    // } else {
    //   httpget();
    // }
  }

  loadcate() async {
    cate = await Catemodel.getcate();
    setState(() {});
  }
  // httpget() async {
  //   var data = await http(api, {}, gethead(), 30);
  //   List tmp = getdata(context, data);
  //   if (isnull(tmp)) {
  //     cate = tmp;
  //     setcache(cachedata, tmp, '-1');
  //     setcache(cachedatatime, 1, '7200');
  //   }
  //   setState(() {});
  // }

  Future<void> gethttpdata() async {
    refresh();
  }

  @override
  void dispose() {
    // scrollController.dispose();
    super.dispose();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // titlebarcolor(true);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(lang('添加标签')),
        ),
      ),
      backgroundColor: SQColor.white,
      body: SingleChildScrollView(
        //防止弹键盘溢出
        child: body(),
      ),
    );
  }

  submit() async {
    if (!isnull(groupValue)) {
      show(context, lang('请选择主类'));
      return;
    }
    if (!isnull(groupValue2)) {
      show(context, lang('请选择类目'));
      return;
    }
    if (!isnull(groupValue3)) {
      show(context, lang('请选择标签'));
      return;
    }
    Map<String, dynamic> tmp = {};
    // String content = comments.text;

    tmp.addAll({'id': widget.novel.id});
    tmp.addAll({'type': widget.novel.type});
    tmp.addAll({'c1': groupValue['category_id']});
    tmp.addAll({'c2': groupValue2['category_id']});
    String t3 = '';
    groupValue3.forEach((element) {
      t3 += element['category_id'] + ',';
    });
    tmp.addAll({'t3': t3});
    var back = await http(subapi, tmp, gethead());
    var data = getdata(context, back!);

    if (isnull(data)) {
      // show(context, lang('感谢提交'));
      pop(context, 1);
    } else {
      pop(context, -1);
    }
  }

  void _changed3(value) {
    if (groupValue3.length >= 3) {
      show(context, lang('最多选三项'));
      return;
    }
    if (value['depth'].toString() == '3') {
      groupValue3.add(value);
    }
    refresh();
  }

  void _changed4(value) {
    if (checksin(value)) {
      groupValue3.remove(value);
    }
    refresh();
  }

  void _changed2(value) {
    groupValue2 = value;

    groupValue3 = [];
    w3 = value['child'];
    refresh();
  }

  void _changed(value) {
    if (value['depth'].toString() == '1') {
      groupValue = value;
      w2 = value['child'];
      w3 = [];
      groupValue3 = [];
      groupValue2 = null;
    }
    refresh();
  }

  List<Widget> getwrong() {
    List<Widget> ret = [];
    // ignore: unused_local_variable
    int i = 0;
    var tmpobj;
    var tmpobj1;
    if (isnull(cate)) {
      cate.forEach((obj) {
        tmpobj = Radio(value: obj, groupValue: groupValue, onChanged: _changed);
        tmpobj1 = SizedBox(
          width: getScreenWidth(context) * .45,
          child: Row(
            children: <Widget>[
              tmpobj,
              Expanded(
                child: Text(lang("c" + obj['category_id'])),
              )
            ],
          ),
        );

        ret.add(tmpobj1);
        i++;
      });
      // d(ret);
      return ret;
    }
    return [Container()];
  }

  List<Widget> getwrong2() {
    List<Widget> ret = [];
    // ignore: unused_local_variable
    int i = 0;
    var tmpobj;
    var tmpobj1;
    if (isnull(w2)) {
      w2.forEach((obj) {
        tmpobj =
            Radio(value: obj, groupValue: groupValue2, onChanged: _changed2);
        tmpobj1 = SizedBox(
          width: getScreenWidth(context) * .45,
          child: Row(
            children: <Widget>[
              tmpobj,
              Expanded(
                child: Text(lang("c" + obj['category_id'])),
              )
            ],
          ),
        );

        ret.add(tmpobj1);
        i++;
      });
      // d(ret);
      return ret;
    }
    return [Container()];
  }

  checksin(obj) {
    if (groupValue3.contains(obj)) {
      return true;
    }
    return false;
  }

  Widget getsnone(obj) {
    var btn = TextButton(
      child: Text(lang("t" + obj['category_name'])),
      // color: SQColor.gray,
      // textColor: Colors.white,
      // elevation: 20,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => SQColor.gray),
          foregroundColor:
              MaterialStateProperty.resolveWith((states) => SQColor.white),
          shape: MaterialStateProperty.resolveWith((states) =>
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),

      onPressed: () {
        _changed3(obj);
      },
    );
    return Container(
      child: btn,
      margin: EdgeInsets.all(4),
    );
  }

  Widget getson(obj) {
    var btn = TextButton(
      child: Text(lang("t" + obj['category_name'])),
      // color: SQColor.orange,
      // textColor: Colors.white,
      // elevation: 20,

      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => SQColor.orange),
          foregroundColor:
              MaterialStateProperty.resolveWith((states) => SQColor.white),
          shape: MaterialStateProperty.resolveWith((states) =>
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
      onPressed: () {
        _changed4(obj);
      },
    );

    var ret = Stack(children: [
      btn,
      Container(
        child: Icon(
          Icons.check_circle,
          color: SQColor.paper,
        ),
        margin: EdgeInsets.only(top: 11.5),
      )
    ]);
    return Container(
      child: ret,
      margin: EdgeInsets.all(4),
    );
  }

  List<Widget> getwrong3() {
    List<Widget> ret = [];

    var tmpobj;

    if (isnull(w3)) {
      w3.forEach((obj) {
        tmpobj = !checksin(obj) ? getsnone(obj) : getson(obj);
        ret.add(tmpobj);
      });

      return ret;
    }
    return [Container()];
  }

  var stag, tags, tagwidgets;
  Widget kk(List<Widget> lists) {
    return Container(
        margin: EdgeInsets.only(left: 14, right: 14),
        child: Column(
          children: <Widget>[
            isnull(lists)
                ? Wrap(
                    children: lists,
                  )
                : Container(),
            // Divider(),
          ],
        ));
  }

  Widget body() {
    return Column(
      children: <Widget>[
        MarkDetailHeader(widget.novel),
        SizedBox(
          height: 10,
        ),
        kk([
          Text(lang('请正确回答，错误的回答可能导致奖励无法领取，或者以后无法参与该任务'),
              overflow: TextOverflow.clip,
              style: TextStyle(fontSize: 13, color: SQColor.gray))
        ]),
        HomeSectionView(lang('选择主类')),
        kk(getwrong()),
        HomeSectionView(lang('选择类目')),
        kk(getwrong2()),
        HomeSectionView(lang('添加标签(最多选择3个)')),
        SizedBox(
          height: 10,
        ),
        kk(getwrong3()),
        SizedBox(
          width: 15,
          height: 20,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 15,
              height: 40,
            ),
            Expanded(
              child: TextButton(
                  // color: SQColor.primary,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => SQColor.primary)),
                  onPressed: submit,
                  child: Padding(
                    child: Text(
                      lang('提交'),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    padding: EdgeInsets.all(5),
                  )),
            ),
            SizedBox(
              width: 15,
            ),
          ],
        ),
        SizedBox(
          width: 15,
          height: 20,
        ),
      ],
    );
  }
}
