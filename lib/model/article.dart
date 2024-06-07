import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';

import 'package:ng169/page/reader/article_provider2.dart';

import 'package:ng169/page/reader/reader_page_agent.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

class Article {
  int id = 0;
  int novelId = 0;
  int price = 0;
  String booktype = "";
  int index = 1;
  int nextArticleId = 0;
  int preArticleId = 0;
  String title = "";
  String content = "";
  List images = [];
  List imagestmp = [];
  String contenttmp = "";
  String section_id = "";
  String dsl = "";
  String book_id = "";
  String update_time = "";
  String isfree = "";
  double coin = 0.0;
  int cutlength = 300; //????
  bool pay = false; //????
  bool cartoonisinit = true; //????
  List<Map<String, int>> pageOffsets = [];
  List<String> page = [];

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
    return getCache(
        novelId.toString(), booktype.toString(), section_id.toString());
  }

  uparticlecache(cache) {
    setCache(novelId.toString(), booktype.toString(), section_id.toString(),
        cache, '0');
  }

  static getCache(String novelId, String noveltype, String sectionid) {
    String cacheindex = 'bookorder_' + novelId + noveltype + sectionid;
    var cache = getcache(cacheindex);
    return cache;
  }

  static setCache(String novelId, String noveltype, String sectionid, cache,
      [String time = '-1']) {
    String cacheindex = 'bookorder_' + novelId + noveltype + sectionid;
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
      } else {
        contenttmp = content;
      }
    }
  }

  cutimg() {
    if (pay) {
      return;
    }
    //????
    if (isnull(images)) {
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
    savedb();
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
      postdata = {
        'book_id': novelId,
        'section_id': section_id,
        'expend_red': coin
      };
    } else {
      postdata = {
        'cartoon_id': novelId,
        'cart_section_id': section_id,
        'expend_red': coin
      };
    }
    postdata.addAll({'isauto': isnull(getcache(autounlock)) ? 1 : 0});
    var rettmp = await http('user/deblocking', postdata, gethead());
    var ret = getdata(context, rettmp!);
    if (isnull(ret)) {
      Novel novel = await Novel.fromID(novelId, int.parse(booktype));
      //拉数据
      await reload(context, novel, index);
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

        var cache = await Chapter.getcatecache(context, novel);
        //????
        var indexs = await T('sec').where({
          'book_id': novelId,
          'section_id': section_id,
          'booktype': booktype
        }).getone();
        if (isnull(indexs)) {
          cache[indexs['index'] - 1]['ispay'] = 1;
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

//重新拉取章节详情
  reload(context, novel, secid) async {
    Article article;
    if (!isnull(context)) {
      context = g("context");
    }
    if (!isnull(secid)) return;
    if (booktype == '1') {
      article = (await ArticleProvider2.fetchArticleRemote(
          context, novel, toint(secid)))!;
      article.initpage();
    } else {
      article = (await ArticleProvider2.fetchArticleRemote(
          context, novel, toint(secid)))!;
    }

    this.content = article.content;
    this.images = article.images;
    this.contenttmp = article.content;
    this.pay = article.pay;
    this.page = article.page;
  }

  initpage() {
    this.page = ReaderPageAgent.getPage(
      content,
    );
  }

  Article.fromJson(Map data, Novel novel) {
    if (!isnull(data)) {
      return;
    }
    index = toint(data['list_order']);
    section_id = data['section_id'].toString();
    booktype = novel.type;
    book_id = data['book_id'].toString();
    id = int.parse(section_id);
    novelId = int.parse(book_id);
    title = data['title'].toString();
    content = data['sec_content'].toString();
    isfree = data['isfree'].toString();
    pay = isnull(data['ispay']) ? true : false;
    coin = isnull(data, 'coin') ? double.parse(data['coin'].toString()) : 0.00;
    if (isnull(data, 'next')) {
      nextArticleId = toint(data['next']);
    }
    if (isnull(data, 'pre')) {
      preArticleId = toint(data['pre']);
    }
    ispay();
    cut();
    initpage();
    savedb();
  }
  Article.fromcartoonJson(Map data, Novel novel) {
    if (!isnull(data)) {
      return;
    }

    if (!isnull(data['cart_section_id'])) {
      return;
    }
    section_id = data['cart_section_id'].toString();
    index = toint(data['list_order']);
    booktype = '2';
    book_id = data['cartoon_id'].toString();
    id = int.parse(section_id);
    novelId = int.parse(book_id);
    title = data['title'].toString();
    images = data['images'];
    content = data['images'].toString();
    if (dslStatus && isnull(dslDomain)) {
      if (isnull(data, 'images_dsl')) {
        dsl = data['dsl'];
        images = data['images_dsl'];
        content = data['images_dsl'].toString();
      }
    }

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
    savedb();
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
    savedb();
  }

  Future<int> getindex() async {
    if (isnull(index)) return index;
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
  }

  savedb() async {
    var insert = {
      'section_id': section_id,
      'title': title,
      'book_id': book_id,
      'isfree': isfree,
      'secnum': content.length,
      'update_time': gettime(),
      'coin': coin,
      'cachedata': content,
      'ispay': pay,
      'booktype': booktype,
      'index': index,
      'cacheflag': 0,
    };
    if (content.length > 0) {
      //如果里面章节详情有数据加保存缓存状态2
      insert['cacheflag'] = 1;
    }
    var w = {
      'book_id': book_id,
      'booktype': booktype,
      'index': index,
    };
    if (!(await isdb())) {
      //更新
      T("sec").insert(insert);
    } else {
      //插入
      T("sec").update(insert, w);
    }
  }

  isdb() async {
    var tmps = await T('sec').where(
        {'book_id': novelId, 'index': index, 'booktype': booktype}).getone();

    if (!isnull(tmps)) {
      return false;
    } else {
      return true;
    }
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
    return 0;
  }
}
