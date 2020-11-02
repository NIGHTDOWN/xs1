import 'package:flutter/material.dart';
import 'package:ng169/page/home/home_banner.dart';
import 'package:ng169/page/home/home_menu.dart';
import 'package:ng169/page/home/novel_first_hybird_card.dart';
import 'package:ng169/page/home/novel_four_grid_view.dart';
import 'package:ng169/page/home/novel_list_more.dart';
import 'package:ng169/page/home/novel_normal_card.dart';
import 'package:ng169/page/home/novel_rom.dart';
import 'package:ng169/page/home/novel_second_hybird_card.dart';
import 'package:ng169/page/mall/searchpage.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

class Mall extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MallState();
}

class MallState extends State<Mall> {
  List banner, newbook, newcart, hotbook, mallcache, romdata;
  List<Widget> more = [SizedBox()];
  var index = 'mallload';
  var cachedata = 'mallload_data', page = 1;
  bool moredata = false, stop = false;
  ScrollController scrollController = ScrollController();
  var navAlpha = 0.0;
  var bannerapi = 'book/get_banner';
  var newBookapi = 'book/get_new_book';
  var hotbooksapi = 'book/new';
  var newCartoonsapi = 'cartoon/new_cartoon';
  var rom = 'book/get_randList';
  Future<List> gethttpdate(String api) async {
    var jbanner = await http(api, null, gethead());
    var data = getdata(context, jbanner);
    if (isnull(data)) {
      return data;
    }
    return null;
  }

  mock() {
    banner = [
      {
        'scan_seat': '1',
        'goal_type': '2',
        'goal_window': '0',
        'book_id': '1140',
        'banner_pic': "mock:b1.png",
        'banner_url': '',
        'cartoon_id': '0'
      },
      {
        'scan_seat': '1',
        'goal_type': '2',
        'goal_window': '0',
        'book_id': '1014',
        'banner_pic': "mock:b3.png",
        'banner_url': '',
        'cartoon_id': '0'
      },
      {
        'scan_seat': '1',
        'goal_type': '2',
        'goal_window': '2',
        'book_id': '1037',
        'banner_pic': "mock:b3.png",
        'banner_url': '',
        'cartoon_id': '0'
      }
    ];
    newbook = [
      {
        "book_id": "1135",
        "other_name":
            "\u0e23\u0e31\u0e01\u0e2d\u0e31\u0e19\u0e27\u0e38\u0e48\u0e19\u0e27\u0e32\u0e22",
        "desc":
            "\u0e01\u0e32\u0e23\u0e41\u0e15\u0e48\u0e07\u0e07\u0e32\u0e19\u0e17\u0e35\u0e48\u0e40\u0e23\u0e35\u0e22\u0e1a\u0e07\u0e48\u0e32\u0e22\u0e44\u0e21\u0e48\u0e0b\u0e31\u0e1a\u0e0b\u0e49\u0e2d\u0e19 \u0e17\u0e33\u0e43\u0e2b\u0e49\u0e40\u0e18\u0e2d\u0e2d\u0e14\u0e17\u0e19\u0e44\u0e21\u0e48\u0e44\u0e14\u0e49\u0e17\u0e35\u0e48\u0e08\u0e30\u0e19\u0e2d\u0e01\u0e43\u0e08 \u0e2a\u0e32\u0e21\u0e35\u0e40\u0e18\u0e2d\u0e01\u0e47\u0e21\u0e35\u0e0a\u0e39\u0e49  \u0e41\u0e16\u0e21\u0e41\u0e21\u0e48\u0e2a\u0e32\u0e21\u0e35\u0e22\u0e31\u0e07\u0e0a\u0e2d\u0e1a\u0e2b\u0e32\u0e40\u0e23\u0e37\u0e48\u0e2d\u0e07\u0e40\u0e18\u0e2d \u0e0a\u0e32\u0e22\u0e2b\u0e19\u0e38\u0e48\u0e21\u0e17\u0e31\u0e49\u0e07\u0e2d\u0e48\u0e2d\u0e19\u0e42\u0e22\u0e19\u0e41\u0e25\u0e30\u0e2d\u0e1a\u0e2d\u0e38\u0e48\u0e19 \u0e17\u0e33\u0e43\u0e2b\u0e49\u0e40\u0e18\u0e2d\u0e1b\u0e0f\u0e34\u0e40\u0e2a\u0e18\u0e44\u0e21\u0e48\u0e44\u0e14\u0e49\u0e08\u0e23\u0e34\u0e07\u0e46",
        "bpic": "mock:588c685200d5496d55055a6711730cff.png",
        "reward_icon": "89",
        "writer_name": "lookstory",
        "virtual_coin": "0",
        "is_virtual": "0",
        "isfree": "1",
        "update_status": "2"
      },
      {
        "book_id": "1062",
        "other_name":
            "\u0e40\u0e01\u0e34\u0e14\u0e43\u0e2b\u0e21\u0e48\u0e17\u0e31\u0e49\u0e07\u0e17\u0e35 \u0e09\u0e31\u0e19\u0e08\u0e30\u0e40\u0e1b\u0e47\u0e19\u0e19\u0e32\u0e07\u0e23\u0e49\u0e32\u0e22",
        "desc":
            "\u0e40\u0e01\u0e34\u0e14\u0e43\u0e2b\u0e21\u0e48\u0e01\u0e25\u0e31\u0e1a\u0e44\u0e1b\u0e21.5 \u0e0a\u0e48\u0e27\u0e07\u0e0a\u0e35\u0e27\u0e34\u0e15\u0e17\u0e35\u0e48\u0e14\u0e35\u0e17\u0e35\u0e48\u0e2a\u0e38\u0e14\u0e02\u0e2d\u0e07\u0e40\u0e01\u0e27\u0e25\u0e34\u0e19 \r\n\u0e04\u0e23\u0e32\u0e27\u0e19\u0e35\u0e49\u0e40\u0e18\u0e2d\u0e15\u0e49\u0e2d\u0e07\u0e43\u0e0a\u0e49\u0e0a\u0e35\u0e27\u0e34\u0e15\u0e14\u0e35\u0e46 \u0e41\u0e25\u0e30\u0e44\u0e1b\u0e40\u0e01\u0e47\u0e1a\u0e04\u0e27\u0e32\u0e21\u0e1d\u0e31\u0e19\u0e17\u0e35\u0e48\u0e40\u0e15\u0e49\u0e19\u0e23\u0e33\u0e02\u0e2d\u0e07\u0e40\u0e18\u0e2d\u0e01\u0e25\u0e31\u0e1a\u0e21\u0e32\r\n\u0e08\u0e30\u0e44\u0e21\u0e48\u0e44\u0e1b\u0e0a\u0e48\u0e27\u0e22\u0e19\u0e49\u0e2d\u0e07\u0e2a\u0e32\u0e27\u0e17\u0e35\u0e48\u0e40\u0e2b\u0e47\u0e19\u0e41\u0e01\u0e48\u0e15\u0e31\u0e27\u0e41\u0e25\u0e30\u0e17\u0e33\u0e43\u0e2b\u0e49\u0e15\u0e19\u0e40\u0e2d\u0e07\u0e40\u0e2a\u0e35\u0e22\u0e42\u0e09\u0e21\u0e2d\u0e35\u0e01 \u0e15\u0e49\u0e2d\u0e07\u0e23\u0e31\u0e01\u0e29\u0e32\u0e04\u0e27\u0e32\u0e21\u0e2a\u0e27\u0e22\u0e02\u0e2d\u0e07\u0e15\u0e19\u0e40\u0e2d\u0e07\u0e43\u0e2b\u0e49\u0e14\u0e35 \r\n\u0e08\u0e30\u0e44\u0e21\u0e48\u0e44\u0e1b\u0e21\u0e35\u0e40\u0e23\u0e37\u0e48\u0e2d\u0e07\u0e01\u0e31\u0e1a\u0e19\u0e23\u0e27\u0e34\u0e17\u0e22\u0e4c \u0e0a\u0e32\u0e22\u0e2b\u0e19\u0e38\u0e21\u0e17\u0e35\u0e48\u0e23\u0e49\u0e32\u0e22\u0e40\u0e2b\u0e21\u0e37\u0e2d\u0e19\u0e1b\u0e35\u0e28\u0e32\u0e08\u0e41\u0e25\u0e30\u0e22\u0e01\u0e21\u0e35\u0e14\u0e44\u0e1b\u0e06\u0e48\u0e32\u0e04\u0e19\u0e43\u0e19\u0e15\u0e2d\u0e19\u0e2b\u0e25\u0e31\u0e07\r\n\u0e41\u0e15\u0e48\u0e43\u0e19\u0e24\u0e14\u0e39\u0e23\u0e49\u0e2d\u0e19\u0e21.5\u0e1b\u0e35\u0e19\u0e35\u0e49  \u0e40\u0e01\u0e27\u0e25\u0e34\u0e19\u0e01\u0e25\u0e31\u0e1a\u0e44\u0e1b\u0e40\u0e2d\u0e32\u0e2b\u0e19\u0e31\u0e07\u0e2a\u0e37\u0e2d\u0e2d\u0e31\u0e07\u0e01\u0e24\u0e29\u0e02\u0e2d\u0e07\u0e15\u0e19\u0e40\u0e2d\u0e07\r\n\u0e43\u0e19\u0e21\u0e38\u0e21\u0e40\u0e25\u0e35\u0e49\u0e22\u0e27\u0e1a\u0e31\u0e19\u0e44\u0e14 \u0e1e\u0e27\u0e01\u0e19\u0e31\u0e01\u0e40\u0e23\u0e35\u0e22\u0e19\u0e40\u0e01\u0e40\u0e23\u0e01\u0e33\u0e25\u0e31\u0e07\u0e2a\u0e39\u0e1a\u0e1a\u0e38\u0e2b\u0e23\u0e35\u0e48\u0e2d\u0e22\u0e39\u0e48 \u0e40\u0e18\u0e2d\u0e0a\u0e30\u0e07\u0e31\u0e01\u0e1d\u0e35\u0e40\u0e17\u0e49\u0e32 \u0e1a\u0e34\u0e07\u0e40\u0e2d\u0e34\u0e0d\u0e44\u0e14\u0e49\u0e22\u0e34\u0e19\u0e19\u0e23\u0e27\u0e34\u0e17\u0e22\u0e4c\u0e22\u0e34\u0e49\u0e21\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e1a\u0e49\u0e32\u0e23\u0e30\u0e2b\u0e48\u0e33\u0e41\u0e25\u0e30\u0e1e\u0e39\u0e14\u0e27\u0e48\u0e32\u201c\u0e01\u0e39\u0e0a\u0e2d\u0e1a\u0e41\u0e1a\u0e1a\u0e44\u0e2b\u0e19\u0e2b\u0e23\u0e2d \u0e01\u0e47\u0e41\u0e1a\u0e1a\u0e17\u0e35\u0e48\u0e40\u0e2b\u0e21\u0e37\u0e2d\u0e19\u0e40\u0e01\u0e27\u0e25\u0e34\u0e19\u0e44\u0e07\uff01\u201d",
        "bpic": "mock:8ab1b5d6ad5ee6be57a3348d5b789f77.jpg",
        "reward_icon": "5239",
        "writer_name": "lookstory",
        "virtual_coin": "190",
        "is_virtual": "0",
        "isfree": "1",
        "update_status": "2"
      },
      {
        "book_id": "1038",
        "other_name":
            "\u0e27\u0e34\u0e27\u0e32\u0e2b\u0e4c\u0e23\u0e49\u0e32\u0e22 \u0e41\u0e15\u0e48\u0e07\u0e01\u0e31\u0e1a\u0e1c\u0e35",
        "desc":
            "\u0e09\u0e31\u0e19\u0e1d\u0e31\u0e19\u0e23\u0e49\u0e32\u0e22\u0e44\u0e1b\u0e2b\u0e19\u0e36\u0e48\u0e07\u0e1d\u0e31\u0e19 \u0e2b\u0e25\u0e31\u0e07\u0e08\u0e32\u0e01\u0e15\u0e37\u0e48\u0e19\u0e21\u0e32 \u0e09\u0e31\u0e19\u0e1b\u0e23\u0e32\u0e01\u0e0f\u0e27\u0e48\u0e32\u0e09\u0e31\u0e19\u0e15\u0e31\u0e49\u0e07\u0e04\u0e23\u0e23\u0e20\u0e4c\u0e41\u0e25\u0e49\u0e27! \u0e19\u0e35\u0e48\u0e25\u0e39\u0e01\u0e17\u0e35\u0e48\u0e2d\u0e22\u0e39\u0e48\u0e43\u0e19\u0e17\u0e49\u0e2d\u0e07\u0e40\u0e1b\u0e47\u0e19\u0e02\u0e2d\u0e07\u0e43\u0e04\u0e23? \u0e09\u0e31\u0e19\u0e17\u0e49\u0e2d\u0e07\u0e44\u0e14\u0e49\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e44\u0e23 ? \u0e09\u0e31\u0e19\u0e40\u0e04\u0e22\u0e17\u0e33\u0e44\u0e1b\u0e2b\u0e25\u0e32\u0e22\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e44\u0e1b\u0e2a\u0e37\u0e1a\u0e2b\u0e32\u0e04\u0e27\u0e32\u0e21\u0e08\u0e23\u0e34\u0e07\u0e02\u0e2d\u0e07\u0e40\u0e23\u0e37\u0e48\u0e2d\u0e07\u0e19\u0e35\u0e49 \u0e41\u0e15\u0e48\u0e43\u0e19\u0e17\u0e35\u0e48\u0e2a\u0e38\u0e14\u0e09\u0e31\u0e19\u0e1e\u0e1a\u0e27\u0e48\u0e32\u0e1e\u0e48\u0e2d\u0e02\u0e2d\u0e07\u0e25\u0e39\u0e01\u0e17\u0e35\u0e48\u0e2d\u0e22\u0e39\u0e48\u0e43\u0e19\u0e17\u0e49\u0e2d\u0e07\u0e40\u0e1b\u0e47\u0e19\u0e1c\u0e35\u0e15\u0e19\u0e2b\u0e19\u0e36\u0e48\u0e07.......",
        "bpic": "mock:8f4b554cb41b97a7b0a293d60a663f5c.jpg",
        "reward_icon": "88481",
        "writer_name": "lookstory",
        "virtual_coin": "4930",
        "is_virtual": "0",
        "isfree": "0",
        "update_status": "2"
      },
      {
        "book_id": "1036",
        "other_name":
            "\u0e1d\u0e37\u0e19\u0e0a\u0e30\u0e15\u0e32:\u0e0a\u0e32\u0e22\u0e32\u0e40\u0e01\u0e34\u0e14\u0e43\u0e2b\u0e21\u0e48",
        "desc":
            "\u0e0a\u0e32\u0e15\u0e34\u0e01\u0e48\u0e2d\u0e19\u0e08\u0e32\u0e07\u0e22\u0e27\u0e35\u0e48\u0e42\u0e2b\u0e23\u0e48\u0e27\u0e23\u0e31\u0e01\u0e1c\u0e34\u0e14\u0e1c\u0e39\u0e49\u0e0a\u0e32\u0e22\u0e17\u0e35\u0e48\u0e2b\u0e25\u0e32\u0e22\u0e43\u0e08 \u0e41\u0e16\u0e21\u0e22\u0e31\u0e07\u0e16\u0e39\u0e01\u0e40\u0e02\u0e32\u0e06\u0e48\u0e32\u0e04\u0e19\u0e43\u0e19\u0e04\u0e23\u0e2d\u0e1a\u0e04\u0e23\u0e31\u0e27\u0e44\u0e1b\u0e2b\u0e21\u0e14 \u0e43\u0e19\u0e15\u0e2d\u0e19\u0e17\u0e35\u0e48\u0e44\u0e14\u0e49\u0e21\u0e35\u0e0a\u0e35\u0e27\u0e34\u0e15\u0e43\u0e2b\u0e21\u0e48 \u0e19\u0e32\u0e07\u0e2a\u0e31\u0e0d\u0e0d\u0e32\u0e27\u0e48\u0e32\u0e08\u0e30\u0e41\u0e01\u0e49\u0e41\u0e04\u0e49\u0e19\u0e40\u0e02\u0e32\u0e43\u0e2b\u0e49\u0e44\u0e14\u0e49  \u0e43\u0e19\u0e27\u0e31\u0e19\u0e41\u0e15\u0e48\u0e07\u0e07\u0e32\u0e19 \u0e19\u0e32\u0e07\u0e27\u0e32\u0e07\u0e41\u0e1c\u0e19\u0e43\u0e2b\u0e49\u0e02\u0e36\u0e49\u0e19\u0e1c\u0e34\u0e14\u0e40\u0e01\u0e35\u0e49\u0e22\u0e27\u0e41\u0e15\u0e48\u0e07\u0e1c\u0e34\u0e14\u0e04\u0e19 \u0e41\u0e15\u0e48\u0e01\u0e25\u0e31\u0e1a\u0e44\u0e21\u0e48\u0e04\u0e32\u0e14\u0e04\u0e34\u0e14\u0e27\u0e48\u0e32\u0e40\u0e1e\u0e34\u0e48\u0e07\u0e2b\u0e19\u0e35\u0e40\u0e2a\u0e37\u0e2d\u0e1b\u0e30\u0e08\u0e23\u0e30\u0e40\u0e02\u0e49 \u201c\u0e40\u0e02\u0e49\u0e32\u0e15\u0e33\u0e2b\u0e19\u0e31\u0e01\u0e02\u0e2d\u0e07\u0e02\u0e49\u0e32 \u0e40\u0e08\u0e49\u0e32\u0e01\u0e47\u0e40\u0e1b\u0e47\u0e19\u0e04\u0e19\u0e02\u0e2d\u0e07\u0e02\u0e49\u0e32\u201d \u0e2b\u0e31\u0e19\u0e22\u0e35\u0e48\u0e09\u0e35\u0e01\u0e25\u0e48\u0e32\u0e27\u0e2d\u0e22\u0e48\u0e32\u0e07\u0e0b\u0e36\u0e48\u0e07\u0e01\u0e14\u0e02\u0e35\u0e48 \u0e22\u0e31\u0e07\u0e41\u0e08\u0e49\u0e07\u0e1b\u0e23\u0e30\u0e01\u0e32\u0e2a\u0e43\u0e2b\u0e49\u0e04\u0e19\u0e17\u0e31\u0e48\u0e27\u0e44\u0e1b\u0e44\u0e14\u0e49\u0e23\u0e31\u0e1a\u0e23\u0e39\u0e49\u0e27\u0e48\u0e32\u0e19\u0e32\u0e07\u0e40\u0e1b\u0e47\u0e19\u0e04\u0e19\u0e02\u0e2d\u0e07\u0e40\u0e02\u0e32 \u201c\u0e2b\u0e27\u0e32\u0e07\u0e40\u0e1f\u0e22 \u0e02\u0e49\u0e32\u0e22\u0e31\u0e07\u0e44\u0e21\u0e48\u0e40\u0e04\u0e22\u0e21\u0e35\u0e25\u0e39\u0e01 \u0e40\u0e23\u0e37\u0e48\u0e2d\u0e07\u0e01\u0e33\u0e40\u0e19\u0e34\u0e14\u0e25\u0e39\u0e01\u0e40\u0e08\u0e49\u0e32\u0e15\u0e49\u0e2d\u0e07\u0e23\u0e31\u0e1a\u0e1c\u0e34\u0e14\u0e0a\u0e2d\u0e1a\u0e14\u0e49\u0e27\u0e22\u0e41\u0e25\u0e49\u0e27\u0e19\u0e30\u201d\u0e15\u0e31\u0e49\u0e07\u0e41\u0e15\u0e48\u0e19\u0e31\u0e49\u0e19\u0e21\u0e32 \u0e19\u0e32\u0e07\u0e01\u0e47\u0e1b\u0e27\u0e14\u0e2b\u0e25\u0e31\u0e07\u0e40\u0e08\u0e47\u0e1a\u0e15\u0e31\u0e27\u0e08\u0e19\u0e25\u0e07\u0e40\u0e15\u0e35\u0e22\u0e07\u0e44\u0e21\u0e48\u0e44\u0e14\u0e49 \u0e01\u0e47\u0e40\u0e1e\u0e23\u0e32\u0e30\u0e0a\u0e32\u0e22\u0e2a\u0e31\u0e15\u0e27\u0e4c\u0e04\u0e19\u0e19\u0e35\u0e49\u0e25\u0e48\u0e30 \u0e19\u0e32\u0e07\u0e22\u0e01\u0e15\u0e31\u0e27\u0e40\u0e2d\u0e07\u0e43\u0e2b\u0e49\u0e40\u0e02\u0e32 \u0e41\u0e25\u0e49\u0e27\u0e40\u0e02\u0e32\u0e08\u0e30\u0e0a\u0e48\u0e27\u0e22\u0e19\u0e32\u0e07\u0e41\u0e01\u0e49\u0e41\u0e04\u0e49\u0e19 \u0e19\u0e35\u0e48\u0e40\u0e1b\u0e47\u0e19\u0e01\u0e32\u0e23\u0e04\u0e49\u0e32\u0e02\u0e32\u0e22\u0e17\u0e35\u0e48\u0e15\u0e48\u0e32\u0e07\u0e04\u0e19\u0e15\u0e48\u0e32\u0e07\u0e44\u0e14\u0e49\u0e2a\u0e34\u0e48\u0e07\u0e17\u0e35\u0e48\u0e15\u0e49\u0e2d\u0e07\u0e01\u0e32\u0e23 \u0e41\u0e15\u0e48\u0e2a\u0e38\u0e14\u0e17\u0e49\u0e32\u0e22\u0e17\u0e33\u0e44\u0e21\u0e09\u0e32\u0e01\u0e08\u0e2d\u0e21\u0e1b\u0e25\u0e2d\u0e21\u0e17\u0e35\u0e48\u0e40\u0e25\u0e48\u0e19\u0e25\u0e30\u0e04\u0e23\u0e09\u0e32\u0e01\u0e19\u0e35\u0e49\u0e01\u0e25\u0e31\u0e1a\u0e01\u0e25\u0e32\u0e22\u0e40\u0e1b\u0e47\u0e19\u0e40\u0e23\u0e37\u0e48\u0e2d\u0e07\u0e08\u0e23\u0e34\u0e07\u0e25\u0e48\u0e30? ",
        "bpic": "mock:d3a4aac5cbc65d1c94ece4446d0d7aa8.jpg",
        "reward_icon": "281071",
        "writer_name": "lookstory",
        "virtual_coin": "5835",
        "is_virtual": "0",
        "isfree": "1",
        "update_status": "2"
      },
      {
        "book_id": "1027",
        "other_name":
            "Marry you \u0e17\u0e48\u0e32\u0e19\u0e1b\u0e23\u0e30\u0e18\u0e32\u0e19!\u0e04\u0e38\u0e13\u0e40\u0e1b\u0e47\u0e19\u0e02\u0e2d\u0e07\u0e09\u0e31\u0e19",
        "desc":
            "\u0e0a\u0e27\u0e19\u0e35\u0e44\u0e1b\u0e40\u0e17\u0e35\u0e48\u0e22\u0e27\u0e40\u0e21\u0e37\u0e2d\u0e07\u0e19\u0e2d\u0e01\u0e41\u0e15\u0e48\u0e2b\u0e25\u0e07\u0e17\u0e32\u0e07\u0e44\u0e1b \u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e44\u0e21\u0e48\u0e2d\u0e14\u0e2d\u0e32\u0e2b\u0e32\u0e23\u0e15\u0e32\u0e22 \u0e40\u0e18\u0e2d\u0e44\u0e1b\u0e40\u0e04\u0e32\u0e30\u0e1b\u0e23\u0e30\u0e15\u0e39\u0e02\u0e2d\u0e07\u0e27\u0e34\u0e25\u0e25\u0e48\u0e32\u0e2b\u0e25\u0e31\u0e07\u0e2b\u0e19\u0e36\u0e48\u0e07 \u0e41\u0e15\u0e48\u0e01\u0e25\u0e31\u0e1a\u0e42\u0e14\u0e19\u0e04\u0e19\u0e19\u0e31\u0e49\u0e19\u0e16\u0e37\u0e2d\u0e40\u0e1b\u0e47\u0e19\u0e2b\u0e0d\u0e34\u0e07\u0e02\u0e32\u0e22\u0e1a\u0e23\u0e34\u0e01\u0e32\u0e23 \u0e2b\u0e25\u0e31\u0e07\u0e01\u0e25\u0e31\u0e1a\u0e21\u0e32\u0e08\u0e32\u0e01\u0e15\u0e48\u0e32\u0e07\u0e1b\u0e23\u0e30\u0e40\u0e17\u0e28\u0e22\u0e31\u0e07\u0e1e\u0e1a\u0e27\u0e48\u0e32\u0e04\u0e39\u0e48\u0e2b\u0e21\u0e31\u0e49\u0e19\u0e15\u0e19\u0e40\u0e2d\u0e07\u0e2d\u0e2d\u0e01\u0e19\u0e2d\u0e01\u0e40\u0e18\u0e2d \u0e20\u0e32\u0e22\u0e43\u0e15\u0e49\u0e04\u0e27\u0e32\u0e21\u0e42\u0e01\u0e23\u0e18\u0e19\u0e35\u0e49\u0e40\u0e18\u0e2d\u0e40\u0e25\u0e22\u0e2b\u0e19\u0e35\u0e44\u0e1b\u0e15\u0e48\u0e32\u0e07\u0e1b\u0e23\u0e30\u0e40\u0e17\u0e29\r\n\u0e2b\u0e25\u0e31\u0e075\u0e1b\u0e35\u0e40\u0e18\u0e2d\u0e1e\u0e32\u0e18\u0e31\u0e19\u0e27\u0e32\u0e40\u0e14\u0e47\u0e01\u0e2a\u0e21\u0e32\u0e23\u0e4c\u0e17\u0e02\u0e2d\u0e07\u0e40\u0e18\u0e2d\u0e01\u0e25\u0e31\u0e1a\u0e21\u0e32 \u0e18\u0e31\u0e19\u0e27\u0e32\u0e44\u0e1b\u0e23\u0e48\u0e27\u0e21\u0e01\u0e32\u0e23\u0e41\u0e02\u0e48\u0e07\u0e02\u0e31\u0e49\u0e19\u0e40\u0e1b\u0e35\u0e22\u0e42\u0e19\u0e41\u0e25\u0e30\u0e15\u0e31\u0e49\u0e07\u0e43\u0e08\u0e02\u0e36\u0e49\u0e19\u0e23\u0e32\u0e22\u0e01\u0e32\u0e23\u0e17\u0e35\u0e27\u0e35\u0e44\u0e1b\u0e1b\u0e23\u0e30\u0e01\u0e32\u0e28\u0e2b\u0e32\u0e1e\u0e48\u0e2d\u0e02\u0e2d\u0e07\u0e15\u0e19\u0e40\u0e2d\u0e07\r\n\u0e2b\u0e25\u0e31\u0e07\u0e01\u0e35\u0e48\u0e27\u0e31\u0e19\u0e1c\u0e48\u0e32\u0e19\u0e44\u0e1b \u0e21\u0e35\u0e1c\u0e39\u0e49\u0e0a\u0e32\u0e22\u0e25\u0e36\u0e01\u0e25\u0e31\u0e1a\u0e21\u0e32\u0e2b\u0e32 \u0e41\u0e25\u0e30\u0e1a\u0e2d\u0e01\u0e27\u0e48\u0e32\u0e40\u0e02\u0e32\u0e40\u0e1b\u0e47\u0e19\u0e1e\u0e48\u0e2d\u0e02\u0e2d\u0e07\u0e18\u0e31\u0e19\u0e27\u0e32\r\n \u0e0a\u0e27\u0e19\u0e35\u0e21\u0e2d\u0e07\u0e14\u0e39\u0e1c\u0e39\u0e49\u0e0a\u0e32\u0e22\u0e17\u0e35\u0e48\u0e2a\u0e39\u0e07\u0e43\u0e2b\u0e0d\u0e48\u0e2b\u0e25\u0e48\u0e2d\u0e40\u0e2b\u0e25\u0e32\u0e41\u0e25\u0e30\u0e21\u0e35\u0e43\u0e1a\u0e2b\u0e19\u0e49\u0e32\u0e04\u0e25\u0e49\u0e32\u0e22\u0e46\u0e01\u0e31\u0e1a\u0e25\u0e39\u0e01\u0e02\u0e2d\u0e07\u0e40\u0e18\u0e2d\u0e22\u0e37\u0e19\u0e2d\u0e22\u0e39\u0e48\u0e02\u0e49\u0e32\u0e07\u0e2b\u0e19\u0e49\u0e32\u0e40\u0e18\u0e2d \u0e40\u0e18\u0e2d\u0e42\u0e01\u0e23\u0e18\u0e22\u0e34\u0e48\u0e07\u0e01\u0e27\u0e48\u0e32\u0e40\u0e14\u0e34\u0e21\r\n\u0e2b\u0e49\u0e32\u0e1b\u0e35\u0e01\u0e48\u0e2d\u0e19\u0e44\u0e2d\u0e49\u0e2a\u0e32\u0e23\u0e40\u0e25\u0e27\u0e17\u0e35\u0e48\u0e02\u0e48\u0e21\u0e02\u0e37\u0e19\u0e40\u0e18\u0e2d\u0e01\u0e47\u0e04\u0e37\u0e2d\u0e40\u0e02\u0e32 \u0e1b\u0e27\u0e31\u0e15\u0e23\u0e2b\u0e23\u0e37\u0e2d",
        "bpic": "mock:939d000a380b41996434aabbfedacc24.jpg",
        "reward_icon": "498197",
        "writer_name": "lookstory",
        "virtual_coin": "25495",
        "is_virtual": "0",
        "isfree": "1",
        "update_status": "2"
      },
      {
        "book_id": "1138",
        "other_name":
            "\u0e23\u0e31\u0e01\u0e25\u0e27\u0e07\u0e46\u0e41\u0e15\u0e48\u0e41\u0e15\u0e48\u0e07\u0e08\u0e23\u0e34\u0e07",
        "desc":
            "\u0e01\u0e32\u0e23\u0e27\u0e32\u0e07\u0e41\u0e1c\u0e19\u0e02\u0e2d\u0e07\u0e19\u0e49\u0e2d\u0e07\u0e2a\u0e32\u0e27\u0e17\u0e35\u0e48\u0e15\u0e31\u0e49\u0e07\u0e43\u0e08\u0e08\u0e31\u0e14\u0e01\u0e32\u0e23\u0e02\u0e36\u0e49\u0e19 \u0e17\u0e33\u0e43\u0e2b\u0e49\u0e0a\u0e37\u0e48\u0e2d\u0e40\u0e2a\u0e35\u0e22\u0e07\u0e02\u0e2d\u0e07\u0e40\u0e18\u0e2d\u0e40\u0e2a\u0e35\u0e22\u0e2b\u0e32\u0e22\u0e41\u0e25\u0e30\u0e01\u0e25\u0e32\u0e22\u0e40\u0e1b\u0e47\u0e19\u0e17\u0e35\u0e48\u0e23\u0e39\u0e49\u0e08\u0e31\u0e01\u0e02\u0e2d\u0e07\u0e04\u0e19\u0e17\u0e31\u0e49\u0e07\u0e40\u0e21\u0e37\u0e2d\u0e07\r\n\u0e04\u0e39\u0e48\u0e2b\u0e21\u0e31\u0e49\u0e19\u0e16\u0e39\u0e01\u0e41\u0e22\u0e48\u0e07 \u0e40\u0e18\u0e2d\u0e21\u0e35\u0e41\u0e15\u0e48\u0e08\u0e30\u0e15\u0e49\u0e2d\u0e07\u0e15\u0e32\u0e21\u0e2b\u0e32\u0e0a\u0e32\u0e22\u0e04\u0e19\u0e17\u0e35\u0e48\u0e1b\u0e25\u0e49\u0e19\u0e15\u0e31\u0e27\u0e40\u0e18\u0e2d\u0e44\u0e1b\u0e21\u0e32\u0e23\u0e31\u0e1a\u0e1c\u0e34\u0e14\u0e0a\u0e2d\u0e1a \u0e2a\u0e31\u0e0d\u0e0d\u0e32\u0e41\u0e15\u0e48\u0e07\u0e07\u0e32\u0e19\u0e09\u0e1a\u0e31\u0e1a\u0e2b\u0e19\u0e36\u0e48\u0e07 \u0e17\u0e33\u0e43\u0e2b\u0e49\u0e2a\u0e2d\u0e07\u0e04\u0e19\u0e21\u0e35\u0e04\u0e27\u0e32\u0e21\u0e2a\u0e31\u0e21\u0e1e\u0e31\u0e19\u0e18\u0e4c\u0e01\u0e31\u0e19 \u0e2d\u0e30\u0e44\u0e23\uff1f \u0e2a\u0e32\u0e21\u0e35\u0e02\u0e2d\u0e07\u0e40\u0e18\u0e2d\u0e40\u0e1b\u0e47\u0e19\u0e1b\u0e23\u0e30\u0e18\u0e32\u0e19\u0e43\u0e2b\u0e0d\u0e48\u0e2b\u0e23\u0e2d \u0e15\u0e01\u0e43\u0e08",
        "bpic": "mock:82f3c9bbca0a205073d60ecdee868a1b.jpg",
        "reward_icon": "27",
        "writer_name": "lookstory",
        "virtual_coin": "0",
        "is_virtual": "0",
        "isfree": "1",
        "update_status": "2"
      },
    ];
    romdata = [
      {
        "book_id": "1066",
        "other_name":
            "\u0e2b\u0e31\u0e27\u0e43\u0e08\u0e23\u0e49\u0e2d\u0e19\u0e46\u0e02\u0e2d\u0e07\u0e19\u0e32\u0e22\u0e40\u0e22\u0e47\u0e19\u0e0a\u0e32",
        "bpic": "mock:778295f43fc5c8684031b40a51f55202.jpg",
        "type": "1",
        "writer_name": "lookstory",
        "recommend_num": "498205"
      },
      {
        "book_id": "1070",
        "other_name":
            "\u0e2b\u0e21\u0e2d\u0e22\u0e32\u0e40\u0e1e\u0e32\u0e30\u0e23\u0e31\u0e01 \u0e17\u0e48\u0e32\u0e19\u0e2d\u0e4b\u0e2d\u0e07\u0e44\u0e23\u0e49\u0e43\u0e08",
        "bpic": "mock:2cc91fb8c45833fdbeb6cdaf195ed345.jpg",
        "type": "1",
        "writer_name": "lookstory",
        "recommend_num": "7533"
      },
      {
        "book_id": "1099",
        "other_name":
            "\u0e2d\u0e30\u0e23\u0e44\u0e19\u0e30 \u0e04\u0e19\u0e43\u0e19\u0e2b\u0e31\u0e27\u0e43\u0e08\u0e02\u0e2d\u0e07\u0e19\u0e32\u0e22\u0e04\u0e37\u0e2d\u0e09\u0e31\u0e19\uff01",
        "bpic": "mock:64056f795459a7d9f6fe753856fb5d4c.jpg",
        "type": "1",
        "writer_name": "lookstory",
        "recommend_num": "95"
      },
      {
        "book_id": "1007",
        "other_name":
            "\u0e22\u0e31\u0e48\u0e27\u0e2a\u0e27\u0e32\u0e17\u0e17\u0e48\u0e32\u0e19\u0e2d\u0e4b\u0e2d\u0e07\u0e42\u0e09\u0e21\u0e07\u0e32\u0e21",
        "bpic": "mock:050f12cbf964ea5c6ce0c653852fd701.jpg",
        "type": "1",
        "writer_name": "lookstory",
        "recommend_num": "1100143"
      },
    ];
  }

  Future<void> gethttpdata() async {
    var jbanner = await http('book/get_banner', null, gethead());
    var data = getdata(context, jbanner);
    if (isnull(data)) {
      banner = data;
    }
    var newBook = await http('book/get_new_book', null, gethead());
    var data1 = getdata(context, newBook);
    if (isnull(data1)) {
      newbook = data1;
    }
    var hotbooks = await http('book/new', null, gethead());
    var data2 = getdata(context, hotbooks);
    if (isnull(data2)) {
      hotbook = data2;
    }
    var newCartoon = await http('cartoon/new_cartoon', null, gethead());
    var data3 = getdata(context, newCartoon);
    if (isnull(data3)) {
      newcart = data3;
    }
    var romdatatmp = await http(rom, null, gethead());
    var data4 = getdata(context, romdatatmp);
    if (isnull(data4)) {
      romdata = data4;
    }
    mallcache = [banner, newbook, newcart, hotbook, romdata];

    setcache(cachedata, mallcache, '-1');
    more = [SizedBox()];
    stop = false;
    page = 1;
    refresh();
  }

  @override
  void deactivate() {
    super.deactivate();
    // d('切换页面');
  }

  // void didChangeMetrics() {
  //   d('切换窗口');
  // }

  @override
  void initState() {
    super.initState();
    index = index + getlang();
    mock();
    loadpage();

    scrollController.addListener(() {
      //var offset = scrollController.offset;
      var offset = scrollController.offset;

      if (offset < 0) {
        if (navAlpha != 0) {
          setState(() {
            navAlpha = 0;
          });
        }
      } else if (offset < 50) {
        setState(() {
          navAlpha = 1 - (50 - offset) / 50;
        });
      } else if (navAlpha != 1) {
        setState(() {
          navAlpha = 1;
        });
      }
      loadmore();
    });
  }

  loadingstatu() {
    setState(() {
      moredata = !moredata;
    });
  }

  loadmore() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      // d('底部' + offset.toString());
      if (stop) {
        return false;
      }
      loadingstatu();
      var data = await http('book/new', {'page': page++}, gethead());
      var tmpmore = getdata(context, data);

      if (isnull(tmpmore)) {
        more.add(bookCardWithInfo(5, '', tmpmore));
        // page++;
      } else {
        stop = true;
      }
      loadingstatu();
      refresh();
    }
  }
  //  gethttpdata(); //加载数据

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    //20分钟刷新缓存数据重新加载
    var mallcachebool = getcache(index);
    if (!isnull(mallcachebool)) {
      await gethttpdata();
      //半个小时的缓存
      setcache(index, 1, '1800');
    } else {
      mallcache = getcache(cachedata);
      if (isnull(mallcache)) {
        banner =
            isnull(mallcache[0]) ? mallcache[0] : await gethttpdate(bannerapi);

        newbook =
            isnull(mallcache[1]) ? mallcache[1] : await gethttpdate(newBookapi);
        newcart = isnull(mallcache[2])
            ? mallcache[2]
            : await gethttpdate(hotbooksapi);
        hotbook = isnull(mallcache[3])
            ? mallcache[3]
            : await gethttpdate(newCartoonsapi);
        romdata = isnull(mallcache[4]) ? mallcache[4] : await gethttpdate(rom);
        // newbook = mallcache[1];
        // newcart = mallcache[2];
        // hotbook = mallcache[3];
      } else {
        setcache(index, 0, '0');
      }
    }
  }

  refresh() {
    setState(() {});
  }

  Future<void> romget() async {
    romdata = await gethttpdate(rom);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    //如果有4个接口请求的内容中有1个空则重新加载请求
    // banner, newbook, newcart, hotbook
    if (!isnull(banner) ||
        !isnull(newbook) ||
        !isnull(newcart) ||
        !isnull(hotbook)) {
      loadpage();
    }

    var body = Container(
      //margin: EdgeInsets.only(top: 5),
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            //banner

            isnull(banner) ? HomeBanner(banner) : SizedBox(),
            //菜单
            HomeMenu(),
            isnull(newbook)
                ? bookCardWithInfo(6, lang('猜你喜欢'), romdata)
                : SizedBox(),
            //推荐小说
            isnull(newbook)
                ? bookCardWithInfo(2, lang('推荐小说'), newbook)
                : SizedBox(),

            //推荐漫画
            isnull(newcart)
                ? bookCardWithInfo(3, lang('推荐漫画'), newcart)
                : SizedBox(),
            //热门小说
            isnull(hotbook)
                ? bookCardWithInfo(4, lang('热门小说'), hotbook)
                : SizedBox(),
            Column(
              children: more,
            ),

            moredata ? _buildProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: SQColor.white,
      body: Stack(
        children: <Widget>[body, buildNavigationBar()],
      ),
    );
  }

  Widget buildNavigationBar() {
    var w = getScreenWidth(context);
    var padding = EdgeInsets.fromLTRB(w * .1, Screen.topSafeHeight, w * .1, 10);
    return Stack(
      children: <Widget>[
        Positioned(
          // right: 0,
          child: Container(
            // margin: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            padding: padding,
            child: buildserechbtn(),
          ),
        ),
        Opacity(
          opacity: navAlpha,
          child: Container(
            decoration: new BoxDecoration(
              color: SQColor.white,
              boxShadow: [
                BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
              ],
            ),
            padding: padding,
            child: buildserechbtn(),
          ),
        )
      ],
    );
  }

  //搜索框栏目
  Widget buildserechbtn() {
    var w = getScreenWidth(context);
    var c = Container(
      alignment: Alignment.center,
      width: w * 0.85,
      height: Screen.navigationBarHeight * .4,
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        //中间按钮背景框
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: navAlpha <= 0 ? Color(0x202B2B2B) : Colors.grey[200],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.search,
                  color: navAlpha <= 0 ? Colors.white : SQColor.primary,
                  size: 20,
                )),
            Text(
              lang("书名/作者/关键词"),
              style: TextStyle(
                  color: navAlpha <= 0 ? Colors.white : Colors.black38,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
    return GestureDetector(
      child: c,
      onTap: () {
        gourl(context, new SearchPage());
      },
    );
  }

  Widget bookCardWithInfo(int style, String title, List json) {
    Widget card;
    switch (style) {
      case 1:
        card = NovelFourGridView(title, json);
        break;
      case 2:
        card = NovelSecondHybirdCard(title, json);
        break;
      case 3:
        card = NovelFirstHybirdCard(title, json);
        break;
      case 4:
        card = NovelNormalCard(title, json);
        break;
      case 5:
        card = NovelmoreCard(json);
        break;
      case 6:
        card = NovelRomView(title, json, () {
          romget();
        });
        break;
    }
    return card;
  }

  Widget _buildProgressIndicator() {
    var circular = new CircularProgressIndicator(
      backgroundColor: Colors.white,
      strokeWidth: 5.0,
      valueColor: AlwaysStoppedAnimation(Colors.green[200]),
    );
    var box = SizedBox(
      width: 17,
      height: 17,
      child: circular,
    );
    var kongbai = Expanded(child: SizedBox());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          kongbai,
          box,
          SizedBox(width: 9),
          Text(
            lang('加载中..'),
          ),
          kongbai
        ],
      ),
    );
  }
}
