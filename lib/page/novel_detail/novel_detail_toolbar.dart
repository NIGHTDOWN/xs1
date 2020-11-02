import 'package:flutter/material.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/reader/reader_scene.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

// StatelessWidget
class NovelDetailToolbar extends StatefulWidget {
  final Novel novel;
  NovelDetailToolbar(this.novel);

  State<StatefulWidget> createState() => _NovelDetailToolbarState();
}

class _NovelDetailToolbarState extends State<NovelDetailToolbar> {
  String isgroom;
  String isdown;
  read(context) {
    //获取当前书阅读章节id
    widget.novel.read(context, widget.novel.readChapter);
  }

  @override
  void initState() {
    super.initState();
    isgroom = this.widget.novel.isgroom;
    isdown = this.widget.novel.isdownload;
    getdown();
    getgroom();
  }

  getgroom() async {
    isgroom = await this.widget.novel.getgroom();

    reflash();
  }

  getdown() async {
    isdown = await this.widget.novel.isdown();
    reflash();
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
      decoration:
          BoxDecoration(color: Colors.white, boxShadow: Styles.borderShadow),
      height: 50 + Screen.bottomSafeHeight,
      child: Row(children: <Widget>[
        Expanded(
          child: Center(
            child: !isnull(isgroom)
                ? GestureDetector(
                    child: Text(
                      lang('加入书架'),
                      style: TextStyle(fontSize: 16, color: SQColor.primary),
                    ),
                    onTap: () {
                      addgroom(context);
                    },
                  )
                : Text(
                    lang('已添加'),
                    style: TextStyle(fontSize: 16, color: SQColor.gray),
                  ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              read(context);
              // AppNavigator.pushReader(context, novel.firstArticleId);
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: SQColor.primary,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  lang('开始阅读'),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        widget.novel.type == '1'
            ? Expanded(
                child: !isnull(isdown)
                    ? GestureDetector(
                        onTap: () {
                          down();
                        },
                        child: Center(
                          child: Text(
                            lang('缓存'),
                            style:
                                TextStyle(fontSize: 16, color: SQColor.primary),
                          ),
                        ))
                    : Center(
                        child: Text(
                          int.parse(widget.novel.downrate) < 100
                              ? lang('缓存中')
                              : lang('已缓存'),
                          style: TextStyle(fontSize: 16, color: SQColor.gray),
                        ),
                      ),
              )
            : SizedBox(width: 10),
      ]),
    );
  }

  addgroom(context) async {
    //判断登入状态
    //if (islogin()) {}

    var user = User.get();
    if (!isnull(user)) {
      gourl(context, new Index());
    } else {
      //添加书架？
      widget.novel.addgroom();
      //改变文字状态
      //加入或者移除数据接口
      isgroom = '1';
      setState(() {});
    }
  }

  down() async {
    //添加书架？
    widget.novel.down();
    //改变文字状态
    //加入或者移除数据接口
    isdown = '1';
    setState(() {});
  }
}
