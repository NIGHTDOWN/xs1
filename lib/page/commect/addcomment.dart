import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/starbar.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';

// ignore: must_be_immutable
class AddComment extends LoginBase {
  final Novel novel;
  bool needlogin = true;
  AddComment({Key? key, required this.novel});

//   @override
//   State<StatefulWidget> createState() => AddCommentState();
// }

// class AddCommentState extends State<AddComment> {
  TextEditingController comments = new TextEditingController();
  double star = 10.0;
  String api = 'user/discuss';
  bool issbumit = true;
  @override
  initState() {
    super.initState();
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(lang("写评论")),
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
    //锁定防止重复提交。
    //评论缓存更新
    if (!issbumit) {
      return false;
    }
    issbumit = false;
    refresh();
    var starHalf = star / 2;
    Map<String, dynamic> tmp = {};
    String content = comments.text;
    if (content.length <= 0) {
      show(context, lang("请填写评论内容"));
    }
    tmp.addAll({'content': content});
    tmp.addAll({'star': starHalf});
    if (int.parse(novel.type) == 2) {
      //漫画
      tmp.addAll({'cartoon_id': novel.id});
    } else {
      //小说
      tmp.addAll({'book_id': novel.id});
    }
    var back = await http(api, tmp, gethead());
    if (isnull(getdata(context, back!))) {
      s('pl', 1);
      pop(context, 1);
    }
  }

  Widget body() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RatingBar(
            value: star,
            size: 30,
            padding: 5,
            nomalImage: Icon(
              Icons.star,
              size: 30,
              color: Colors.grey,
            ),
            selectImage: Icon(
              Icons.star,
              size: 30,
              color: Colors.yellow,
            ),
            selectAble: true,
            onRatingUpdate: (value) {
              star = value;
              setState(() {});
            },
            maxRating: 10,
            count: 5,
          ),
        ]),
        Divider(
          height: 1,
          color: SQColor.lightGray,
        ),
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
                  hintText: lang("写下优质评论,有机会得到作者的回复哦"),
                  border: InputBorder.none),
              style: new TextStyle(fontSize: 19, color: Colors.black),
              //验证
              validator: (String? value) {
                return '';
              },
              onSaved: (value) {},
            )),
        Divider(
          height: 1,
          color: SQColor.lightGray,
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
                      backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => SQColor.primary)),
                  onPressed: submit,
                  child: Padding(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang('发布评论'),
                            style:
                                TextStyle(fontSize: 16, color: SQColor.white),
                          ),
                          !issbumit
                              ? Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    //backgroundColor: Colors.blue,
                                    //value: 0.5,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            SQColor.white),
                                  ),
                                  width: 16,
                                  height: 16,
                                )
                              : Container()
                        ]),
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
