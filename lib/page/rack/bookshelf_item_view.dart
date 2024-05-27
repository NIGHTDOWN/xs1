import 'package:flutter/material.dart';

import 'package:ng169/obj/novel.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/brige.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';

class BookshelfItemView extends StatefulWidget {
  final Novel novel;

  BookshelfItemView(this.novel);

  @override
  _BookshelfItemViewState createState() => _BookshelfItemViewState();
}

class _BookshelfItemViewState extends State<BookshelfItemView> {
  late Novel novel;
  // BookshelfItemView(this.novel);
  bool ischoose = false;

  static Widget onimg = SizedBox();
  static Widget unimg = SizedBox();
  var p, pedit, pfun, pclickonebook;
  late int pall;
  var width;

  @override
  void initState() {
    if (!isnull(onimg)) {
      onimg = Image.asset('assets/images/choose_click.png');
    }
    if (!isnull(unimg)) {
      unimg = Image.asset('assets/images/choose_unclick.png');
    }
    super.initState();
  }

  getbookbg() {
    double h = width / 0.75;
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
                  child: Text(novel.name,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl))),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    novel = this.widget.novel;

    width = (Screen.width - 15 * 2 - 24 * 2) / 3;
    p = NgBrige.of(context);
    pedit = p.data['isedit'];
    pfun = p.fun['chooseone'];
    pclickonebook = p.fun['clickonebook'];

    pall = p.data['chooseall'];
    var zhezao = Positioned(
      top: 0,
      child: new Container(
        color: Colors.black.withOpacity(pedit ? 0.2 : 0),
        // color: Color(0x90000000),
        width: width,
        height: width / 0.75,
      ),
    );
    if (!pedit) {
      ischoose = false;
    }
    if (pedit) {
      if (pall == 2) {
        editbook(true, true);
      }
      if (pall == 0) {
        editbook(true, false);
      }
    }
    var chooseimg = pedit
        ? Positioned(
            bottom: 4,
            right: 4,
            width: width / 4.2,
            child: ischoose && pedit ? onimg : unimg)
        : Container();
    return GestureDetector(
      onTap: () {
        // d(p.data);
        // d(p.fun);
        if (pedit) {
          //编辑
          editbook();
        } else {
          //阅读
          openbook();
        }
        // var fun = p.fun['chooseone'];
        // fun(novel.id.toString(), novel.type);
        //AppNavigator.pushNovelDetail(context, novel);
      },
      child: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              child: Stack(children: <Widget>[
                Positioned(
                  // top:0,
                  child: this.widget.novel.type == '3'
                      ? getbookbg()
                      : NgImage(
                          this.widget.novel.imgUrl,
                          width: width,
                          height: width / 0.75,
                          fit: BoxFit.fill,
                          placeholder: Container(),
                        ),
                ),
                getnum(),
                zhezao,
                chooseimg
              ]),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: Color(0x22000000), blurRadius: 5)
              ]),
            ),
            SizedBox(height: 10),
            Text(novel.name,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  getnum() {
    if (pedit) {
      return Container();
    }

    if (!isnull(widget.novel.upsecnum)) {
      return Container();
    }
    if (widget.novel.upsecnum < 1) {
      return Container();
    }
    Color c3 = SQColor.white;

    var s = width / 7;
    var con = Container(
        width: s * 1.5,
        height: s,
        // margin: EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.only(right: 2, left: 2),
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            // begin: Alignment.topCenter,
            // end: Alignment.bottomCenter,
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: <Color>[
              Color(0xffe94034),
              Color(0xfff45d36),
              Color(0xfffc7437)
            ],
          ),
          // color: c,
          borderRadius:
              new BorderRadius.only(bottomLeft: new Radius.circular(5.0)),
        ),
        child: Center(
          child: Text(widget.novel.upsecnum.toString(),
              // child: Text('199',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 10, color: c3, fontWeight: FontWeight.w500)),
        ));
    return Positioned(child: con, right: 0, top: 0);
  }

  openbook() {
    // gourl(context, NovelDetailScene(novel));
    widget.novel.read(context, widget.novel.readChapter);
  }

  editbook([bool? isset, bool? isadd]) {
    if (isnull(isset)) {
      // 全选时候的操作
      ischoose = isadd!;
      pfun(novel, isadd); //全局设置
    } else {
      //点击某一个的操作
      pclickonebook();
      ischoose = !ischoose;
      pfun(novel, ischoose); //本控件设置
    }
  }

  reflesh() {
    setState(() {});
  }
}
