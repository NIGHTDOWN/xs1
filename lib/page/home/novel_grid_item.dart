import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

class NovelGridItem extends StatelessWidget {
  final Novel novel;

  NovelGridItem(this.novel);

  @override
  Widget build(BuildContext context) {
    var width = (Screen.width - 15 * 2 - 15) / 2;
    return GestureDetector(
      onTap: () {
        gourl(context, NovelDetailScene(novel));
      },
      child: Container(
        width: width,
        child: Row(
          children: <Widget>[
            NgImage(
              novel.imgUrl,
              width: 50,
              height: 66,
              placeholder: Container(),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    novel.name,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 16, height: 0.9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    // 'sss',
                    novel.recommendCountStr(),
                    style: TextStyle(fontSize: 12, color: SQColor.gray),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
