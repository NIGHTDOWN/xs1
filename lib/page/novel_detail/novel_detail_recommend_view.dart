import 'package:flutter/material.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_bar.dart';
import 'package:ng169/style/sq_color.dart';

class NovelDetailRecommendView extends StatelessWidget {
  final List<Novel> novels;

  NovelDetailRecommendView(this.novels);

  Widget buildItems() {
    // var children = novels.map((novel) => HomeNovelCoverView(novel)).toList();
    // return Container(
    //   padding: EdgeInsets.symmetric(horizontal: 15),
    //   child: Wrap(spacing: 15, runSpacing: 20, children: children),
    // );
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SQColor.white,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: <Widget>[
                SQBar.gettitlebar(),
                SizedBox(width: 13),
                Text('看过本书的人还在看', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          buildItems(),
        ],
      ),
    );
  }
}
