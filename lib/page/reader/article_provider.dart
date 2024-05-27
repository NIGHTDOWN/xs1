import 'package:flutter/cupertino.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

class ArticleProvider {
  static Future<Article?> fetchArticle(
      BuildContext context, Novel novel, int articleId) async {
    var artiicle, article;
    if (novel.type != '3') {
      artiicle = await getcontent(context, novel, articleId);

      if (!isnull(artiicle)) {
        return null;
      }

      article = Article.fromJson(artiicle, novel);
      //异步检测状态

      await article.autolock();
    } else {
      artiicle = await getcontent(context, novel, articleId);
      if (!isnull(artiicle)) {
        return null;
      }

      article = Article.fromJson(artiicle, novel);
      article.pay = true;
    }

    return article;
  }

  static getcontent(context, Novel novel, secionid) async {
    //数据库缓存有问题

    var cache = Article.getCache(
        novel.id.toString(), novel.type.toString(), secionid.toString());
    if (isnull(cache)) {
      return cache;
    } else {
      return await getremotecontent(context, novel, secionid);
    }
  }

  static Future<dynamic> getremotecontent(
      context, Novel novel, secionid) async {
    if (!isnull(secionid)) return null;
    var tmp;
    if (novel.type != '3') {
      // var response = await http('book/get_wap_content',
      //     {'book_id': novel.id, 'section_id': secionid}, gethead());
      var response = await http('content/get_book',
          {'book_id': novel.id, 'section_id': secionid}, gethead());
      tmp = getdata(context, response);

      var w = {
        'book_id': novel.id,
        'section_id': secionid,
        'booktype': novel.type
      };
      if (!isnull(tmp)) {
        //失败
        var update = {'cacheword': response, 'cacheflag': 2};
        T('sec').update(update, w);
        return [];
      } else {
        var update = {'cachedata': response, 'cacheflag': 1, 'cacheword': ''};
        T('sec').update(update, w);
      }
    } else {
      var tmps = await T('sec').where({
        'book_id': novel.id,
        'section_id': secionid,
        'booktype': 3
      }).getone();
      if (!isnull(tmps)) {
        return [];
      } else {
        var next = await T('sec')
            .where({
              'book_id': novel.id,
              // 'section_id': secionid,
              'booktype': 3
            })
            .wherestring('`index`>' + tmps['index'].toString())
            .order('`index` asc')
            .field('section_id')
            .getone();
        var pre = await T('sec')
            .where({
              'book_id': novel.id,
              // 'section_id': secionid,
              'booktype': 3
            })
            .wherestring('`index`<' + tmps['index'].toString())
            .order('`index` desc')
            .field('section_id')
            .getone();

        tmp = {
          "next": isnull(next) ? next['section_id'].toString() : '0',
          "pre": isnull(pre) ? pre['section_id'].toString() : '0',
          "section_id": tmps['section_id'],
          "title": tmps['title'],
          "isfree": "0",
          "ispay": 0,
          "coin": 0,
          "isvip": false,
          "book_id": tmps['book_id'],
          "update_time": tmps['update_time'],
          "sec_content_id": tmps['section_id'],
          "sec_content": tmps['cachedata'],
        };
      }
    }

    // var cacheindex = 'book_' +
    //     novel.id.toString() +
    //     novel.type.toString() +
    //     secionid.toString();
    // setcache(cacheindex, tmp, '-1');

    if (isnull(tmp, 'next')) {
      Article.setCache(
          novel.id.toString(), novel.type.toString(), secionid.toString(), tmp);
    } else {
      Article.setCache(novel.id.toString(), novel.type.toString(),
          secionid.toString(), tmp, "46400");
    }

    return tmp;
  }
}
