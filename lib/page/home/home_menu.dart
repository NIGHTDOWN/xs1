import 'package:flutter/material.dart';
import 'package:ng169/page/mall/mallpage.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

// ignore: must_be_immutable
class HomeMenu extends StatelessWidget {
  List infos = [
    {
      "title": lang("新书"),
      "url": "book/newbook",
      "api": "0",
      "icon": "assets/images/menu_category.png",
    },
    {
      "title": lang("免费"),
      // "url": "https:\/\/owl.shuqiread.com\/?sq_pg_param=owlri",
      "url": "book/free",
      "api": "0",
      "icon": "assets/images/menu_rank.png",
    },
    {
      "title": lang("热销"),
      "url": "book/new",
      // "http:\/\/iosbookstore.shuqiread.com\/route.php?sq_pg_param=bsvh#!\/page_id\/26\/",
      "api": "0",
      "icon": "assets/images/menu_vip.png",
    },
    {
      "title": lang("完结"),
      "url": "book/end",
      // "http:\/\/iosbookstore.shuqiread.com\/route.php?sq_pg_param=bslb#!\/page_id\/29\/",
      "api": "0",
      "icon": "assets/images/menu_complete.png",
    },
    {
      "title": lang("漫画"),
      "url": "cartoon/new_cartoon",
      "api": "0",
      "icon": "assets/images/menu_publish.png",
    }
  ];
  BuildContext? context;
  HomeMenu();

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Container(
      color: SQColor.white,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: infos.map((info) => menuItem(info)).toList(),
      ),
    );
  }

  Widget menuItem(var info) {
    var ico = Column(
      children: <Widget>[
        Image.asset(
          info['icon'],
          width: 45,
        ),
        SizedBox(height: 5),
        Text(info['title'],
            style: TextStyle(fontSize: 12, color: SQColor.gray)),
      ],
    );
    return GestureDetector(
      child: ico,
      onTap: () {
        switch (int.parse(info['api'])) {
          case 1:
            //浏览器
            gourl(context!, new Bow(url: info['url'], title: info['title']));
            break;
          default:
            gourl(
                context!, new MallPage(api: info['url'], title: info['title']));
          //页面
        }
      },
    );
    //  ico;
  }
}
