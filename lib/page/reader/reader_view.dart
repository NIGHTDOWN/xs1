import 'package:css_text/css_text.dart';
import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';
import 'package:ng169/page/reader/reader_page_agent.dart';
import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

import 'battery_view.dart';
import 'reader_overlayer.dart';
import 'reader_utils.dart';

class ReaderView extends StatefulWidget {
  final Article article;
  final int page;
  final double topSafeHeight;
  final Novel novel;
  final Widget battery;
  ReaderView(
      {this.novel, this.article, this.page, this.topSafeHeight, this.battery});

  @override
  ReaderViewState createState() => ReaderViewState();
}

class ReaderViewState extends State<ReaderView> {
  // final Article article;
  // final int page;
  // final double topSafeHeight;
  // final Novel novel;

  // ReaderView({this.novel, this.article, this.page, this.topSafeHeight});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //显示购买页面
    return Stack(
      children: <Widget>[
        Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(Styles.getTheme()['bg'], fit: BoxFit.cover)),
        SingleChildScrollView(
          // physics: ScrollPhysics.,
          child: buildContent(widget.article, widget.page),
        ),
        ReaderOverlayer(
            article: widget.article,
            page: widget.page,
            battery: widget.battery,
            topSafeHeight: widget.topSafeHeight),
        payitem(context)
      ],
    );
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget payitem(context) {
    if (widget.article.pay) {
      return Container();
    }
    var line = Container(
      height: 1,
      width: getScreenWidth(context),
      color: Styles.getTheme()['cateover'],
    );
    var topmargin = Container(
      height: 15,
    );
    var need = widget.article.coin.toString();
    double have = User.getcoin();
    double canpay = (have) - double.parse(need);
    bool bools = canpay >= 0 ? true : false;
    TextStyle style = TextStyle(color: Styles.getTheme()['cateover']);

    bool _autolock = isnull(getcache(autounlock)) ? true : false;
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        //书籍标题
        topmargin,
        Text(
          widget.novel.name.toString(),
          style: style,
        ),
        topmargin,
        line,
        topmargin,
        Row(children: <Widget>[
          Text(
            lang('本章价格') + ':',
            style: style,
          ),
          Text(
            need,
            style: style,
          ),
          SizedBox(width: 2),
          Image.asset(
            'assets/images/bean.png',
            width: 15,
          )
        ]),
        topmargin,
        Row(children: <Widget>[
          Text(
            lang('账号余额') + ':',
            style: style,
          ),
          Text(
            have.toString(),
            style: style,
          ),
          SizedBox(width: 2),
          Image.asset(
            'assets/images/bean.png',
            width: 15,
          ),
        ]),
        //这里显示自动解锁按钮或者提示余额不足
        topmargin,
        bools
            ? Row(children: <Widget>[
                SizedBox(
                    width: 25,
                    height: 25,
                    child: Stack(children: [
                      Radio(
                        value: true,
                        groupValue: _autolock,
                        activeColor: Styles.getTheme()['activecolor'],
                        onChanged: (v) {},
                      ),
                      InkWell(
                          onTap: () {
                            _autolock = !_autolock;
                            setcache(autounlock, _autolock, '-1');
                            reflash();
                          },
                          child: Container(
                            width: 25,
                            height: 25,
                          )),
                    ])),
                Text(
                  lang('自动解锁，不在提示') + '。',
                  style: style,
                ),
              ])
            : Text(
                lang('余额不足请充值'),
                style: style,
              ),
        topmargin,
        Row(children: <Widget>[
          bools ? unlockbtn(context) : paybtn(context),
        ]),
      ],
    );
    child = Container(
      decoration: BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover, image: AssetImage(Styles.getTheme()['bg'])),
          boxShadow: Styles.borderShadow),
      //color: Colors.white,

      padding: EdgeInsets.fromLTRB(15, 0, 10, ReaderUtils.bottomOffset),
      // margin: EdgeInsets.only(left:),
      child: child,
    );

    return Positioned(left: 0, right: 0, bottom: 0, child: child);
  }

  unlockbook() async {
    bool b = await widget.article.unlock(context); //解锁逻辑完成需要重载

    // if (b) {
    eventBus.emit('read_reflash', '');
    // }
  }

  Widget unlockbtn(context) {
    return Expanded(
      child: TextButton(
        onPressed: () async {
          await unlockbook();
        },
        child: Container(
          child: Text(
            lang('解锁本章节'),
            style: TextStyle(fontSize: 15),
          ),
          margin: EdgeInsets.all(5),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return Styles.getTheme()['activecolor'];
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return Styles.getTheme()['activefontcolor'];
          }),
          shape: MaterialStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8));
          }),
        ),
      ),
    );
  }

  Widget paybtn(context) {
    return Expanded(
      child: TextButton(
        onPressed: () async {
          await gourl(
              context,
              Recharge(widget.article.book_id, widget.article.booktype,
                  widget.article.id.toString()));
          //如余额大于 就可以解锁
          if (User.getcoin() > widget.article.coin) {
            await unlockbook();
          }
        },
        child: Container(
          child: Text(
            lang('立即充值'),
            style: TextStyle(fontSize: 15),
          ),
          margin: EdgeInsets.all(5),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return Styles.getTheme()['activecolor'];
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            return Styles.getTheme()['activefontcolor'];
          }),
          shape: MaterialStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8));
          }),
        ),
      ),
    );
  }

  buildContent(Article article, int page) {
    String content;
    if (!isnull(article)) return Container();
    var testobj;
    //未支付的显示截取部分
    if (article.pay) {
      content = article.stringAtPageIndex(page);
      //如果是已经支付的分页内容直接获取分割后的内容；间隔符按照已经存在的
      testobj = Text.rich(
        // TextSpan(
        //   children: ReaderPageAgent.gettextwidget(content),
        // ),
        TextSpan(text: content, style: ReaderPageAgent.getstyle()),
        textAlign: TextAlign.left,
      );
    } else {
      content = article.contenttmp;
      //如果是未支付需要获取分割字符串后的widget

      testobj = Text.rich(
        TextSpan(
          children: ReaderPageAgent.gettextwidget(content),
        ),
      );
    }

    return Container(
      // color: Colors.transparent,
      // color: Colors.green[200],
      // width: ReaderPageAgent.getwidth(),
      // height: ReaderPageAgent.getHeight(),
      // height: 491.40000000000003,
      margin: EdgeInsets.fromLTRB(
          15, widget.topSafeHeight + ReaderUtils.topOffset, 10, 0),
      child: testobj,
    );
  }
}
