import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

class NovelDetailCell extends StatelessWidget {
  final String iconName;
  final String title;
  final String subtitle;
  final Widget attachedWidget;
  final Function onclick;

  NovelDetailCell(
      {required this.iconName,
      required this.title,
      required this.subtitle,
      required this.attachedWidget,
      required this.onclick});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SQColor.white,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: <Widget>[
          Divider(
            height: 1,
            color: SQColor.lightGray,
          ),
          Container(
            height: 50,
            child: GestureDetector(
              onTap: () {
                if (isnull(onclick)) {
                  onclick();
                }
                // gourl(context, new Catalog());
              }, //显示目录
              child: Row(
                children: <Widget>[
                  Image.asset(
                    iconName,
                    width: 23,
                  ),
                  SizedBox(width: 5),
                  Text(title, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: SQColor.gray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  attachedWidget != null ? attachedWidget : Container(),
                  SizedBox(width: 10),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: SQColor.gray,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
