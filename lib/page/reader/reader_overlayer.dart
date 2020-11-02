import 'package:flutter/material.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';

import 'battery_view.dart';

class ReaderOverlayer extends StatelessWidget {
  final Article article;
  final int page;
  final double topSafeHeight;
  final Widget battery;

  ReaderOverlayer({this.article, this.page, this.topSafeHeight, this.battery});

  @override
  Widget build(BuildContext context) {
    if (!isnull(article)) return Container();
    Color color = Styles.getTheme()['titlefontcolor'];
    DateTime today = new DateTime.now();
    String time = today.hour.toString().padLeft(2, '0') +
        ":" +
        today.minute.toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.fromLTRB(
          15, 10 + topSafeHeight, 15, 10 + Screen.bottomSafeHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(article.title,
              style: TextStyle(fontSize: fixedFontSize(14), color: color)),
          Expanded(child: Container()),
          //????
          Row(
            children: <Widget>[
              battery,
              SizedBox(width: 10),
              Expanded(
                  child: Container(
                child: Center(
                  child: Text(time,
                      style:
                          TextStyle(fontSize: fixedFontSize(11), color: color)),
                ),
              )),
              Text('${page + 1}/' + article.pageCount.toString(),
                  style: TextStyle(fontSize: fixedFontSize(11), color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
