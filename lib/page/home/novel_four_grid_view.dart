import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'home_section_view.dart';
import 'home_novel_cover_view.dart';

class NovelFourGridView extends StatelessWidget {
  final String title;
  final List novelss;
  final bool showbottom;

  NovelFourGridView(this.title, this.novelss, [this.showbottom = true]);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;
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
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionView(title),
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Wrap(spacing: 15, runSpacing: 20, children: children),
          ),
          showbottom
              ? Container(
                  height: 10,
                  color: Color(0xfff5f5f5),
                )
              : Container()
        ],
      ),
    );
  }
}
