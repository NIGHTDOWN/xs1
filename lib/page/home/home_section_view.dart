import 'package:flutter/material.dart';
import 'package:ng169/style/sq_bar.dart';
import 'package:ng169/style/sq_color.dart';

class HomeSectionView extends StatelessWidget {
  final String title;
  HomeSectionView(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SQColor.white,
      padding: EdgeInsets.fromLTRB(15, 15, 0, 5),
      child: Row(
        children: <Widget>[
          SQBar.gettitlebar(),
          SizedBox(width: 10),
          Text(
            '$title',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
