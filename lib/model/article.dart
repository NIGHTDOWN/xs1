import 'dart:io';

import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

class Article {
  int id;
  int novelId;
  int price;
  String booktype;
  int index;
  int nextArticleId;
  int preArticleId;
  String title;
  String content;
  List images;
  List imagestmp = [];
  String contenttmp;
  String section_id;
  String book_id;
  String update_time;
  String isfree;
  double coin = 0.0;
  int cutlength = 300; //????
  bool pay = false; //????
  bool cartoonisinit = true; //????
  List<Map<String, int>> pageOffsets;
  List<String> page;

  var context;
  Future<bool> ispay() async {
    if (isfree != '1') {
      pay = true;
      return true;
    }
    if (!isnull(getuid())) {
      pay = false;
      return false;
    }

    var w = {
      'secid': section_id,
      'bookid': novelId,
      'type': booktype,
      'uid': getuid(),
    };

    var data = await T('pay').getone(w);

    if (!isnull(data)) {
      //远程查记录，更新数据库
      //数据库无记录不操作
      // pay = false;
      return false;
    }

    if (isnull(data['pay'])) {
      pay = true;
      return true;
    }
    {
      pay = false;
      return false;
    }
  }

  getarticlecache() {
    // String cacheindex = 'book_' +
    //     novelId.toString() +
    //     booktype.toString() +
    //     section_id.toString();
    // var cache = getcache(cacheindex);
    // return cache;
    return getCache(
        novelId.toString(), booktype.toString(), section_id.toString());
  }

  uparticlecache(cache) {
    // String cacheindex = 'book_' +
    //     novelId.toString() +
    //     booktype.toString() +
    //     section_id.toString();
    // setcache(cacheindex, cache, '0');
    setCache(novelId.toString(), booktype.toString(), section_id.toString(),
        cache, '0');
  }

  static getCache(String novelId, String noveltype, String sectionid) {
    String cacheindex = 'book_' + novelId + noveltype + sectionid;
    var cache = getcache(cacheindex);
    return cache;
  }

  static setCache(
      String novelId, String noveltype, String sectionid,  cache,
      [String time = '-1']) {
    String cacheindex = 'book_' + novelId + noveltype + sectionid;
    setcache(cacheindex, cache, time);
    return cache;
  }

  cut() {
    if (pay) {
      return;
    }
    if (booktype == '3') {
      return;
    }
    //????
    if (isnull(content)) {
      if (content.toString().length >= cutlength) {
        contenttmp = content.toString().substring(0, cutlength);
      }
    }
  }

  cutimg() {
    if (pay) {
      return;
    }
    //????
    if (isnull(images)) {
      // if (content.toString().length >= cutlength) {
      //   contenttmp = content.toString().substring(0, cutlength);
      // }
      if (images.length > 2) {
        //三张以上的图片，显示三张
        imagestmp = [images[0], images[1]];
      } else {
        //否则显示一张图
        imagestmp = [images[0]];
      }
    }
  }

  autolock() async {
    if (pay) {
      return;
    }
    //????
    if (isnull(getcache(autounlock))) {
      bool b = await unlock(context);
      if (!b) {
        //????????????
        setcache(autounlock, '0', '-1');
      }
    }
  }

  uppaystatus() async {
    pay = true;
    Map<String, dynamic> w = {
      'secid': section_id,
      'bookid': novelId,
      'type': booktype,
      'uid': getuid(),
    };
    var data = await T('pay').getone(w);

    if (!isnull(data)) {
      //??
      w.addAll({'pay': 1});
      T('pay').add(w);
    } else {
      //??
      T('pay').update({'pay': 1}, w);
    }
  }

  Future<bool> unlock(context) async {
    //??????
    //?????????
    //?????

    if (await ispay()) {
      return true;
    }
    var nowcoin = User.getcoin();
    var lastcoin = nowcoin - coin;
    if (lastcoin < 0) {
      return false;
    }
    User.upcoin(lastcoin);
    Map<String, dynamic> postdata;
    if (booktype == '1') {
      //??
      postdata = {
        'book_id': novelId,
        'section_id': section_id,
        'expend_red': coin
      };
    } else {
      //??
      postdata = {
        'cartoon_id': novelId,
        'cart_section_id': section_id,
        'expend_red': coin
      };
    }
    postdata.addAll({'isauto': isnull(getcache(autounlock)) ? 1 : 0});
    var rettmp = await http('user/deblocking', postdata, gethead());
    var ret = getdata(context, rettmp);
    if (isnull(ret)) {
      //??????
      //??????
      if (isnull(ret['remainder'])) {
        User.upcoin(ret['remainder']);
        var bookcache = getarticlecache();
        if (isnull(bookcache)) {
          bookcache['ispay'] = 1;
          uparticlecache(bookcache);
        }

        await uppaystatus();
        //????????????
        // Novel novel = Novel.fromDb({
        //   'bookid': novelId,
        //   'type': booktype,
        // });
        Novel novel = await Novel.fromID(novelId, int.parse(booktype));
        var cache = await Chapter.getcatecache(context, novel);
        //????
        var indexs = await T('sec').where({
          'book_id': novelId,
          'section_id': section_id,
          'booktype': booktype
        }).getone();
        if (isnull(indexs)) {
          cache[indexs['index']]['ispay'] = 1;
          Chapter.setbookcache(context, novel, cache);
        }

        //Chapter.upcachefromdb(context, novelId);
        // d(cache);

        return true;
      } else {
        //????
        uparticlecache('');
        //??????
        Novel novel = Novel.fromDb({
          'bookid': novelId,
          'type': booktype,
        });
        Chapter.gethttp(context, novel);
      }
    }

    return false;
  }

  Article.fromJson(Map data, Novel novel) {
    if (!isnull(data)) {
      return;
    }
    section_id = data['section_id'].toString();
    booktype = novel.type;
    book_id = data['book_id'].toString();
    id = int.parse(section_id);
    novelId = int.parse(book_id);
    title = data['title'].toString();
    content = data['sec_content'].toString();
    isfree = data['isfree'].toString();
    pay = isnull(data['ispay']) ? true : false;
    // d(data);
    // d(isnull(data,'coin'));
    coin = isnull(data, 'coin') ? double.parse(data['coin'].toString()) : 0.00;
    //content = content.replaceAll(new RegExp(r'[\s]{1,}'), '\n\t');
    //content = content.replaceAll(new RegExp(r'\n\s{0,}\n'), '\2');
    //content = '　　' + content;
    // content = content.replaceAll('\n', '\n　　');

    // price = data['welth'];
    // index = int.parse(Chapter.getReadSecId(novel.id, novel.type));
    // d(index);
    nextArticleId =
        data['next'] is int ? data['next'] : int.parse(data['next']);
    preArticleId = data['pre'] is int ? data['pre'] : int.parse(data['pre']);

    ispay();
    cut();
  }
  Article.fromcartoonJson(Map data, Novel novel) {
    if (!isnull(data)) {
      return;
    }

    if (!isnull(data['cart_section_id'])) {
      return;
    }
    section_id = data['cart_section_id'].toString();
    booktype = '2';
    book_id = data['cartoon_id'].toString();
    id = int.parse(section_id);
    novelId = int.parse(book_id);
    title = data['title'].toString();
    images = data['images'];
    content = data['images'].toString();

    isfree = data['isfree'].toString();
    pay = isnull(data['ispay']) ? true : false;
    if (!isnull(isfree)) {
      //免费的时候，支付状态为true
      pay = true;
    }
    coin = double.parse(data['coin'].toString());
    // inserdbpay(pay);
    nextArticleId = int.parse(data['next']);
    preArticleId = int.parse(data['pre']);

    // ispay();
    cutimg();
  }
  inserdbpay(bool tmppay) async {
    //把解锁记录更新到本地数据库
    if (isnull(getuid())) {
      //判断记录是否存在
      var w = {
        'secid': section_id,
        'bookid': novelId,
        'type': booktype,
        'uid': getuid(),
      };
      var data = await T('pay').getone(w);
      if (!isnull(data)) {
        //不存在就插入

        w.addAll({'pay': tmppay, 'coin': coin});
        await T('pay').add(w);
      } else {
        //更新

        if (tmppay != data['pay']) {
          //数据库不相同才更新
          await T('pay').update({'pay': tmppay, 'coin': coin}, w);
        }
      }
    }
  }

  Future<int> getindex() async {
    var data = await T('sec').getone(
        {'section_id': section_id, 'book_id': novelId, 'booktype': booktype});

    if (isnull(data)) {
      if (isnull(data['index'])) {
        return data['index'];
      }
    }
    return 0;
  }

  String stringAtPageIndex(int index) {
    if (!isnull(this.content)) {
      return '';
    }

    if (!isnull(page, index)) {
      return page[page.length - 1];
    }
    return page[index];
    // var offset = pageOffsets[index];

    // return this.content.substring(offset['start'], offset['end']);
  }

  int get pageCount {
    if (isnull(pay)) {
      //????200????
      if (booktype == '1') {
        //小说分页
        return page.length;
      } else if (booktype == '2') {
        //漫画分页
        return images.length;
      } else if (booktype == '3') {
        //漫画分页
        return page.length;
      }
    } else {
      //content??
      //?????????

      //  d(this.content.toString().substring(0, 200));
      return 1;
    }
  }
}
