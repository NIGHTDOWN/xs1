import 'package:flutter/material.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/Novelimage.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class InCataLog extends StatefulWidget {
  final Novel novel;
  final void Function(Chapter chapter) clickChapter;
  const InCataLog({Key? key, required this.novel, required this.clickChapter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => InCataLogState();
}

class InCataLogState extends State<InCataLog> {
  List remotedata = [];

  ScrollController scrollController = new ScrollController();
  double goread = 0.0;
  //跳转到阅读指针的位置
  late String readid;
  gotoreadsign() {
    getpostion();
    if (scrollController.hasClients && remotedata.length > 0) {
      scrollController.jumpTo(goread);
    }
  }

  double hafelines = 0;
  double gethanglin() {
    if (isnull(hafelines)) return hafelines;
    double lines = getScreenHeight(context) / 51 - 3;
    hafelines = lines / 2;
    return hafelines;
  }

  void getpostion() {
    readid = Chapter.getReadSecId(this.widget.novel.id, this.widget.novel.type);
    double hafelines = gethanglin();
    var h = getScreenHeight(context) - (51 * hafelines);
    double tmp = int.parse(readid) * 51.0;
    if (h > tmp) {
      goread = 0;
    } else {
      //到最后一页的时候滚动页面不能超过半屏
      if (int.parse(readid) > (remotedata.length - (hafelines + 2))) {
        goread = ((remotedata.length - 3.2) * 51) - h; //全屏
      } else {
        goread = tmp - (51 * hafelines); //半屏
      }
    }
  }

  @override
  initState() {
    super.initState();
    loadpage();
    initool(); //初始化控件
    WidgetsBinding.instance.addPostFrameCallback((_) => gotoreadsign());
  }

  Future<void> gethttpdata() async {
    remotedata = await Chapter.gethttp(context, this.widget.novel);
    gotoreadsign();
    refresh();
  }

  loadpage() {
    remotedata = Chapter.get(context, this.widget.novel);
    loadcache();
    //gotoreadsign();
    refresh();
  }

  loadcache() async {
    //缓存
    remotedata = await Chapter.getcatecache(context, this.widget.novel);
    refresh();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  var h = 90.0;
  late Widget tmptitle;
  late Widget drag;
  initool() {
    tmptitle = Container(
        decoration: BoxDecoration(
            color: Styles.getTheme()['barcolor'],
            boxShadow: Styles.borderShadow),
        height: h,
        padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 5, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 15,
              ),
              widget.novel.type == '3'
                  ? getbookbg2(60, 60 * 1.3)
                  : Container(
                      width: 50,
                      child: widget.novel.imgdom,
                    ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: Text(
                  widget.novel.name,
                  overflow: TextOverflow.clip,
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Styles.getTheme()['catenomal']),
                ),
              )
            ]));
    initdrag();
  }

  initdrag() {
    drag = DraggableScrollbar.arrows(
      backgroundColor: Colors.grey,
      controller: scrollController,
      heightScrollThumb: 35.0,
      child: bookCardWithInfo() as BoxScrollView,
    );
  }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);

    if (!isnull(remotedata.length)) {
      return SizedBox();
    }

    var body = Container(
      height: getScreenHeight(context) - h,
      width: getScreenWidth(context),
      color: Styles.getTheme()['barcolor'],
      child: widget.novel.type == '3'
          ? drag
          : RefreshIndicator(
              // ignore: missing_return
              onRefresh: gethttpdata,
              child: drag),
    );
    getpostion();
    // scrollController = new ScrollController(initialScrollOffset: goread);

    // initdrag();
    var b = Stack(
      children: <Widget>[
        Positioned(
          child: body,
          top: h,
          right: 0,
          left: 0,
        ),
        Positioned(
          child: tmptitle,
          top: 0,
          right: 0,
          left: 0,
        ),
      ],
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: b,
    );
  }

  getbookbg2(double w, double h) {
    // double h = width / 0.75;
    var width = w;
    // double h = h;
    var img = Image.asset('assets/images/bookbg.jpg',
        width: width, height: h, fit: BoxFit.fill);
    return Container(
      width: width,
      height: h,
      child: Stack(children: [
        img,
        Positioned(
          top: h * 0.6,
          width: width,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Center(
                  child: Text(widget.novel.name,
                      overflow: TextOverflow.clip,
                      style: TextStyle(color: Colors.blue, fontSize: 10),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl))),
        ),
      ]),
    );
  }

  Widget bookCardWithInfo() {
    return ListView.builder(
      //reverse: true,
      controller: scrollController,
      scrollDirection: Axis.vertical,
      cacheExtent: 30.0,
      padding: new EdgeInsets.all(5.0),
      itemExtent: 51.0,
      itemCount: isnull(remotedata) ? remotedata.length : 0,
      itemBuilder: (BuildContext context, int index) {
        var chapter = Chapter.fromJson(remotedata[index], index + 1);
        return Container(
          color: Styles.getTheme()['barcolor'],
          padding: EdgeInsets.only(left: 18),
          child: Column(
            children: <Widget>[
              Divider(
                height: 1,
                color: SQColor.lightGray,
              ),
              Expanded(
                child: Container(
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      chapter.click();
                      gotoreadsign();

                      widget.clickChapter(chapter);
                      refresh();
                    }, //显示目录
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                                fontSize: 14,
                                color: chapter.isSignHere()
                                    ? Styles.getTheme()['cateon']
                                    : !chapter.isclick()
                                        ? Styles.getTheme()['catenomal']
                                        : Styles.getTheme()['cateover']),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        widget.novel.type == "3"
                            ? SizedBox()
                            : chapter.isfree != '0'
                                ? chapter.ispay != '1'
                                    ? Icon(
                                        Icons.lock,
                                        color: Styles.getTheme()['catenomal'],
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.lock_open,
                                        color: Styles.getTheme()['catenomal'],
                                        size: 20,
                                      )
                                : SizedBox(),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
