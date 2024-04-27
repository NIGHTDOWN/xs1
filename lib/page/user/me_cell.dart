import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

class MeCell extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconName;
  final String title;
  final double line_padding_left;
  final Widget right_widget;
  final bool haveline;

  MeCell(
      {required this.title,
      required this.iconName,
      required this.onPressed,
       this.line_padding_left=0,
      required this.right_widget,
      this.haveline = true});
  @override
  Widget build(BuildContext context) {
   
    Widget qjin = Icon(
      Icons.keyboard_arrow_right,
      color: SQColor.gray,
    );
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              color: SQColor.white,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  isnull(iconName)
                      ? Image.asset(
                          iconName,
                          width: 18,
                        )
                      : SizedBox(),
                  isnull(iconName) ? SizedBox(width: 20) : SizedBox(),
                  Text(title, style: TextStyle(fontSize: 18)),
                  Expanded(child: Container()),
                  isnull(right_widget) ? right_widget : qjin,
                ],
              ),
            ),
            haveline
                ? Container(
                    height: 1,
                    color: SQColor.lightGray,
                    margin: EdgeInsets.only(
                        left:
                            isnull(line_padding_left) ? line_padding_left : 60),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
