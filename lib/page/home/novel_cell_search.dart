import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/Novelimage.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

// ignore: must_be_immutable
class NovelsearchCell extends StatelessWidget {
  final Novel novel;
  final String search;
  var choosecolor = Colors.red;
  NovelsearchCell(this.novel, this.search);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        gourl(context, NovelDetailScene(novel));
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // NgImage(
            //   novel.imgUrl,
            //   width: 70,
            //   height: 93,
            //   placeholder: Container(),
            // ),

            Novelimage(
              novel,
              width: 70,
              height: 93,
            ),
            SizedBox(width: 15),
            Expanded(
              child: buildRight(),
            ),
          ],
        ),
      ),
    );
  }

  List _findword(String str, String find) {
    List<String> tmp = [];
    var i = 0;
    var tmp2, tmp3, tmp4;
    RegExp reg = new RegExp(find);
    Iterable<Match> matches = reg.allMatches(str);

    for (Match m in matches) {
      tmp2 = str.substring(i, m.start);
      tmp3 = str.substring(m.start, m.end);
      tmp4 = str.substring(m.end, str.length);
      i = m.end;
      if (isnull(tmp2)) {
        tmp.add(tmp2);
      }
      if (isnull(tmp3)) {
        tmp.add(tmp3);
      }
    }
    if (isnull(tmp4)) {
      tmp.add(tmp4);
    }
    if (isnull(tmp)) {
      return tmp;
    } else {
      tmp = [str];
      return tmp;
    }
  }

  Widget gettxt(List<String> txts, String find, TextStyle textStyles) {
    List<Widget> l = [];
    TextStyle light = textStyles.copyWith(color: Colors.red);
    // textStyles.color=Colors.red;
    Widget tmp;
    txts.forEach((f) {
      if (f == find) {
        //亮色
        tmp = Text(
          f,
          style: light,
        );
        l.add(tmp);
      } else {
        //原本色彩
        tmp = Text(
          f,
          style: textStyles,
        );
        l.add(tmp);
      }
    });
    return Wrap(children: l, crossAxisAlignment: WrapCrossAlignment.end);
  }

  Widget getdesctxt(List<String> txts, String find, TextStyle textStyles) {
    List<Widget> l = [];
    TextStyle light = textStyles.copyWith(color: Colors.red);
    // textStyles.color=Colors.red;
    Widget tmp;
    txts.forEach((f) {
      if (f == find) {
        //亮色
        tmp = Text(
          f,
          style: light,
        );
      } else {
        //原本色彩
        tmp = Text(
          f,
          style: textStyles,
        );
      }
      l.add(tmp);
    });
    return Wrap(children: l);
  }

  Widget buildRight() {
    var title = gettxt(_findword(novel.name, search).cast<String>(), search,
        TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
    var author = gettxt(_findword(novel.author, search).cast<String>(), search,
        TextStyle(fontSize: 14, color: SQColor.gray));
    // var desc = gettxt(_findword(novel.desc, search), search,
    //     TextStyle(fontSize: 14, color: SQColor.gray));
    // var title = Text(
    //   novel.name,
    //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    // );
    // var author = Text(
    //   novel.author,
    //   style: TextStyle(fontSize: 14, color: SQColor.gray),
    // );
    var desc = Text(
      novel.desc,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: SQColor.gray,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        SizedBox(height: 5),
        desc,
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            author,
            Expanded(child: Container()),
            buildTag(novel.status, novel.statusColor()),
            // SizedBox(width: 5),
            // buildTag(novel.type, SQColor.gray),//标签（待开发）
          ],
        )
      ],
    );
  }

  Widget buildTag(String title, Color color) {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 2, 5, 3),
      decoration: BoxDecoration(
        border: Border.all(
            color: Color.fromARGB(99, color.red, color.green, color.blue),
            width: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
