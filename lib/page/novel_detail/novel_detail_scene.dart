import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ng169/model/rack.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/commect/addcomment.dart';
import 'package:ng169/page/commect/comment.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';
import 'package:ng169/tool/url.dart';
import 'package:share/share.dart';
import 'catalog.dart';
import 'novel_comment.dart';
import 'novel_detail_header.dart';
import 'novel_summary_view.dart';
import 'novel_detail_toolbar.dart';
import 'novel_detail_cell.dart';
import 'novel_comment_cell.dart';

class NovelDetailScene extends StatefulWidget {
  final Novel novel;
  final bool opshare;

  NovelDetailScene(this.novel, [this.opshare = false]);

  @override
  NovelDetailSceneState createState() => NovelDetailSceneState();
}

class NovelDetailSceneState extends State<NovelDetailScene> with RouteAware {
  Novel novel;
  List<Novel> recommendNovels = [];
  List<NovelComment> comments = [];
  ScrollController scrollController = ScrollController();
  double navAlpha = 0;
  bool isSummaryUnfold = false, isshare = false;
  int commentCount = 0;
  int commentMemberCount = 0;
  var index;
  var indexcahcetime;
  int httpnum = 0;
  bool showload = true;
  @override
  void initState() {
    novel = this.widget.novel;
    super.initState();
    fetchData();

    Rackmodel()..upreadtime(novel);
    scrolllistener();
    // d(widget.opshare);
    if (widget.opshare) {
      share();
    }
  }

  //滚动监听
  void scrolllistener() {
    scrollController.addListener(() {
      var offset = scrollController.offset;
      if (offset < 0) {
        if (navAlpha != 0) {
          navAlpha = 0;
        }
      } else if (offset < 50) {
        navAlpha = 1 - (50 - offset) / 50;
      } else if (navAlpha != 1) {
        navAlpha = 1;
      }
      reflash();
    });
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    showtitlebar();
    titlebarcolor(false);
    super.dispose();
  }

  changeSummaryMaxLines() {
    isSummaryUnfold = !isSummaryUnfold;
    reflash();
  }

  back() {
    // Navigator.pop(context);
    pop(context);
  }

  Future<void> fetchData() async {
    var novelId = this.widget.novel.id;
    index = 'bnovelResponse' +
        this.widget.novel.type.toString() +
        '_' +
        novelId.toString();
    indexcahcetime = index + index.toString().hashCode.toString();

    loadcache();
    if (!isnull(getcache(indexcahcetime))) {
      //这里会出现初次加载的时候；接口请求两次，需要限制
      loadhttp();
    }
  }

  todate(sinfo) {
    if (!isnull(sinfo)) {
      setcache(indexcahcetime, '0', '0');
      return false;
    }
    comments = [];
    var com = sinfo['discussd'];
    if (isnull(com)) {
      com['discuss'].forEach((data) {
        NovelComment tmp = NovelComment.fromJson(data);
        if (isnull(tmp)) {
          comments.add(tmp);
        }
      });
    }
    this.novel = Novel.fromJson(sinfo['data']);
    this.commentCount = int.parse(com['count']);
    reflash();
  }

  Future<void> loadcache() async {
    var bk = getcache(index);
    if (isnull(bk)) {
      showload = false;
      todate(bk);
    } else {
      setcache(indexcahcetime, '', '1');
      loadhttp();
    }
  }

  Future<void> loadhttp() async {
    //return ;
    if (httpnum > 0) {
      //限制同一秒多次请求
      return;
    }
    httpnum = 1;
    var novelResponse;
    var novelId = this.widget.novel.id;
    switch (int.parse(this.widget.novel.type)) {
      case 1:
        {
          novelResponse = await http(
              'book/get_bookDetail', {'book_id': novelId}, gethead());
        }
        break;
      case 2:
        {
          novelResponse = await http(
              'cartoon/get_cartoonDetail', {'cartoon_id': novelId}, gethead());
        }
        break;
    }
    var tpdata = getdata(context, novelResponse);
    httpnum = 0;
    if (isnull(tpdata)) {
      showload = false;

      // reflash();
      setcache(index, tpdata, '-1');
      setcache(indexcahcetime, '1', '360');
      todate(tpdata);
    }
  }

  Widget buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: 44,
                height: Screen.navigationBarHeight,
                padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
                child: GestureDetector(
                    onTap: back,
                    child: Icon(Icons.arrow_back, color: Colors.white)),
              ),
              Expanded(child: SizedBox()),
              Container(
                width: 44,
                height: Screen.navigationBarHeight,
                padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 5, 0),
                child: GestureDetector(
                    onTap: share,
                    child: Icon(
                      Icons.share,
                      color: Colors.white,
                    )),
              ),
            ]),
        Opacity(
          opacity: navAlpha,
          child: Container(
            decoration: BoxDecoration(
                color: SQColor.white, boxShadow: Styles.borderShadow),
            padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            height: Screen.navigationBarHeight,
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  child: GestureDetector(
                      onTap: back,
                      child: Icon(
                        Icons.arrow_back,
                        // color: color,
                      )),
                ),
                Expanded(
                  child: Text(
                    novel.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 44,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: GestureDetector(
                      onTap: share,
                      child: Icon(
                        Icons.share,
                        color: Colors.grey,
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  share() {
    isshare = !isshare;
    sharefun(novel);
  }

  sharew() {
    return Container();
  }

  writecomment() async {
    //跳到
    var data = await gourl(
        context,
        AddComment(
          novel: novel,
        ));
    if (isnull(data)) {
      //提交了评论就刷新
      loadhttp();
    }
  }

  Widget buildComment() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Image.asset(
                  'assets/images/home_tip.png',
                  width: 3,
                  height: 22,
                  // color: SQColor.primary,
                ),
                SizedBox(width: 13),
                Text(lang('书友评价'), style: TextStyle(fontSize: 16)),
                Expanded(child: Container()),
                GestureDetector(
                  child: Image.asset('assets/images/detail_write_comment.png',
                      width: 16, color: SQColor.primary),
                  onTap: writecomment,
                ),
                GestureDetector(
                  onTap: writecomment,
                  child: Text('  ' + lang('写书评'),
                      style: TextStyle(fontSize: 14, color: SQColor.primary)),
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
          Divider(height: 1),
          Column(
            children:
                comments.map((comment) => NovelCommentCell(comment)).toList(),
          ),
          isnull(commentCount) ? Divider(height: 1) : Container(),
          isnull(commentCount)
              ? GestureDetector(
                  onTap: readmore,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        lang('查看全部评论') + '（$commentCount' + lang('条') + '）',
                        style: TextStyle(fontSize: 14, color: SQColor.gray),
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                      child: Text(
                    lang('还没有评论哦'),
                    style: TextStyle(fontSize: 14, color: SQColor.gray),
                  )),
                ),
        ],
      ),
    );
  }

  Widget buildTags() {
    var colors = [Color(0xFFF9A19F), Color(0xFF59DDB9), Color(0xFF7EB3E7)];
    var i = 0;
    var tagWidgets = novel.tags.map((tag) {
      var color = colors[i % 3];
      var tagWidget = Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Color.fromARGB(99, color.red, color.green, color.blue),
              width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
        child: Text(tag, style: TextStyle(fontSize: 14, color: colors[i % 3])),
      );
      i++;
      return tagWidget;
    }).toList();
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
      color: SQColor.white,
      child: Wrap(runSpacing: 10, spacing: 10, children: tagWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.novel == null) {
      return Scaffold(appBar: AppBar(elevation: 0));
    }
    if (isnull(g('pl'))) {
      s('pl', 0);
      fetchData();
    }
    var c = Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(top: 0),
                children: <Widget>[
                  NovelDetailHeader(novel),
                  NovelSummaryView(
                      isnull(novel.introduction) ? novel.introduction : '',
                      isSummaryUnfold,
                      changeSummaryMaxLines),
                  isnull(novel.lastChapterid)
                      ? NovelDetailCell(
                          iconName: 'assets/images/detail_latest.png',
                          title: lang('最新'),
                          onclick: () {
                            var tmp = {
                              'section_id': novel.lastChapterid,
                              'booktype': int.parse(novel.type),
                              "book_id": novel.id
                            };
                            Chapter.fromtmp(tmp, novel.chapterCount - 1)
                                .click();
                            novel.read(context, int.parse(novel.lastChapterid));
                          },
                          subtitle: novel.lastChaptertitle,
                          attachedWidget: Text(novel.status,
                              style: TextStyle(
                                  fontSize: 14, color: novel.statusColor())),
                        )
                      : SizedBox(),

                  Container(
                      child: NovelDetailCell(
                    onclick: () {
                      gourl_animation(
                          context,
                          new CataLog(
                            novel: novel,
                          ));
                    },
                    iconName: 'assets/images/detail_chapter.png',
                    title: lang('目录'),
                    subtitle: lang('共') + '${novel.chapterCount}' + lang('章'),
                  )),
                  // buildTags(),  //标签，此版先不加
                  SizedBox(height: 10),
                  buildComment(),
                  SizedBox(height: 10),
                  /*   NovelDetailRecommendView(recommendNovels),*/
                ],
              ),
            ),
            NovelDetailToolbar(novel),
          ],
        ),
        buildNavigationBar(),
        sharew()
      ],
    );

    return Scaffold(
      body: AnnotatedRegion(
          value: navAlpha > 0.5
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          child: RefreshIndicator(
            onRefresh: loadhttp,
            child: Loadbox(
              loading: showload,
              child: c,
            ),
            color: SQColor.primary,
          )),
    );
  }

  void readmore() {
    gourl(context, Comment(novel: novel));
  }
}
