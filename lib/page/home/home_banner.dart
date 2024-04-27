import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';

import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

// ignore: must_be_immutable
class HomeBanner extends StatelessWidget {
  final List banners;
  BuildContext context=Null as BuildContext;
  HomeBanner(this.banners);
  HashMap tmplist = new HashMap();
  Widget banner(info) {
    var bneer = Container(
        width: Screen.width,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: isnull(info, 'banner_pic')
            ? NgImage(info['banner_pic'])
            : Container());
    return GestureDetector(
      child: bneer,
      onTap: () {
        _bannerclick(info);
      },
    );
  }

  _bannerclick(info) async {
    //1网页、2小说、3漫画、4充值 5 网页充值
    switch (int.parse(info['goal_type'])) {
      case 1:
        if (isnull(info['banner_url'])) {
          gourl(
              context,
              Bow(
                url: info['banner_url'], title: '',
              ));
        }
        break;
      case 2:
        if (isnull(info['book_id'])) {
          Novel novel;
          int id = int.parse(info['book_id']);
          if (isnull(tmplist) && isnull(tmplist[id.toString()])) {
            novel = tmplist[id.toString()];
          } else {
            novel = await Novel.fromID(id, 1);
            tmplist.addAll({id.toString(): novel});
          }
          if (info['goal_window'] == '2') {
            novel.read(context);
          } else {
            gourl(context, NovelDetailScene(novel));
          }
        }
        break;
      case 3:
        if (isnull(info['cartoon_id'])) {
          Novel novel;
          int id = int.parse(info['cartoon_id']);
          if (isnull(tmplist) && isnull(tmplist[id.toString()])) {
            novel = tmplist[id.toString()];
          } else {
            novel = await Novel.fromID(id, 2);

            tmplist.addAll({id.toString(): novel});
          }

          if (info['goal_window'] == '2') {
            novel.read(context);
          } else {
            gourl(context, NovelDetailScene(novel));
          }
        }
        break;
      case 4:
        //充值页面
        gourl(context, Recharge());
        break;
      case 5:
        if (isnull(info['banner_url'])) {
          gourl(
              context,
              Bow(
                url: info['banner_url'], title: '',
              ));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (banners.length == 0) {
      return SizedBox();
    }
    this.context = context;
    // ignore: deprecated_member_use
    double top = MediaQueryData.fromWindow(window).padding.top;
    return Container(
      margin: EdgeInsets.only(top: top),
      color: Colors.white,
      child: CarouselSlider(
        items: banners.map((info) {
          return Builder(
            builder: (BuildContext context) {
              return banner(info);
            },
          );
        }).toList(),
        // aspectRatio: 2,
        // autoPlay: true,
        options: new CarouselOptions(aspectRatio: 2, autoPlay: true),
      ),
    );
  }
}
