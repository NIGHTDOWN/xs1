import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_color.dart';
import 'novel_cell.dart';

class NovelmoreCard extends StatelessWidget {
  final List novelss;

  NovelmoreCard(this.novelss);

  @override
  Widget build(BuildContext context) {
    var novels = novelss;
    if (novels.length <= 0) {
      return SizedBox();
    }

    List<Widget> children = [];
    for (var i = 0; i < novels.length; i++) {
      var novel = novels[i];
      // if (i != 0) {
      children.add(
        Divider(
          height: 1,
          color: SQColor.lightGray,
        ),
      );
      // }

      children.add(NovelCell(Novel.fromJson(novel)));
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
}
