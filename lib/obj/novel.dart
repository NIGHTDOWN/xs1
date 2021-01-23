import 'package:flutter/material.dart';
import 'package:ng169/model/rack.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/reader/article_provider.dart';
import 'package:ng169/page/reader/cartreader_scene.dart';
import 'package:ng169/page/reader/reader_scene.dart';
import 'package:ng169/page/reader/local_reader_scene.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/t.dart';
import 'package:ng169/tool/url.dart';

import 'chapter.dart';

class Novel {
  String id;
  String dbid;
  String name;
  String imgUrl;
  int firstChapter;
  int readChapter;
  int lastChapter;
  String lastChaptertitle;
  String lastChapterid;
  String isgroom;
  String author;
  double price;
  double score = 5.0;
  String type;
  String introduction;
  int chapterCount;
  int recommendCount;
  int commentCount;
  int firstArticleId;
  String lastsecnum; //上次加入书架最新章节数量
  String nowsecnum; //本次获取远程书籍最新章节数量
  int upsecnum = 0; //书架页面显示更新的章节数量
  List<String> roles;
  String status;
  int _status;
  String desc;
  double wordCount;
  List<String> tags;
  bool isLimitedFree;
  String uid;
  Map comment;
  List catelog; //目录
  String isdownload;
  String downrate = '0';

  setcomment(Map comments) {
    comment = comments;
  }

  savedb() async {
    if (!isnull(id)) return false;
    // var db = g('db');
    var w = {'bookid': id, 'type': type};
    // var ins = await db.where(w).getone('book');
    var ins = await T('book').where(w).getone();

    Map<String, dynamic> insert = {
      // 'bookid': id,
      'bookname': name,
      'type': type,
      'author': author,
      'pic': imgUrl,
      'about': desc,
      'bookid': id,
      'isfree': isLimitedFree,
      'scroe': score,
      'price': price,
      // 'isgroom': isgroom,
      'secnum': lastChapter,
      'readsec': readChapter,
    };
    //登入的时候才更新书架状态，且书架状态为1才更新
    // insert.addAll({'uid': User.getuid()});
    // if (isnull(user)) {
    //   // insert.addAll({'uid': User.getuid()});
    //   if (isgroom == '1') {
    //     insert.addAll({'isgroom': isgroom});
    //   }
    // } else {
    //   //未登入的除非有gromm状态，否则全部为0

    //   if (isgroom == '1') {
    //     insert.addAll({'isgroom': isgroom});
    //   } else {
    //     insert.addAll({'isgroom': 0});
    //   }
    // }
    if (!isnull(ins)) {
      // db.add('book', insert);
      T('book').add(insert);
      //添加
    } else {
      isgroom = isnull(isgroom) ? isgroom : ins['isgroom'].toString();
      insert.addAll({'bookid': id});
      if (!isnull(ins, 'addtime')) {
        insert.addAll({'addtime': gettime()});
      }
      T('book').update(insert, w);
      // db.update('book', insert, w);
      //更新
    }
  }
  //更新数据库书架状态

  updbgroom() async {
    if (!isnull(id)) return false;
    var db = g('db');
    var w = {'bookid': id, 'type': type};
    // var ins = await db.where(w).getone('book');
    var ins = await T('book').where(w).getone();
    var user = User.get();

    Map<String, dynamic> insert = {};
    if (isnull(nowsecnum)) {
      //检查最新章节数量
      insert.addAll({'nowsecnum': nowsecnum});
    }
    //登入的时候才更新书架状态，且书架状态为1才更新
    insert.addAll({'uid': User.getuid()});
    if (isnull(user)) {
      // insert.addAll({'uid': User.getuid()});
      if (isgroom == '1') {
        insert.addAll({'isgroom': isgroom});
      }
    } else {
      //未登入的除非有gromm状态，否则全部为0

      if (isgroom == '1') {
        insert.addAll({'isgroom': isgroom});
      } else {
        insert.addAll({'isgroom': 0});
      }
    }
    if (!isnull(ins)) {
      // db.add('book', insert);
      //添加
    } else {
      insert.addAll({'bookid': id});
      if (!isnull(ins['addtime'])) {
        insert.addAll({'addtime': gettime()});
      }
      T('book').update(insert, w);
      //更新
    }
  }

  getgroom() async {
    var uid = getuid();
    if (!isnull(uid)) {
      isgroom = '0';
      return '0';
    }
    var dbdata =
        await T('book').getone({'type': type, 'bookid': id, 'uid': uid});

    if (isnull(dbdata)) {
      if (isnull(dbdata['isgroom'])) {
        isgroom = '1';
        return '1';
      }
    }
    isgroom = '0';
    return '0';
  }

  isdown() async {
    var dbdata = await T('book').getone({'type': type, 'bookid': id});
    //判断缓存比列

    if (isnull(dbdata)) {
      if (isnull(dbdata['isdownload'])) {
        await continuedown();
        isdownload = '1';
        return '1';
      }
    }
    isdownload = '0';
    return '0';
  }

  //继续缓存
  continuedown() async {
    //
    int cateall =
        await T('sec').where({'book_id': id, 'booktype': type}).getcount();
    int catedown =
        await T('sec').where({'book_id': id, 'booktype': type}).getcount();
    if (!isnull(cateall)) {
      //，目录获取失败分母为0
      downrate = '0';
    } else {
      downrate = (((catedown / cateall) * 100).toStringAsFixed(0));
      // d(cateall);
      // d(catedown);
      // d(((catedown / cateall) * 100).toStringAsFixed(0));
      if (int.parse(downrate) < 100) {
        // 继续下载
        down();
      }
    }
  }

  Novel.fromJson(Map data) {
    id = isnull(data['book_id'])
        ? data['book_id']
        : isnull(data['cartoon_id']) ? data['cartoon_id'] : 0;
    //firstArticleId = data['first_article_id'];
    name = data['other_name'];
    imgUrl = data['bpic'];
    if (dslStatus && isnull(dslDomain)) {
      if (isnull(data, 'bpic_dsl')) {
        imgUrl = data['bpic_dsl'];
      }
    }

    desc = isnull(data['desc']) ? data['desc'] : '';
    type = isnull(data['book_id']) ? '1' : '2';
    type = isnull(data['type']) ? data['type'].toString() : type;
    isgroom = !isnull(data['isgroom']) ? '0' : '1';
    readChapter = isnull(data['readsec']) ? int.parse(data['readsec']) : 0;
    lastChapter = isnull(data['secnum']) ? int.parse(data['secnum']) : 0;
    author = isnull(data['writer_name']) ? data['writer_name'] : lang('匿名');
    nowsecnum = isnull(data['newnum']) ? data['newnum'] : '0';
    wordCount = isnull(data['wordnum'])
        ? double.parse(data['wordnum'].toString())
        : 0.0;
    price =
        isnull(data['price']) ? double.parse(data['price'].toString()) : 0.0;
    score = isnull(data['replynum'])
        ? double.parse(data['replynum'].toString())
        : 5.0;
    // type = data['class_name'];
    lastChaptertitle = data['new_section_title'];
    lastChapterid = data['new_section_id'];
    introduction = data['desc'];
    if (isnull(data, 'update_section')) {
      chapterCount = int.parse(data['update_section'] ?? 0);
    } else {
      //获取最新章节数量
      getchapterCount();
    }
    recommendCount =
        int.parse(isnull(data['recommend_num']) ? data['recommend_num'] : '0');

    //commentCount = int.parse(data['discussd']['count'] ?? '0');
    _status =
        isnull(data['update_status']) ? int.parse(data['update_status']) : 0;
    switch (_status) {
      case 1:
        status = lang('完结');
        break;
      default:
        status = lang('连载中');
    }

    // wordCount = data['wordCount'];
    // tags = data['tag']?.cast<String>()?.toList();

    // isLimitedFree = data['is_free'] == 1;
    // getgroom();
    savedb();
  }
  //更新书架状态
  initrack() {}
  getchapterCount() async {
    // var list = await Chapter.getcatecache(g('context'), this);
    var where = {'book_id': id, 'booktype': type};
    var list = await T('sec').where(where).getcount();
    if (isnull(list)) {
      chapterCount = list;
    }
  }

  //创建本地书籍
  static fromloacl(String bname) async {
    var name = bname;
    var type = '3';
    var isgroom = '1';
    var author = 'local';
    var isin = await T('book').where({'bookname': name, 'type': type}).getone();
    if (isnull(isin)) {
      //已经导入了
      T('book').update({
        'uid': User.getuid(),
        'addtime': gettime(),
        'isgroom': isgroom,
      }, {
        'bookname': name,
        'type': type
      });
      return 0;
    } else {
      int idstart = 90000;
      int bid;
      var id =
          await T('book').where({'type': type}).order('bookid desc').getone();

      // d(await T('book').getall());
      if (isnull(id)) {
        bid = id['bookid'] + 1;
      } else {
        bid = idstart;
      }
      var insert = {
        'bookname': name,
        'type': type,
        'author': author,
        'addtime': gettime(),
        // 'pic': imgUrl,
        // 'about': desc,
        'bookid': bid,
        'isfree': 0,
        'scroe': 0,
        'price': 0,
        'uid': User.getuid(),
        'isgroom': isgroom,
      };
      var inid = await T('book').add(insert);
      if (isnull(inid)) {
        return bid;
      } else {
        return 0;
      }
    }
  }

  Novel.fromDb(Map data) {
    //d(data);
    //d(data['book_id']);
    id = data['bookid'].toString();
    dbid = data['id'].toString();
    //d(id);
    //firstArticleId = data['first_article_id'];
    // if (data['bookname'] is int) {
    //   name = data['bookname'].toString();
    // } else {
    name = '' + data['bookname'].toString();
    // }
    imgUrl = data['pic'];
    desc = data['desc'];
    type = data['type'].toString();
    isgroom = data['isgroom'].toString();
    readChapter = isnull(data['readsec']) ? int.parse(data['readsec']) : 0;
    lastChapter = isnull(data['secnum']) ? int.parse(data['secnum']) : 0;
    lastsecnum = data['lastsecnum'].toString();
    nowsecnum = data['nowsecnum'].toString();
    if (isnull(lastsecnum) && isnull(nowsecnum)) {
      //执行

      upsecnum = int.parse(nowsecnum) - int.parse(lastsecnum);
    }

    author = isnull(data['author']) ? data['author'] : lang('匿名');
    _status =
        isnull(data['update_status']) ? int.parse(data['update_status']) : 0;
    switch (_status) {
      case 1:
        status = lang('完结');
        break;
      default:
        status = lang('连载中');
    }
  }
  //获取书籍信息，先从数据库拉取，数据库没就从远程拉取
  static fromID(int id, int type) async {
    var tmp = {'bookid': id, 'type': type};
    var db = await T('book').where(tmp).getone();
    if (isnull(db)) {
      return Novel.fromDb(db);
    } else {
      var api, tmpdata;
      if (type == 1) {
        api = 'book/get_bookDetail';
        tmpdata = {'book_id': id};
      } else {
        api = 'cartoon/get_cartoonDetail';
        tmpdata = {'cartoon_id': id};
      }
      var tmpremote = await http(api, tmpdata, gethead());
      var data = getdata(g('context'), tmpremote);
      if (isnull(data)) {
        return Novel.fromJson(data['data']);
      }
      return Novel.fromJson({'book_id': id, 'type': type});
    }
  }

  Future<int> getprogress() async {
    int tmp = int.parse(Chapter.getReadSecId(id, type));
    if (tmp == 0) {
      return 0;
    }
    var sizes = await T('book').where({'bookid': id, 'type': type}).getone();
    var tmp2;
    if (isnull(sizes) && isnull(sizes, 'lastsecnum')) {
      int size = (sizes['lastsecnum'] - 1);

      size = size > 0 ? size : 1;

      tmp2 = tmp / size * 100;
    } else {
      tmp2 = 0;
    }

    return tmp2.round();
  }

  String recommendCountStr() {
    if (recommendCount >= 10000) {
      return (recommendCount / 10000).toStringAsFixed(1) + lang('万人推荐');
    } else {
      return recommendCount.toString() + lang('人推荐');
    }
  }

  Color statusColor() {
    return _status == 1 ? SQColor.blue : SQColor.primary;
  }

  //添加书架
  addgroom() async {
    isgroom = '1';
    // savedb();
    var tmp =
        await http('groom/add_rack', {'book_id': id, 'type': type}, gethead());
    var data = getdata(g('context'), tmp);
    if (isnull(data)) {
      Rackmodel()..addrack(this);
      //状态
    }
  }

  downbook() async {
    //异步缓存所有章节倒数据库
    //这里书逻辑
    var context;
    await Chapter.getcatecache(context, this);

    // await secs.forEach((v) {
    //   ArticleProvider.getremotecontent(context, this, v['section_id']);
    // });

    var tmp = await T('sec').where({'cacheflag': 0, 'book_id': id}).getall();
    for (var i = 0; i < tmp.length; i++) {
      //重新缓存所有未完成的缓存
      await ArticleProvider.getcontent(context, this, tmp[i]['section_id']);
    }
    var tmp2 = await T('sec').where({'cacheflag': 2, 'book_id': id}).getall();
    for (var i = 0; i < tmp2.length; i++) {
      //重新缓存所有未完成的缓存
      await ArticleProvider.getcontent(context, this, tmp2[i]['section_id']);
    }
  }

  //书籍缓存
  down() {
    isdownload = '1';
    T('book').update({'isdownload': 1}, {'bookid': id, 'type': type});
    downbook();
    return isdownload;
  }

  removegroom() async {
    isgroom = '0';
    // savedb();
    // var tmp =
    //     await http('groom/add_rack', {'book_id': id, 'type': type}, gethead());
    // var data = getdata(g('context'), tmp);
    // if (isnull(data)) {
    if (type == '1') {
      http('groom/delrack', {'book_id': id}, gethead());
    } else {
      http('groom/delrack', {'cartoon_id': id}, gethead());
    }

    //本地
    T('book')
        .update({'isgroom': 0, 'uid': getuid()}, {'bookid': id, 'type': type});
    //状态
    // }

    Rackmodel().rackrf();
  }

  read(context, [int readChapter]) async {
    Rackmodel()..upreadtime(this);
    if (type == '1') {
      await gourl(context, ReaderScene(this, readChapter));
    } else if (type == '2') {
      await gourl(context, CartReaderScene(this, readChapter));
    } else if (type == '3') {
      await gourl(context, LocalReaderScene(this, readChapter));
    }

    //更新阅读记录
  }

//添加阅读记录
  addreadlog(secid) async {
    var uid = getuid();
    Map<String, dynamic> where = {'uid': uid, 'bookid': id, 'type': type};
    var getdb = await T('read').where(where).getone();
    if (isnull(getdb)) {
      //更新
      T('read').where(where).update({"readtime": gettime(), 'secid': secid});
    } else {
      //插入
      T('read').add(({
        'uid': uid,
        'bookid': id,
        'type': type,
        "readtime": gettime(),
        'secid': secid
      }));
    }
  }
}
