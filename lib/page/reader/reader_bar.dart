import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/reader/reader_cate.dart';
import 'package:ng169/page/reader/reader_scene.dart';

import 'package:ng169/page/reader/reader_set.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/url.dart';
import 'reader_menu.dart';

typedef setCallback = dynamic Function(int articleId, PageJumpType jumpType);

class ReaderBar extends StatefulWidget {
  final Novel novel; //小说
  final List chapets; //小说
  final Article currentArticle;
  final VoidCallback reflash;
  final setCallback resetContent;
  ReaderBar(this.novel, this.chapets, this.currentArticle, this.reflash,
      this.resetContent);

  @override
  ReaderBarState createState() => ReaderBarState();
}

class ReaderBarState extends State<ReaderBar> with RouteAware {
  bool isMenuVisiable = false; //显示菜单
  bool isCateVisiable = false; //显示目录
  bool isSetVisiable = false; //显示设置

  int articleIndex;
  var chapets;
  @override
  void initState() {
    super.initState();
    if (isnull(widget.chapets)) {
      chapets = widget.chapets;
    } else {
      chapets = Chapter.get(context, widget.novel);
    }
    if (!isnull(chapets)) {
      loadchapters();
    }
  }

  loadchapters() async {
    chapets = await Chapter.getcatecache(context, widget.novel);
    if (mounted) {
      reflash();
    }
  }

  pageindex() {
    articleIndex =
        int.parse(Chapter.getReadSecId(widget.novel.id, widget.novel.type));
  }

  @override
  Widget build(BuildContext context) {
    isMenuVisiable = g('isMenuVisiable') ?? false;
    pageindex();
    return Stack(
      children: <Widget>[buildMenu(), buildcate(), buildset()],
    );
  }

  Widget buildMenu() {
    if (!isMenuVisiable) {
      return Container();
    }
    if (!isnull(chapets)) {
      return Container();
    }

    return ReaderMenu(
        chapters: chapets,
        novel: widget.novel,
        articleIndex: articleIndex,
        onTap: hideMenu,
        onPreviousArticle: () {
          if (isnull(widget.currentArticle)) {
            widget.resetContent(
                widget.currentArticle.preArticleId, PageJumpType.firstPage);
          }
        },
        onNextArticle: () {
          if (isnull(widget.currentArticle)) {
            widget.resetContent(
                widget.currentArticle.nextArticleId, PageJumpType.firstPage);
          }
        },
        onToggleChapter: (tmpchapter) {
          widget.resetContent(
              int.parse(tmpchapter.section_id), PageJumpType.firstPage);
        },
        onToggleTheme: (tmpchapter) {
          if (isnull(getcache(isnight))) {
            setcache(isnight, '0', '-1');
            if (isnull(getcache(oldthemecache))) {
              if (getcache(oldthemecache) == 'th6') {
                setcache(themecache, 'th1', '-1');
              } else {
                setcache(themecache, getcache(oldthemecache), '-1');
              }
            } else {
              setcache(themecache, 'th1', '-1');
            }
          } else {
            setcache(isnight, '1', '-1');
            setcache(oldthemecache, getcache(themecache), '-1');
            setcache(themecache, 'th6', '-1');
          }

          reflash();
        },
        showcate: () {
          hideMenu();

          isCateVisiable = true;
          reflash();
        },
        showset: () {
          hideMenu();

          isSetVisiable = true;
          reflash();
        });
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  //目录
  Widget buildcate() {
    if (isMenuVisiable) {
      //菜单栏存在则不显示
      return Container();
    }
    if (!isCateVisiable) {
      //菜单栏存在则不显示
      return Container();
    }

    return ReaderCate(
      chapters: widget.chapets,
      novel: widget.novel,
      articleIndex: articleIndex,
      onTap: hideCate,
      onPreviousArticle: () {
        widget.resetContent(
            widget.currentArticle.preArticleId, PageJumpType.firstPage);
      },
      onNextArticle: () {
        widget.resetContent(
            widget.currentArticle.nextArticleId, PageJumpType.firstPage);
      },
      onToggleChapter: (tmpchapter) {
        widget.resetContent(
            int.parse(tmpchapter.section_id), PageJumpType.firstPage);
      },
    );
  }

  //设置
  Widget buildset() {
    if (isMenuVisiable) {
      //菜单栏存在则不显示
      return Container();
    }
    if (!isSetVisiable) {
      //菜单栏存在则不显示
      return Container();
    }

    return ReaderSet(
      chapters: widget.chapets,
      novel: widget.novel,
      articleIndex: articleIndex,
      onTap: hideSet,
      reload: reload,
      reflash: () {
        widget.reflash();
      },
    );
  }

  hideMenu() {
    if (!mounted) return;

    this.isMenuVisiable = false;
    s('isMenuVisiable', false);
    reflash();
  }

  hideCate() {
    if (!mounted) return;

    this.isCateVisiable = false;
    reflash();
  }

  hideSet() {
    if (!mounted) return;

    this.isSetVisiable = false;
    reflash();
  }

  reload() {
    // widget.reflash();
    pop(context);

    widget.novel.read(context, widget.novel.readChapter);
    return;
  }
}
