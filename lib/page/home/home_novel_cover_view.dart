import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';


class HomeNovelCoverView extends StatelessWidget {
  final Novel novel;
  HomeNovelCoverView(this.novel);

  @override
  Widget build(BuildContext context) {
   
    var width = (Screen.width - 15 * 2 - 15 * 3) / 4;
    return GestureDetector(
      onTap: () {
       // AppNavigator.pushNovelDetail(context, novel);
        gourl(context, NovelDetailScene(novel));
      },
      child: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NgImage(novel.imgUrl, width: width, height: width / 0.75),
            SizedBox(height: 5),
            Text(
              novel.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            SizedBox(height: 3),
            Text(
              novel.author,
              style: TextStyle(fontSize: 12, color: SQColor.gray),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
