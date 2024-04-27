import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'novel_cell_search.dart';

class NovelmorechooseCard extends StatelessWidget {
  final List novelss;
  final String choosestr;

  bool showborderline;

  NovelmorechooseCard(this.novelss, this.choosestr,
      [this.showborderline = true]);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;
    if (novels.length <= 0) {
      return SizedBox();
    }

    List<Widget> children = [];
    for (var i = 0; i < novels.length; i++) {
      var novel = novels[i];
      if (showborderline) {
        children.add(Divider(height: 1));
      }

      children.add(NovelsearchCell(Novel.fromJson(novel), choosestr));
    }
    //children.add(Container(height: 10, color: Color(0xfff5f5f5)));

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
        // controller: scrollController,
      ),
    );
  }
}
