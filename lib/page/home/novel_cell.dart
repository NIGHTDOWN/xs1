import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/Novelimage.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

class NovelCell extends StatelessWidget {
  final Novel novel;

  NovelCell(this.novel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //  AppNavigator.pushNovelDetail(context, novel);
        gourl(context, NovelDetailScene(novel));
      },
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Novelimage(novel, width: 70, height: 93),
            Container(
              width: 70,
              height: 93,
              child: novel.imgdom,
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

  Widget buildRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          novel.name,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          novel.desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: SQColor.gray,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            Text(
              novel.author,
              style: TextStyle(fontSize: 14, color: SQColor.gray),
            ),
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
