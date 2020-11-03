import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';

import 'novel_cell.dart';
import 'novel_grid_item.dart';
import 'home_section_view.dart';

class NovelFirstHybirdCard extends StatelessWidget {
  final String title;
  final List novelss;

  NovelFirstHybirdCard(this.title, this.novelss);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;
    // if (novels.length < 3) {
    //   return Container();
    // }

    List<Widget> children = [];
    var bottomNovels = novels.sublist(1);
    bottomNovels.forEach((novel) {
      children.add(NovelGridItem(Novel.fromJson(novel)));
    });
    Novel first = Novel.fromJson(novels[0]);
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          HomeSectionView(title),
          NovelCell(first),
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
