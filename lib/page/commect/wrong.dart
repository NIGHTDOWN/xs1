import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

class AddWrong extends StatefulWidget {
  final Novel novel;
  final String secid;
  const AddWrong({Key? key, required this.novel, required this.secid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddWrongState();
}

class AddWrongState extends State<AddWrong> {
  TextEditingController comments = new TextEditingController();
  double star = 10.0;
  String api = 'common/get_wrongtype';
  String subapi = 'user/correction';
  late String? groupValue;
  late List wrong;
  String cachedata = 'Comment_wrong_data_';
  @override
  initState() {
    super.initState();

    if (isnull(getcache(cachedata))) {
      wrong = getcache(cachedata);
    } else {
      httpget();
    }
  }

  httpget() async {
    var data = await http(api, {}, gethead());
    List tmp = getdata(context, data!);
    if (isnull(tmp)) {
      wrong = tmp;
      setcache(cachedata, tmp, '3600');
    }
    setState(() {});
  }

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
    titlebarcolor(false);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(lang("报错")),
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
    // var starHalf = star / 2;
    Map<String, dynamic> tmp = {};
    String content = comments.text;
    // if (content.length <= 0) {
    //   show(context, lang("请填写评论内容"));
    // }
    tmp.addAll({'content': content});
    tmp.addAll({'titletype': groupValue});
    tmp.addAll({'sectionid': widget.secid});
    tmp.addAll({'type': widget.novel.type});
    if (int.parse(widget.novel.type) == 2) {
      //漫画
      tmp.addAll({'wid': widget.novel.id});
    } else {
      //小说
      tmp.addAll({'wid': widget.novel.id});
    }
    var back = await http(subapi, tmp, gethead());
    if (isnull(getdata(context, back!))) {
      // s('pl', 1);
      show(context, lang('感谢提交'));
      pop(context);
    }
  }

void _changed(String? value) {
  // 现在 value 可以是 String 或 null
  if (value != null) {
    setState(() {
      groupValue = value;
    });
  }
}

  List<Widget> getwrong() {
    List<Widget> ret = [];
    int i = 0;
    var tmpobj;
    var tmpobj1;
    if (isnull(wrong)) {
      wrong.forEach((obj) {
        tmpobj = Radio<String>(
            // title: Text(obj),
            value: i.toString(),
            groupValue: groupValue,
            onChanged: _changed);
        tmpobj1 = SizedBox(
          width: getScreenWidth(context) * .45,
          child: Row(
            children: <Widget>[
              tmpobj,
              Expanded(
                child: Text(obj),
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

  Widget body() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Wrap(
          children: getwrong(),
        ),
        Divider(),
        Container(
            padding: EdgeInsets.all(10),
            child: new TextFormField(
              maxLines: 7,
              maxLength: 200,
              //关联焦点
              // autovalidate:true,
              // focusNode: emailFocusNode,
              controller: comments,
              onChanged: (str) {
                if (isnull(str)) {
                } else {}
              },
              onEditingComplete: () {},

              decoration: new InputDecoration(
                  contentPadding: EdgeInsets.only(top: -4.0),
                  hintText: lang("请描述你遇到的问题，以便我们尽快解决"),
                  border: InputBorder.none),
              style: new TextStyle(fontSize: 19, color: Colors.black),
              //验证
              validator: (String? value) {
                return '';
              },
              onSaved: (value) {},
            )),
        Divider(),
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
        )
      ],
    );
  }
}
