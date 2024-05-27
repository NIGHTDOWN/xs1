import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_color.dart';

import 'novel_grid_item.dart';
import 'home_section_view.dart';
import 'home_novel_cover_view.dart';

class NovelSecondHybirdCard extends StatelessWidget {
  final String title;
  final List novelss;

  NovelSecondHybirdCard(this.title, this.novelss);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;
    if (novels.length < 5) {
      return Container();
    }

    var topNovels = novels.sublist(0, 4);
    List<Widget> children = [];
    topNovels.forEach((novel) {
      children.add(HomeNovelCoverView(Novel.fromJson(novel)));
    });

    var bottomNovels = novels.sublist(4);
    bottomNovels.forEach((novel) {
      children.add(NovelGridItem(Novel.fromJson(novel)));
    });

    return Container(
      color: SQColor.white,
      child: Column(
        children: <Widget>[
          HomeSectionView(title),
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Wrap(spacing: 15, runSpacing: 15, children: children),
          ),
          Container(
            height: 10,
            color: Color(0xfff5f5f5),
          )
        ],
      ),
    );
  }
}
