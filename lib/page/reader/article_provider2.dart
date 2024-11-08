import 'package:flutter/cupertino.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/t.dart';

class ArticleProvider2 {
  //本地获取
  static Future<Article?> fetchArticle(
      BuildContext context, Novel novel, int order) async {
    var artiicle, article;

    artiicle = await getcontent(context, novel, order);

    if (!isnull(artiicle)) {
      return null;
    }

    if (novel.type == "2") {
      article = Article.fromcartoonJson(artiicle, novel);
    } else {
      article = Article.fromJson(artiicle, novel);
    }

    if (novel.type != '3') {
      //异步检测状态
      await article.autolock();
    } else {
      article.pay = true;
    }
    return article;
  }

  static Future<Article?> fetchArticleRemote(
      BuildContext context, Novel novel, int order) async {
    var artiicle, article;
    artiicle = await getremotecontent(context, novel, order);
    if (!isnull(artiicle)) {
      return null;
    }

    if (novel.type == "2") {
      article = Article.fromcartoonJson(artiicle, novel);
    } else {
      article = Article.fromJson(artiicle, novel);
    }

    if (novel.type != '3') {
      //异步检测状态
      await article.autolock();
    } else {
      article.pay = true;
    }
    return article;
  }

  //获取章节详情
  static getcontent(context, Novel novel, order) async {
    //数据库缓存有问题
    if (order < 1) {
      order = 1;
    }
    var cache = null;
    if (toint(novel.type) <= 2) {
      cache = Article.getCache(
          novel.id.toString(), novel.type.toString(), order.toString());
    }
    if (isnull(cache)) {
      return cache;
    } else {
      d("api拉取" + order.toString());
      return await getremotecontent(context, novel, order);
    }
  }

  //获取远程数据
  static Future<dynamic> getremotecontent(context, Novel novel, order) async {
    if (!isnull(order)) return null;
    var tmp;
    if (novel.type != '3') {
      var response = await http('book/get_content',
          {'book_id': novel.id, "type": novel.type, 'index': order}, gethead());
      tmp = getdata(context, response);
    } else {
      tmp = {};
      var tmps = await T('sec')
          .where({'book_id': novel.id, 'index': order, 'booktype': 3}).getone();
      if (!isnull(tmps)) {
        return [];
      } else {
        tmp['content'] = tmps["cachedata"];
        tmp['section_id'] = tmps["section_id"];
        tmp['content'] = tmps["cachedata"];
        tmp['book_id'] = tmps["book_id"];
        tmp['isfree'] = tmps["isfree"];
        tmp['booktype'] = tmps["booktype"];
        tmp['index'] = tmps["index"];
        tmp['secnum'] = tmps["secnum"];
        tmp['ispay'] = tmps["ispay"];
        tmp['coin'] = tmps["coin"];
        tmp['sec_content'] = tmps["cachedata"];
      }
    }

//有下一章加换成短时间；否则永久缓存
    if (isnull(tmp, 'next')) {
      Article.setCache(
          novel.id.toString(), novel.type.toString(), order.toString(), tmp);
    } else {
      Article.setCache(novel.id.toString(), novel.type.toString(),
          order.toString(), tmp, "46400");
    }
    return tmp;
  }
}
