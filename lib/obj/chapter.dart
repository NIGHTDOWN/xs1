import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

import 'novel.dart';

class Chapter {
  int id = 0;
  String book_id = "0";
  int book_type = 0;
  String coin = "0";
  String isfree = "0";
  String title = "0";
  String ispay = "0";
  String secnum = "0";
  String section_id = "0";
  String update_time = "0";
  int index = 0;
  String click_cache_name = "";
  String read_sign_cache_name = "";
  int read_sign = 0; //????
  Chapter.fromJson(Map data, int i) {
    //section_id = data['id'].toString();
    index = i;
    id = data['section_id'] is int
        ? data['section_id']
        : int.parse(data['section_id']);
    book_type =
        isnull(data['booktype']) ? int.parse(data['booktype'].toString()) : 1;
    book_id = data['book_id'].toString();
    coin = data['coin'].toString();
    isfree = data['isfree'].toString();
    title = data['title'];
    title = trim(title);
    ispay = data['ispay'].toString();
    secnum = data['secnum'].toString();
    section_id = data['section_id'].toString();
    update_time = data['update_time'].toString();
    click_cache_name = book_id + '_' + book_type.toString() + '_' + section_id;
    read_sign_cache_name = book_id + '_' + book_type.toString();
  }
  //获取最新的解锁状态
  getpaystat() {
    if (isnull(getuid)) {
      //如果是登入状态才检测
    }
  }

  Chapter.fromtmp(Map data, int i) {
    index = i;
    id = int.parse(data['section_id']);
    book_type = data['booktype'];
    book_id = data['book_id'].toString();
    //coin = data['coin'].toString();
    section_id = data['section_id'].toString();
    click_cache_name = book_id + '_' + book_type.toString() + '_' + section_id;
    read_sign_cache_name = book_id + '_' + book_type.toString();
  }
  static String getReadSecId(String bookid, String booktype) {
    var tmpReadSignCacheName = bookid + '_' + booktype.toString();
    var iss = getcache(tmpReadSignCacheName);

    if (isnull(iss)) return iss;
    return '0';
  }

  bool isclick() {
    var iss = getcache(click_cache_name);
    if (isnull(iss)) return true;
    return false;
  }

  String getReadSign() {
    var iss = getcache(read_sign_cache_name);
    if (isnull(iss)) return iss;
    return '0';
  }

  bool isSignHere() {
    String readid = getReadSign();

    if (readid == index.toString()) {
      return true;
    }
    return false;
  }

  void click() {
    setcache(click_cache_name, 1, '-1');
    setcache(read_sign_cache_name, index.toString(), '-1');
  }

  static void clickout(bookId, bookType, sectionId, index) {
    if (!isnull(sectionId)) {
      return;
    }
    var clickCacheNames = bookId + '_' + bookType.toString() + '_' + sectionId;
    var readSignCacheNames = bookId + '_' + bookType.toString();
    setcache(clickCacheNames, 1, '-1');
    setcache(readSignCacheNames, index.toString(), '-1');
  }

  static Future<List> getfromdb(context, Novel novel,
      [bool nocache = true]) async {
    // var bookid = novel.id;
    // var cacheindex = 'chapter' + bookid.toString() + getuid().toString();
    // var cache = getcache(cacheindex);
    var where = {'book_id': novel.id, 'booktype': 3};
    var data = await T('sec')
        .where(where)
        .field('section_id,id,book_id,title,`index`,booktype')
        .order('`index` asc')
        .getall();
    if (isnull(data)) {
      setbookcache(context, novel, data);
      // setdbcache(chaptersResponse);
      var cacheindex = 'chapter' + novel.id + getuid().toString(); //不同用户缓存id不一样
      String cacheindextime =
          'chapter' + novel.id + cacheindex.hashCode.toString();
      setcache(cacheindextime, '1', '3600');
      return isnull(data) ? data : [];
    } else {
      return [];
    }
  }

  static Future<List> getcatecache(context, Novel novel) async {
    var bookid = novel.id;
    var cacheindex =
        'chapter' + bookid.toString() + getuid().toString(); //不同用户缓存id不一样

    var cacheindextime =
        'chapter' + bookid.toString() + cacheindex.hashCode.toString();
    var cache = getcache(cacheindextime);

    if (isnull(cache)) {
      //从数据库读取,如果未登入直接取，否则连表取数据
      var tmp = get(context, novel);

      if (isnull(tmp)) {
        return tmp;
      }
    }
    if (novel.type != '3') {
      return await gethttp(context, novel);
    } else {
      d(novel);
      return await getfromdb(context, novel);
    }
  }

  static upcachefromdb(context, bookid) async {
    //性能消耗太大,弃用
    // List tmpfree, tmpunfree, tmp = [];

    // tmpfree = await T('sec')
    //     .where({'book_id': bookid})
    //     .wherestring('isfree!=1')
    //     .order('`index` asc')
    //     .getall();
    // tmpunfree = await T('sec')
    //     .where({'book_id': bookid, 'isfree': 1})
    //     .order('`index` asc')
    //     .getall();

    // tmp.addAll(tmpfree);

    // if (isnull(getuid())) {
    //   tmpunfree.forEach((v) async {
    //     Map tmplist = Map.from(v);

    //     var status = await T('pay').where({
    //       'bookid': bookid,
    //       'type': v['booktype'],
    //       'secid': v['section_id'],
    //       'uid': getuid()
    //     }).getone();

    //     tmplist['ispay'] = status['pay'];
    //     tmp.add(v);
    //   });

    // } else {
    //   tmp.addAll(tmpunfree);
    // }
    // var tmp = await getcatecache(context, bookid);
    // d(tmp);
    // setbookcache(context, bookid, tmp);
  }

  static Future<List> gethttp(context, Novel novel) async {
    var bookid = novel.id;
    var api, data;
    var cacheindex =
        'chapter' + bookid.toString() + getuid().toString(); //不同用户缓存id不一样
    String cacheindextime =
        'chapter' + bookid.toString() + cacheindex.hashCode.toString();
    if (novel.type == '1') {
      api = 'book/get_section';
      data = {'book_id': bookid};
    } else {
      api = 'cartoon/get_cart_section';
      data = {'cartoon_id': bookid};
    }
    var chapters = await http(api, data, gethead());
    List<dynamic> chaptersResponse = getdata(context, chapters!);

    setbookcache(context, novel, chaptersResponse);
    setdbcache(chaptersResponse);
    setcache(cacheindextime, '1', '3600');
    return isnull(chaptersResponse) ? chaptersResponse : [];
  }

//设置小说目录缓存
  static setbookcache(context, novel, cache) {
    var bookid = novel.id;
    var cacheindex = 'chapter' +
        bookid.toString() +
        novel.type +
        getuid().toString(); //不同用户缓存id不一样
    setcache(cacheindex, cache, '-1');
  }

  static List get(context, Novel novel, [bool nocache = true]) {
    var bookid = novel.id;
    var cacheindex =
        'chapter' + bookid.toString() + novel.type + getuid().toString();
    var cache = getcache(cacheindex);
    if (isnull(cache) && nocache) {
      return cache;
    } else {
      return [];
    }
  }

  //存数据库记录
  static setdbcache(cache) {
    if (isnull(cache)) {
      makechapter(cache);
    }
  }

  //生成数据库目录
  static makechapter(chapters) async {
    for (var i = 0; i < chapters.length; i++) {
      //里面的同步，全异步会锁死数据库
      await insetcate(chapters[i], i);
      await insertpay(chapters[i]);
    }
  }

  static insetlocal(int bookid, int index, String title, String content) async {
    if (!isnull(bookid)) return;
    if (!isnull(content)) return;
    var insert = {
      'section_id': index,
      'title': title,
      'book_id': bookid,
      'isfree': 0,
      'secnum': content.length,
      'cachedata': content,
      'update_time': gettime(),
      'booktype': 3,
      'index': index,
    };
    return await T('sec').add(insert);
  }

  static insetcate(Map v, int i) async {
    var w = {
      'section_id': v['section_id'],
      'book_id': v['book_id'],
      'booktype': v['booktype'] ?? 1
    };
    var data = await T('sec').getone(w);
    // d(v);
    // d(w);
    // d(data);
    var insert = {
      'section_id': v['section_id'],
      'title': v['title'],
      'book_id': v['book_id'],
      'isfree': v['isfree'],
      'secnum': v['secnum'],
      'update_time': v['update_time'],
      'coin': v['coin'],
      'ispay': v['isfree'] == 1 ? 1 : 0,
      'booktype': v['booktype'] ?? 1,
      'index': i,
    };
    if (!isnull(data)) {
      await T('sec').add(insert);
    } else {
      //更新太多数据库有压力

      // d(data);
      await T('sec').update(insert, w);
    }
  }

  //把支付状态入库
  static insertpay(Map v) async {
    //免费就不管
    if (v['isfree'].toString() != '1') {
      return false;
    }

    //添加购买记录
    if (isnull(getuid())) {
      //判断记录是否存在
      var w = {
        'secid': v['section_id'],
        'bookid': v['book_id'],
        'type': v['booktype'],
        'uid': getuid(),
      };
      var data = await T('pay').getone(w);
      if (!isnull(data)) {
        //不存在就插入
        w.addAll({'pay': v['ispay'], 'coin': v['coin']});
        await T('pay').add(w);
      } else {
        //更新

        if (v['ispay'] != data['pay']) {
          //数据库不相同才更新
          await T('pay').update({'pay': v['ispay'], 'coin': v['coin']}, w);
        }
      }
    }
  }
}
