import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

class NovelHistory extends StatelessWidget {
  final List novelss;

  NovelHistory(this.novelss);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;

    List<Widget> children = [];
    for (var i = 0; i < novels.length; i++) {
      var novel = Novel.fromDb(novels[i]);

      children.add(getrow(context, novel));
      children.add(
        Divider(
          height: 1,
          color: SQColor.lightGray,
        ),
      );
    }
    //children.add(Container(height: 10, color: Color(0xfff5f5f5)));

    return Container(
      color: SQColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
        // controller: scrollController,
      ),
    );
  }

  Widget getrow(BuildContext context, novel) {
    return GestureDetector(
      onTap: () {
        gourl(context, NovelDetailScene(novel));
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NgImage(
              novel.imgUrl,
              width: 70,
              height: 93,
              placeholder: Container(),
            ),
            SizedBox(width: 15),
            Expanded(
              child: buildRight(novel),
            ),
            buildTag(novel.status, novel.statusColor()),
          ],
        ),
      ),
    );
  }

  Widget buildRight(novel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          novel.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            Text(
              novel.author.toString(),
              style: TextStyle(fontSize: 14, color: SQColor.gray),
            ),
            Expanded(child: Container()),
            // buildTag(novel.status, novel.statusColor()),
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
        title.toString(),
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}
