import 'package:flutter/cupertino.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

class CartoonProvider {
  static Future<Article> fetchArticle(
      BuildContext context, Novel novel, int articleId) async {
    var artiicle = await getcontent(context, novel, articleId);
    if (!isnull(artiicle)) {
      return null;
    }

    var article = Article.fromcartoonJson(artiicle, novel);
    //异步检测状态

    await article.autolock();
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
    var response = await http('cartoon/get_wap_content',
        {'cartoon_id': novel.id, 'cart_section_id': secionid}, gethead());
    var tmp = getdata(context, response);
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

    Article.setCache(
        novel.id.toString(), novel.type.toString(), secionid.toString(), tmp);
    return tmp;
  }
}
