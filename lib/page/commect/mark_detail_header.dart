import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/starbar.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/lang.dart';

class MarkDetailHeader extends StatelessWidget {
  final Novel novel;
  MarkDetailHeader(this.novel);

  @override
  Widget build(BuildContext context) {
    var width = Screen.width;
    var height = 218.0 - 54 + Screen.topSafeHeight;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          NgImage(
            novel.imgUrl,
            fit: BoxFit.fitWidth,
            width: width,
            height: height,
            placeholder: Container(),
          ),
          Container(color: Color(0xbb000000), width: width, height: height),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    //判断标题是否超过两行
    // ignore: unused_local_variable
    var h = novel.name.length >= 22 ? 4.0 : 10.0;
    h = 0;
    var width = Screen.width;
    var desc;
    if (novel.type == '1') {
      desc = [
        Text(novel.name,
            style: TextStyle(
                fontSize: fixedFontSize(18),
                color: SQColor.white,
                fontWeight: FontWeight.bold)),
        // SizedBox(height: h),
        Row(children: [
          Text(lang('状态') + ('：'),
              style:
                  TextStyle(fontSize: fixedFontSize(14), color: SQColor.white)),
          Text(novel.status,
              style: TextStyle(fontSize: 14, color: novel.statusColor()))
        ]),
        // SizedBox(height: h),
        buildScore(),
        SizedBox(height: 26),
      ];
    } else {
      desc = [
        Text(novel.name,
            style: TextStyle(
                fontSize: fixedFontSize(18),
                color: SQColor.white,
                fontWeight: FontWeight.bold)),
        // SizedBox(height: h),
        Row(children: [
          Text(lang('状态') + ('：'),
              style:
                  TextStyle(fontSize: fixedFontSize(14), color: SQColor.white)),
          Text(novel.status,
              style: TextStyle(fontSize: 14, color: novel.statusColor()))
        ]),
        // SizedBox(height: h),
        buildScore(),
        SizedBox(height: 26),
      ];
    }
    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(15, Screen.topSafeHeight, 10, 0),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          NgImage(
            novel.imgUrl,
            width: 100,
            height: 133,
            placeholder: Container(),
          ),
          SizedBox(width: 15),
          Flexible(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                // mainAxisAlignment: novel.type == '1'
                //     ? MainAxisAlignment.spaceBetween
                //     : MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: desc),
          )
        ],
      ),
    );
  }

  Widget buildScore() {
    var star = novel.score;

    star = isnull(star) ? star : 0;
    star = star > 5 ? 5 : star;
    List<Widget> children = [
      Text(lang('评分') + '：${star.toString()}' + lang('分') + '  ',
          style:
              TextStyle(fontSize: fixedFontSize(14), color: Color(0xfff8e71c)))
    ];

    var xx = RatingBar(
      value: star * 2,
      size: 15,
      padding: 3,
      nomalImage: Icon(
        Icons.star,
        size: 15,
        color: Colors.grey,
      ),
      selectImage: Icon(
        Icons.star,
        size: 15,
        color: Colors.yellow,
      ),
      selectAble: false,
      onRatingUpdate: (value) {
        d(value);
      },
      maxRating: 10,
      count: 5,
    );
    children.add(xx);
    children.add(SizedBox(width: 5));

    return Row(
      children: children,
    );
  }
}
