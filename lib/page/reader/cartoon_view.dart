import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/article.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/novel_detail/novel_detail_header.dart';

import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';
import 'reader_utils.dart';

// ignore: must_be_immutable
class CartoonView extends StatefulWidget {
  late Article article;
late int page;
late Function lock;
late Function unlock;
late bool islock;
late double topSafeHeight;
late Novel novel;
late Function scroll;
late Function showmenu;
late Function next;
late Function pre;
 
  CartoonView(
      {required this.novel,
      required this.article,
      required this.page,
      required this.topSafeHeight,
      required this.scroll,
      required this.next,
      required this.pre,
      required this.lock,
      required this.islock,
      required this.unlock,
      required this.showmenu});

  @override
  CartoonViewState createState() => CartoonViewState();
}

class CartoonViewState extends State<CartoonView> {
  List<Widget> pics = [];
  List<String> loading = [
    'assets/images/loading/1.png',
    'assets/images/loading/2.png',
    'assets/images/loading/3.png',
    'assets/images/loading/4.png',
    'assets/images/loading/5.png',
  ];
  late double width;
 late PageController pageController;
 late double height;
 late Widget loadanmianl;
 late Widget loadimg;
  int locktime = 0;
  bool lock = false, lastpagelock = false;
  late int pageindex;
  @override
  void initState() {
    super.initState();

    loadanmianl = FrameAnimationImage(
      width: g('swidth'),
      height: g('sheight'),
      picwidth: 100,
      interval: 200, imageList: [], bgcolor: Color.fromARGB(0, 0, 0, 0),
    );
    pageindex = widget.page;

    loadimg = FrameAnimationImage(
      imageList: loading,
      width: g('swidth'),
      // height: g('sheight'),
      picwidth: 50,
      interval: 200, bgcolor: Color.fromARGB(0, 0, 0, 0),
    );
    init();
  }

  init() {
    pageController = PageController(keepPage: false, initialPage: 0);

    if (isnull(widget.scroll)) {
      pageController.addListener(() {
        _scroll();
      });
    }
    goindex();
  }

  onTap(Offset position) async {
    //点击翻页或者弹出菜单

    //hidetitlebar();
    double xRate = position.dy / Screen.height;
    var of = 0.0;
    var time = 100;
    var h = g('sheight') / 2;
    double goh = 0;
    if ((xRate > 0.33 && xRate < 0.66)) {
      //显示菜单
      // isMenuVisiable = true;
      // s('isMenuVisiable', true);
      // reflash();
      widget.showmenu();
    } else if (xRate >= 0.66) {
      //下一页
      of = pageController.offset;
      if (of > pageController.position.maxScrollExtent) {
        return;
      }
      if (of == pageController.position.maxScrollExtent) {
        pageController.animateTo(of + h,
            duration: Duration(milliseconds: time), curve: Curves.easeInOut);
        return;
      }
      goh = of + h;
      if (goh > pageController.position.maxScrollExtent) {
        pageController.animateTo(pageController.position.maxScrollExtent,
            duration: Duration(milliseconds: time), curve: Curves.easeInOut);
        return;
      }

      //如果当前是已经底部则可以继续下滑
      pageController.animateTo(goh,
          duration: Duration(milliseconds: time), curve: Curves.easeInOut);
      // pageController.animateToPage(2,
      //     duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    } else {
      //上一页
      of = pageController.offset;
      goh = of - h;
      if (of < 0) {
        return;
      }
      if (of == 0) {
        pageController.animateTo(-(h / 3),
            duration: Duration(milliseconds: time), curve: Curves.easeInOut);
        return;
      }
      if (goh < 0) {
        pageController.animateTo(0,
            duration: Duration(milliseconds: time), curve: Curves.easeInOut);
        return;
      }
      pageController.animateTo(goh,
          duration: Duration(milliseconds: time), curve: Curves.easeInOut);
    }
  }

  //防止页面高度还没加载完成，加载上一页尾部又立马跳转到下一页
  bool check() {
    var now = int.parse(gettime());
//4秒内禁止切换下一页
    if ((now - locktime) > 4) {
      locktime = int.parse(gettime());
      return true;
    } else {
      return false;
    }
  }

  _scroll() async {
    if (lock) {
      return;
    }
    if (!widget.article.cartoonisinit) {
      //初始化完成之后在去回调；
      //内容长度不满一屏的补监听
      if (widget.islock) {
        //滚动后停止滚动监听
        return;
      }
      if (widget.article.cartoonisinit) {
        //加载未完成停止监听
        return;
      }
      if (!pageController.hasClients) {
        //滚动后停止滚动监听
        return;
      }
      if (pageController.position.maxScrollExtent <= g('sheight')) {
        //滚动后停止滚动监听
        return;
      }
      if (!widget.article.pay) {
        return;
      }
      var offseth = g('sheight') * 0.1;
      widget.scroll(pageController);

      if (pageController.position.pixels >
          (pageController.position.maxScrollExtent + offseth)) {
        if (isnull(widget.article.nextArticleId) && check()) {
          lock = true;
          widget.lock();
          reflash();
          await widget.next();
          pageindex = 0;
          reflash();
        }
        return;
      }
      if (pageController.position.pixels <= (0.0 - offseth)) {
        if (isnull(widget.article.preArticleId) && check()) {
          lock = true;
          widget.lock();
          reflash();
          await widget.pre();
          pageindex = widget.article.pageCount - 1;
          reflash();
        } else {
          // show(context, lang('已经是第一页了'));
        }
        return;
      }
    }
    // golastpage();
  }

  // golastpage() async {
  //   if (lastpagelock) {
  //     return;
  //   }
  //   if (!widget.article.pay) {
  //     return;
  //   }
  //   if (!isnull(pageController.hasClients)) {
  //     return;
  //   }
  //   if (pageController.position.pixels <
  //       (pageController.position.maxScrollExtent)) {
  //     return;
  //   }
  //   lastpagelock = true;

  //   if (!isnull(widget.article.nextArticleId) && pageController.position.pixels >
  //       (pageController.position.maxScrollExtent+10)) {
  //     //这里滑动过去
  //      Future.delayed(Duration(milliseconds: 200)).then((e) async {
  //     // setState(() {
  //     //   indexs.add(indexs.length + 1);
  //     // });
  //     await gourl(context, Lastpage(widget.novel));
  //     lastpagelock = false;
  //     reflash();
  //   });

  //   }
  // }

  Widget _buildProgressIndicator() {
    if (!widget.article.pay) {
      return SizedBox();
    }
    if (!isnull(pageController.hasClients)) {
      return SizedBox();
    }
    if (pageController.position.pixels <
        (pageController.position.maxScrollExtent)) {
      return SizedBox();
    }
    if (!isnull(widget.article.nextArticleId)) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 9,
              height: 28,
            ),
            Text(
              lang('已经看完了'),
            ),
            SizedBox(
              width: 9,
              height: 28,
            ),
          ],
        ),
      );
    }
    // var circular = new CircularProgressIndicator(
    //   backgroundColor: Colors.white,
    //   strokeWidth: 5.0,
    //   valueColor: AlwaysStoppedAnimation(Colors.green[200]),
    // );
    var circular = Icon(
      Icons.arrow_downward,
      size: 17,
    );
    var box = SizedBox(
      width: 17,
      height: 17,
      child: circular,
    );
    var kongbai = Expanded(child: SizedBox());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          kongbai,
          box,
          SizedBox(
            width: 9,
            height: 28,
          ),
          Text(
            lang('上拉加载下一章'),
          ),
          kongbai
        ],
      ),
    );
  }

  Widget _buildtopIndicator() {
    if (!widget.article.pay) {
      return SizedBox();
    }
    if (!isnull(pageController.hasClients)) {
      return SizedBox();
    }
    if (pageController.position.pixels >= 0) {
      return SizedBox();
    }
    if (!isnull(widget.article.preArticleId)) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 9,
              height: 28,
            ),
            Text(
              lang('没有上一章'),
            ),
            SizedBox(
              width: 9,
              height: 28,
            ),
          ],
        ),
      );
    }
    // var circular = new CircularProgressIndicator(
    //   backgroundColor: Colors.white,
    //   strokeWidth: 5.0,
    //   valueColor: AlwaysStoppedAnimation(Colors.green[200]),
    // );
    var circular = Icon(
      Icons.arrow_upward,
      size: 17,
    );
    var box = SizedBox(
      width: 17,
      height: 17,
      child: circular,
    );
    var kongbai = Expanded(child: SizedBox());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          kongbai,
          box,
          SizedBox(
            width: 9,
            height: 28,
          ),
          Text(
            lang('下拉返回上一章'),
          ),
          kongbai
        ],
      ),
    );
  }

  goindex() async {
    //计算所有图片高度和
    lock = true;
    locktime = int.parse(gettime());
    await Future.delayed(Duration(milliseconds: 500)).then((data) async {
      if (!isnull(pageController.hasClients)) {
        //获取页面高度失败,持续等待加载完成，
        goindex();
        return;
      } else {
        var max = pageController.position.maxScrollExtent;

        // await Future.delayed(Duration(milliseconds: 500));
        var pagemax = max - 48;
        if (pageindex >= widget.article.pageCount - 1) {
          pageController.jumpTo(pagemax);
        } else {
          if (pageindex <= 1) {
            pageController.jumpTo(0);
          } else {
            var rate = (pageindex + 1) / widget.article.pageCount;
            var pooint = max * rate;
            if (pooint > pagemax) {
              pageController.jumpTo(pagemax);
            } else {
              pageController.jumpTo(pooint);
            }
          }
        }
        lock = false;
        widget.article.cartoonisinit = false;
        widget.unlock();
        reflash();
        // });
      }
      return;
    });
  }

  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = g('swidth');
    height = g('sheight');
    pics = [];
    getpic();

    if (widget.article.cartoonisinit) {
      goindex();
    }
    //显示购买页面
    var s = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        page(),
        payitem(context),
        widget.article.cartoonisinit ? loadanmianl : Container()
      ],
    );

    return s;
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  loadwidget() {
    return loadimg;
  }

  getpic() {
    //顶部防止遮挡
    pics.add(SizedBox(height: 18));
    pics.add(_buildtopIndicator());
    // d(widget.article.pay);
    if (widget.article.pay) {
      widget.article.images.forEach((pic) {
        pics.add(NgImage(pic['url'],
            width: width,
            //height: height,
            placeholder: loadwidget(),
            dsl: widget.article.dsl));
      });
    } else {
      // d(widget.article.dsl);
      widget.article.imagestmp.forEach((pic) {
        pics.add(NgImage(pic['url'],
            width: width,
            //height: height,
            placeholder: loadwidget(),
            dsl: widget.article.dsl));
      });
    }
    pics.add(_buildProgressIndicator());
  }

  Widget page() {
    if (!isnull(widget.article)) return Container();
    return GestureDetector(
        onTapUp: (TapUpDetails details) {
          onTap(details.globalPosition);
        },
        child: ListView(
          physics: BouncingScrollPhysics(),
          controller: pageController,
          children: pics,
        ));
    //SingleChildScrollView 数量多性能不好；
    // return SingleChildScrollView(
    //     physics: BouncingScrollPhysics(),
    //     controller: pageController,
    //     child: Column(
    //       children: pics,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //     ));
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
            // image: new DecorationImage(
            //     fit: BoxFit.cover, image: AssetImage(Styles.getTheme()['bg'])),
            color: Styles.getTheme()['barcolor'],
            boxShadow: Styles.borderShadow),
        //color: Colors.white,

        padding: EdgeInsets.fromLTRB(15, 0, 10, ReaderUtils.bottomOffset),
        // margin: EdgeInsets.only(left:),
        child: child);

    return Positioned(left: 0, right: 0, bottom: 0, child: child);
  }

  Widget unlockbtn(context) {
    return Expanded(
      child: TextButton(
        onPressed: () async {
          // bool b = await widget.article.unlock(context); //解锁逻辑完成需要重载
          // if (b) {
          //   eventBus.emit('read_reflash', '');
          // }\
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
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Styles.getTheme()['activecolor'];
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Styles.getTheme()['activefontcolor'];
          }),
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8));
          }),
        ),
      ),
    );
  }

  unlockbook() async {
    bool b = await widget.article.unlock(context); //解锁逻辑完成需要重载
    // if (b) {
    eventBus.emit('read_reflash', '');
    // }
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
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Styles.getTheme()['activecolor'];
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return Styles.getTheme()['activefontcolor'];
          }),
          shape: WidgetStateProperty.resolveWith((states) {
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
    //未支付的显示截取部分
    if (article.pay) {
      content = article.stringAtPageIndex(page);
    } else {
      content = article.contenttmp;
    }

    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.fromLTRB(
          15, widget.topSafeHeight + ReaderUtils.topOffset, 10, 0),
      //  margin: EdgeInsets.fromLTRB(15, topSafeHeight + ReaderUtils.topOffset, 10,
      // Screen.bottomSafeHeight + ReaderUtils.bottomOffset),
      // child: Text(content,
      //     style: TextStyle(
      //         color: Styles.getTheme()['fontcolor'],
      //         fontSize: fixedFontSize(Styles.getTheme()['fontsize']))));
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: content,
              style: TextStyle(
                  color: Styles.getTheme()['fontcolor'],
                  // height: 1.2,
                  fontSize: fixedFontSize(Styles.getTheme()['fontsize']))),
        ]),
        textAlign: TextAlign.left,
      ),
    );
  }
}
