import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';

import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/url.dart';

// ignore: must_be_immutable
class BookBanner extends LoginBase {
  final List banners;
  static var novels = {};
  BuildContext context;
  BookBanner(this.banners);
  HashMap tmplist = new HashMap();
  static String bgimg;
  // SwiperController sw = SwiperController();
  static double hd = 8;
  void initState() {
    hd = g('swidth') / 25;
    if (isnull(banners)) {
      BookBanner.bgimg = banners[0]['bpic'];
    }
  }

  Novel getnovel(info) {
    // d(info);
    if (isnull(novels, info['book_id'])) {
      return novels[info['book_id']];
    } else {
      Novel novel = Novel.fromJson(info);
      novels.addAll({info['book_id']: novel});
      return novel;
    }
    // banners.forEach((element) {
    //   novels.add(Novel.fromJson(element));
    // });
  }

  void dispose() {
    super.dispose();
    // sw.dispose();
  }

  Widget banner(info) {
    Novel novel = getnovel(info);
    var bneer = ClipRRect(
      borderRadius: BorderRadius.circular(BookBanner.hd),
      child: NgImage(novel.imgUrl),
    );
    // return bneer;
    return GestureDetector(
      child: bneer,
      onTap: () {
        _bannerclick(novel);
      },
    );
  }

  _bannerclick(novel) async {
    
    gourl(context, NovelDetailScene(novel));
  }

  @override
  Widget build(BuildContext context) {
    if (banners.length == 0) {
      return SizedBox();
    }

//图片 比列 3：4
    this.context = context;
    double h = g('sheight') * 0.5;
    double w = g('swidth');
    var s = h * 3 / 4 / w;
    //搜索栏高度
    double th = Screen.topSafeHeight + 20 + Screen.navigationBarHeight * .4;
    var bgHeight = w / 0.9;
    var height = Screen.topSafeHeight + 250;
    return Container(
        color: Colors.white,
        height: h + th,
        child: Stack(
          children: <Widget>[
            //背景
            Container(
              child: ClipPath(
                //路径裁切组件
                clipper: BottomClipper(), //路径
                child: Container(
                  child: Stack(children: [
                    isnull(BookBanner.bgimg)
                        ? Positioned(
                            top: height - bgHeight,
                            child: NgImage(
                              BookBanner.bgimg,
                              width: w,
                            ))
                        : SizedBox(),
                    //透明遮罩
                    BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: new Container(
                        color: Colors.black12.withOpacity(0.3),
                        width: w,
                        height: h + th,
                      ),
                    ),
                  ]),
                ),
              ),
            ),

            // banner
            Container(
              height: h,
              margin: EdgeInsets.only(top: th),
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return banner(banners[index]);
                },
                autoplayDisableOnInteraction: true, // 用户进行操作时停止自动翻页
                // pagination: new SwiperPagination(
                //     builder: DotSwiperPaginationBuilder(
                //         color: Colors.black54,
                //         activeColor: Colors.white,
                //         size: 35,
                //         activeSize: 35)),
                pagination: new SwiperCustomPagination(
                    builder: (BuildContext context, SwiperPluginConfig config) {
                  return initpage(
                      config.itemCount, config.activeIndex, config.controller);
                }),
                // controller: sw,
                itemCount: banners.length,
                viewportFraction: s,
                scale: 0.8,
                loop: true,
                duration: 2500,
                // onTap: (index) => print('点击了第$index个'),
                autoplay: true,
                onIndexChanged: (index) {
                  if (isnull(banners[index]['bpic'])) {
                    BookBanner.bgimg = banners[index]['bpic'];
                    reflash();
                  }
                },
              ),
            )
          ],
        ));
  }

  Widget initpage(int count, int index, SwiperController controller) {
    List<Widget> s = [];
    double size = 7;
    Color colore = Colors.white;
    Widget r = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: s,
    );
    for (var i = 0; i < count; i++) {
      if (i == index) {
        s.add(GestureDetector(
            onTap: () {
              controller.move(i, animation: false);
            },
            child: Container(
              margin: EdgeInsets.all(size / 2),
              width: size * 3,
              height: size,
              decoration: BoxDecoration(
                color: colore,
                shape: BoxShape.rectangle, //可以设置角度，BoxShape.circle直接圆形
                borderRadius: BorderRadius.circular(size),
              ),
            )));
      } else {
        s.add(GestureDetector(
            onTap: () {
              controller.move(i, animation: false);
            },
            child: Container(
              margin: EdgeInsets.all(size / 2),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colore,
                shape: BoxShape.rectangle, //可以设置角度，BoxShape.circle直接圆形
                borderRadius: BorderRadius.circular(size),
              ),
            )));
      }
    }
    return Column(
        children: [r, SizedBox(height: size)],
        mainAxisAlignment: MainAxisAlignment.end);
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 0); //第1个点
    path.lineTo(0, size.height - 50.0); //第2个点
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEdnPoint = Offset(size.width, size.height - 50.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEdnPoint.dx, firstEdnPoint.dy);
    path.lineTo(size.width, size.height - 50.0); //第3个点
    path.lineTo(size.width, 0); //第4个点

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}