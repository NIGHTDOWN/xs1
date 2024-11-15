import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';

class MeCells extends LoginBase with WidgetsBindingObserver {
  final VoidCallback onPressed;
  final String iconName;
  final String title;
  final double line_padding_left;
  final Widget right_widget;
  final bool haveline;
  bool needlogin = true;
  static int msgnum = 0;
  @override
  void initState() {
    // TODO: implement initState

    msgnum = toint(g("msg"));
    loadbus();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (mounted) {
      reflash();
    }
  }

  reloadmsgnum() {
    msgnum = toint(g("msg"));
    reflash();
  }

  loadbus() {
    eventBus.on('user_im_on', (data) {
      reloadmsgnum();
    });
  }

  offbus() {
    eventBus.off('user_im_on');
  }

  @override
  void dispose() {
    offbus();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 页面可见时执行的操作

      reloadmsgnum();
    } else if (state == AppLifecycleState.paused) {
      // 页面不可见时执行的操作
    }
  }

  MeCells(
      {required this.title,
      required this.iconName,
      required this.onPressed,
      required this.line_padding_left,
      required this.right_widget,
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
        color: SQColor.white,
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
                  Expanded(
                      flex: 4,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  // Text(title, style: TextStyle(fontSize: 18)),
                  // Expanded(
                  //   child: Container(),
                  //   // fit: FlexFit.loose,
                  // ),

                  isnull(msgnum)
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          child: ClipOval(
                            child: Container(
                              width: 20,
                              height: 20,
                              color: Colors.red,
                              child: Center(
                                  child: Text(tostring(msgnum),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13, color: SQColor.white))),
                            ),
                          ))
                      : Container(
                          width: 20,
                        ),
                  // isnull(right_widget) ? right_widget : qjin,
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
