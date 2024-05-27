import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_bar.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'home_novel_cover_view.dart';

class NovelRomView extends StatelessWidget {
  final String title;
  final List novelss;
  final Function call;

  NovelRomView(this.title, this.novelss, this.call);

  @override
  Widget build(BuildContext context) {
    List novels = [];
    if (!isnull(novelss)) {
      return Container();
    }
    if (novelss.length > 4) {
      novels = novelss.sublist(0, 4);
    } else {
      novels = novelss;
    }

    // if (novels.length < 8) {
    //   return Container();
    // }
// gourl(context, NovelDetailScene(novel));
    var children = novels.map((novel) {
      var tmpnovel = Novel.fromJson(novel);
      return GestureDetector(
        child: HomeNovelCoverView(tmpnovel),
        onTap: () {
          // d(3333);
        },
      );
    }).toList();
    return Container(
      color: SQColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          gettitle(title),
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Wrap(spacing: 15, runSpacing: 20, children: children),
          ),
          Container(
            height: 10,
            color: Color(0xfff5f5f5),
          )
        ],
      ),
    );
  }

  gettitle(title) {
    return Container(
      color: SQColor.white,
      padding: EdgeInsets.fromLTRB(15, 15, 0, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SQBar.gettitlebar(),
          SizedBox(width: 10),
          Text(
            '$title',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Expanded(child: SizedBox()),
          GestureDetector(
              onTap: () {
                call();
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  lang('换一换'),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87),
                ),
                Icon(Icons.refresh, size: 18, color: Colors.black87),
                SizedBox(width: 15),
              ]))
        ],
      ),
    );
  }
}
