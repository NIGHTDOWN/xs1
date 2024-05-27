import 'package:flutter/material.dart';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:ng169/tool/loadbox.dart';

class CataLog extends StatefulWidget {
  final Novel novel;
  const CataLog({Key? key, required this.novel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CataLogState();
}

class CataLogState extends State<CataLog> {
  List remotedata = [];

  ScrollController scrollController = new ScrollController();
  // final key = GlobalKey<LoadboxState>();
  double goread = 0.0;
  //跳转到阅读指针的位置
  late String readid;
  gotoreadsign() {
    getpostion();
    if (scrollController.hasClients && remotedata.length > 0) {
      scrollController.jumpTo(goread);
    }
  }

  void getpostion() {
    readid = Chapter.getReadSecId(this.widget.novel.id, this.widget.novel.type);
    double lines = getScreenHeight(context) / 51 - 3;
    double hafelines = lines / 2;
    var h = getScreenHeight(context) - (51 * hafelines);
    double tmp = int.parse(readid) * 51.0;
    if (h > tmp) {
      goread = 0;
    } else {
      //到最后一页的时候滚动页面不能超过半屏
      // if(readid)
      // var s=h/51;
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
  }

  Future<void> gethttpdata() async {
    remotedata = await Chapter.gethttp(context, this.widget.novel);
    gotoreadsign();
    refresh();
  }

  loadpage() {
    remotedata = Chapter.get(context, this.widget.novel);
    loadcache();
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

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    // if (!isnull(remotedata.length)) {
    //   return Scaffold();
    // }
    getpostion();
    var drag;
    scrollController = new ScrollController(initialScrollOffset: goread);
    if (!isnull(remotedata)) {
      drag = Loadbox(
        // key: this.key,
        loading: true,
        color: SQColor.primary,
        bgColor: SQColor.gray,
        width: 80,
        height: 80,
        opacity: 0.0,
        child: Container(
          height: getScreenHeight(context),
          width: getScreenWidth(context),
          color: SQColor.white,
          child: SizedBox(
            height: getScreenHeight(context),
            width: getScreenWidth(context),
            child: Text(''),
          ),
        ),
      );
    } else {
      drag = DraggableScrollbar.arrows(
        backgroundColor: Colors.grey,
        controller: scrollController,
        heightScrollThumb: 35.0,
        child: bookCardWithInfo() as BoxScrollView,
      );
    }

    var body = Container(
      child: RefreshIndicator(onRefresh: gethttpdata, child: drag),
    );
    return Scaffold(
      appBar: AppBar(title: Text(lang("全部目录")), actions: [
        Center(
            child: GestureDetector(
          child: Container(
            margin: EdgeInsets.only(top: 6, right: 10),
            child: Icon(Icons.refresh),
          ),
          onTap: gethttpdata,
        ))
      ]),
      backgroundColor: SQColor.white,
      body: body,
    );
  }

  Widget bookCardWithInfo() {
    return new ListView.builder(
      //reverse: true,
      controller: scrollController,
      scrollDirection: Axis.vertical,
      cacheExtent: 30.0,
      padding: new EdgeInsets.all(5.0),
      itemExtent: 51.0,
      itemCount: isnull(remotedata) ? remotedata.length : 0,
      itemBuilder: (BuildContext context, int index) {
        var chapter = Chapter.fromJson(remotedata[index], index);
        return Container(
          color: SQColor.white,
          padding: EdgeInsets.only(left: 18),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 50,
                  child: GestureDetector(
                    onTap: () async {
                      chapter.click();
                      gotoreadsign();

                      await this.widget.novel.read(context, chapter.id);

                      loadpage();
                      refresh();
                    }, //显示目录
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                                fontSize: 14,
                                color: chapter.isSignHere()
                                    ? Colors.orange[200]
                                    : !chapter.isclick()
                                        ? Colors.black
                                        : SQColor.gray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        chapter.isfree != '0'
                            ? chapter.ispay != '1'
                                ? Icon(
                                    Icons.lock,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.lock_open,
                                    size: 20,
                                  )
                            : SizedBox(),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: SQColor.lightGray,
              ),
            ],
          ),
        );
      },
    );
  }
}
