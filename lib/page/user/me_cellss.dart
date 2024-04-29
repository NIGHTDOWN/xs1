import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

class MeCellss extends LoginBase {
  final VoidCallback onPressed;
  final String iconName;
  final String title;
  final double line_padding_left;
  final Widget right_widget;
  final bool haveline;
  final bool havemsg;
  bool needlogin = true;

  var size = 10.0;

  MeCellss(
      {required this.title,
    required  this.iconName,
    required  this.onPressed,
    required  this.line_padding_left,
    required  this.right_widget,
      this.havemsg = false,
      this.haveline = true});
  @override
  Widget build(BuildContext context) {
     var qjin = Icon(
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
                  havemsg
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          child: ClipOval(
                            child: Container(
                              width: size,
                              height: size,
                              color: Colors.red,
                              child: Center(
                                  child: ClipOval(
                                child: Container(
                                    width: size,
                                    height: size,
                                    color: Colors.red),
                              )),
                            ),
                          ))
                      : Container(),
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
