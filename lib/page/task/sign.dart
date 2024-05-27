import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/commect/kefu.dart';
import 'package:ng169/page/commect/markbook.dart';
import 'package:ng169/page/novel_detail/novel_detail_scene.dart';
import 'package:ng169/page/recharge/recharge.dart';

import 'package:ng169/page/user/edit_user.dart';

import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';
import 'package:ng169/tool/t.dart';

import 'package:ng169/tool/url.dart';
import 'package:ng169/tool/Jsq.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'calendar.dart';
import 'friend.dart';

class Sign extends LoginBase {
  bool needlogin = true;
  String title = '签到中心';
  List<Widget> more = [SizedBox()];
  bool debug = false, showad = false;
  var cachedata = 'sign_data_', cachedatatime = 'sign_data_time_', page = 1;
  var prolist;
  var bsqignnum;
  String api = 'user/get_signday';
  String api2 = 'task/init';
  var topcolor;
  var textstyle;
  var textstyle2;
  var textsignstyle;
  var taskdata;
  var taskdatacachename = 'taskdatacachename';
  bool todaypay = false;
  double barheight = 600;
  double topheight = 140;
  var objw;
  var choose, maozhua, maozhua2;
  bool payok = false, cansign = true;
  var bean = SizedBox(
    //width: 5,
    child: Image.asset('assets/images/bean.png', width: 18),
  );
  var year, month, today, chooseday, info, havebook;
  Future<void> gethttpdata() async {
    var tmp = await http(api, null, gethead());
    var data2 = getdata(context, tmp);
    if (isnull(data2)) {
      prolist = data2['sgin'];
      bsqignnum = data2['num'];
      setcache(cachedata, data2, '-1');
      setcache(cachedatatime, 1, '3600');
      info = prolist[chooseday - 1];
      reflash();
    }
  }

  checkhavebook() async {
    havebook = await T('book').where({'type': '3'}).getone();
  }

  loadtaskcache() {
    taskdata = getcache(taskdatacachename);
  }

  inittask() async {
    var tmp = await http(api2, null, gethead());

    var data2 = getdata(context, tmp);
    if (isnull(data2)) {
      taskdata = data2;
      // reflash();
      setcache(taskdatacachename, taskdata, '86400');
    }
    var tmp2 = await http('task/gettodaypay', null, gethead());
    var data3 = getdata(context, tmp2);
    if (isnull(data3)) {
      todaypay = isnull(data3) ? true : false;
    }
    reflash();
  }

  @override
  void initState() {
    super.initState();
    checkhavebook();
    info = [];
    DateTime nowDay = new DateTime.now();
    year = nowDay.year;
    month = nowDay.month;
    today = nowDay.day;
    taskdatacachename = taskdatacachename +
        year.toString() +
        month.toString() +
        today.toString();
    chooseday = today; //默认选择当日
    titlebarcolor(true);
    barheight = Screen.navigationBarHeight;
    loadtaskcache();
    inittask();
    topcolor = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-0.5, 1.0),
        end: Alignment(-0.2, -1.0),
        colors: [SQColor.primary4, SQColor.primary], // whitish to gray
      ),
    );
    textstyle = TextStyle(
        fontSize: 13, fontWeight: FontWeight.w400, color: SQColor.white);
    textstyle2 = TextStyle(
        fontSize: 15, fontWeight: FontWeight.w400, color: SQColor.white);
    textsignstyle = TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700, color: SQColor.white);

    loadpage();
    objw = (getScreenWidth(g('context')) - 20) / 7;
    var de = new BoxDecoration(
      color: SQColor.white,
      borderRadius: new BorderRadius.circular(50), // 圆角度
      border: new Border.all(color: SQColor.primary2, width: 1),
    );
    choose = Container(
      decoration: de,
      width: 40,
      height: 40,
    );
    maozhua = Container(
      child: Image.asset(
        'assets/images/zhua.png',
        color: const Color.fromARGB(203, 249, 157, 165),
      ),
      width: 20,
      height: 20,
    );
    maozhua2 = Container(
      child: Image.asset(
        'assets/images/zhua.png',
        color: const Color.fromARGB(203, 249, 157, 165),
      ),
      width: 25,
      height: 25,
    );
    if (isnull(prolist)) {
      info = prolist[chooseday - 1];
    }
    gethttpdata();
  }

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    var tmp = getcache(cachedata);
    // gethttpdata();
    if (!isnull(tmp)) {
      await gethttpdata();
      return;
    }
    prolist = tmp['sgin'];
    bsqignnum = tmp['num'];

    if (!isnull(getcache(cachedatatime))) {
      await gethttpdata();
    }
  }

  // refresh() {
  //   setState(() {});
  // }

  Widget buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Container(
          //width: 44,
          //color: topcolor,
          height: Screen.navigationBarHeight,
          padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 5, 0),
          child: Row(children: [
            SizedBox(
              width: 5,
            ),
            GestureDetector(
                onTap: back,
                child: Icon(
                  Icons.arrow_back,
                  color: SQColor.white,
                )),
            Expanded(
                child: Center(
                    child: Text(
              lang(title),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: SQColor.white),
            ))),
            SizedBox(
              width: 30,
            ),
          ]),
        ),
      ],
    );
  }

  back() {
    pop(context);
  }

  gt(String str) {
    return Text(
      str,
      style: textstyle,
    );
  }

  gt2(String str) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          str,
          style: textstyle2,
        ));
  }

  gt3(String str) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          str,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: SQColor.white),
        ));
  }

  showcai(String title, var coin) {
    var body = Container(
      width: 300,
      height: 300,
      child: Stack(children: [
        Image.asset('assets/images/tcbg.png'),
        Positioned(
            child: Center(
              child: Text(title,
                  style: TextStyle(
                    shadows: [
                      BoxShadow(
                          color: SQColor.white,
                          offset: Offset(1.0, 1.0),
                          blurRadius: 6.0,
                          spreadRadius: 6.0)
                    ],
                    decoration: TextDecoration.none,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: SQColor.white,
                  )),
            ),
            top: 50,
            width: 300),
        Positioned(
            top: 120,
            width: 300,
            height: 140,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Image.asset(
                'assets/images/bean.png',
                width: 50,
              ),
              Text(
                '+' + coin.toString() + lang('金豆'),
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: Colors.black45,
                ),
              ),
              TextButton(
                onPressed: () {
                  pop(context);
                },
                child: Text(lang("确定")),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return SQColor.primary;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return SQColor.white;
                  }),
                  shape: WidgetStateProperty.resolveWith((states) {
                    return RoundedRectangleBorder(
                        side: BorderSide(
                          color: SQColor.primary2,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8));
                  }),
                ),
              )
            ]))
      ]),
    );
    showbox(body, Color(0x00ffffff));
  }

  httpsign() async {
    var signda = info['sign_day'];
    var signapi = 'user/sign';

    var data = await http(signapi, {'day': signda}, gethead());
    var tmpdata = getdata(context, data);
    if (isnull(tmpdata)) {
      //弹窗
      //刷新

      User.addcoin(tmpdata);
      showcai(lang('奖励到账'), tmpdata);
      gethttpdata();
    }
  }

//回去左边按钮
  gright() {
    var tmpdee = new BoxDecoration(
      //borderRadius: new BorderRadius.circular(50), // 圆角度

      shape: BoxShape.circle,
      border: new Border.all(
          color: Color.fromARGB(213, 231, 213, 215), width: 10), // 边色与边宽度
// 生成俩层阴影，一层绿，一层黄， 阴影位置由offset决定,阴影模糊层度由blurRadius大小决定（大就更透明更扩散），阴影模糊大小由spreadRadius决定
      boxShadow: [
        BoxShadow(color: SQColor.primary, blurRadius: 3.0, spreadRadius: 7.0),
      ],
    );
    //签到按钮（显示联系签到天数）
    //补签按钮（显示补签天数）
    //未到时间的，签到按钮灰色

    if (isnull(info['issign'])) {
      //已经签到
      cansign = false;
    } else {
      cansign = true;
    }
    if (int.parse(info['sign_day']) > today) {
      cansign = false;
    }

    if (isnull(info)) {
      var num;
      if (isnull(info['issign'])) {
        num = info['num'];
      } else {
        var tmpnum = chooseday - 2;
        num = prolist[tmpnum >= 0 ? tmpnum : 0]['num'];
      }
      if (int.parse(info['sign_day']) >= today || isnull(info['issign'])) {
        //签到按钮（显示联系签到天数）

        return Expanded(
            child: Column(children: [
          Container(
            decoration: tmpdee,
            child: RawMaterialButton(
              shape: CircleBorder(),
              padding: EdgeInsets.all(18.0),
              fillColor: cansign ? SQColor.white : Colors.grey[300],
              child: Text(lang('签到'),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: SQColor.primary)),
              onPressed: cansign ? httpsign : null,
            ),
          ),
          // gt2(num.toString() + lang('次')),
          // gt(
          //   lang('连续签到'),
          // ),
        ]));
      }
      if (int.parse(info['sign_day']) < today) {
        if (bsqignnum <= 0) {
          //补签次数不足
          cansign = false;
        }
      }
      return Expanded(
          child: Column(children: [
        Container(
          decoration: tmpdee,
          child: RawMaterialButton(
            shape: CircleBorder(),
            padding: EdgeInsets.all(18.0),
            fillColor: cansign ? SQColor.white : Colors.grey[300],
            child: Text(lang('补签'),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: SQColor.primary)),
            onPressed: cansign ? httpsign : null,
          ),
        ),
        // gt2(bsqignnum.toString() + lang('次')),
        // gt(
        //   lang('补签次数'),
        // ),
      ]));
    }
    return Container();
  }

  getbox() {
    //  Text('连续签到五天以上才可领取翻倍奖励')
    var str = Text(lang('连续签到五天以上才可领取翻倍奖励'),
        style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16,
          fontWeight: FontWeight.w100,
          color: Colors.black,
        ));
    return Container(
      padding: EdgeInsets.all(10),
      child: str,
    );
    //return Text('连续签到五天以上才可领取翻倍奖励');
  }

  //签到按钮部分
  Widget _signtop() {
    // d(info['issign']);
//下面
    Widget o1, o2;
    if (int.parse(info['sign_day']) >= today || isnull(info['issign'])) {
      var num;
      if (isnull(info['issign'])) {
        num = info['num'];
      } else {
        var tmpnum = chooseday - 2;
        num = prolist[tmpnum >= 0 ? tmpnum : 0]['num'];
      }
      o1 = gt2(num.toString() + lang('次'));
      o2 = gt(
        lang('连续签到'),
      );
    } else {
      o1 = gt2(bsqignnum.toString() + lang('次'));
      o2 = gt(
        lang('补签次数'),
      );
    }

    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(
        children: <Widget>[
          //待领取 是否翻倍
          Expanded(
              child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      margin: EdgeInsets.only(bottom: 2, right: 2),
                      child: Image.asset('assets/images/bean.png', width: 18)),
                  gt2(
                    isnull(info) ? info['sign_icon'].toString() : '0',
                  ),
                  Icon(Icons.clear, size: 15, color: SQColor.white),
                  gt3(
                    info['sign_multiple'],
                  ),
                  int.parse(info['sign_multiple']) > 1
                      ? Container(
                          margin: EdgeInsets.only(bottom: 2, left: 2),
                          child: GestureDetector(
                              onTap: () {
                                //显示说明信息
                                // showDialog(context: context, child: getbox());
                                showbox(getbox(), SQColor.white);
                              },
                              child: Icon(Icons.error_outline,
                                  size: 15, color: Colors.grey)))
                      : Container()
                ]),
            isnull(info)
                ? (isnull(info['issign'])
                    ? gt(
                        lang('已领取'),
                      )
                    : gt(
                        lang('待领取'),
                      ))
                : SizedBox(),
            // SizedBox(
            //   height: 10,
            // ),
            // gt(
            //   lang('奖励倍数'),
            // ),
            o1, o2
          ])),
          //中间线
          Container(
            height: 110,
          ),
          Container(
            width: 1,
            height: topheight - 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, -1.0),
                end: Alignment(0.0, 1.0),
                colors: [
                  Color(0x00ffffff),
                  Color(0x50ffffff),
                  Color(0xFFffffff),
                  Color(0xFFffffff),
                  Color(0x50ffffff),
                  Color(0x00ffffff),
                ], // whitish to gray
              ),
            ),
          ),
          //签到按钮
          gright(),
        ],
      ),

      Container(
        height: 10,
      ),
      getob(),
      // Expand(child:)
      SizedBox(height: 15),
      _task(),
      SizedBox(height: 15),
    ]);
  }

  Widget _task() {
    return Container(
        width: objw * 7 + 2,
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 10),
        decoration: new BoxDecoration(
          color: SQColor.white,
          borderRadius: new BorderRadius.circular(10), // 圆角度
          //border: new Border.all(color: Color(0xf1aec1e2), width: 1),
          boxShadow: [
            BoxShadow(
              color: SQColor.primary2,
              offset: Offset(1.0, 1.0),
              blurRadius: 1.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //标题
            Text(lang('做任务赚金豆'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SQColor.black)),
            //任务
            //广告无接入服务商
            // 1每日分享 2每日阅读 3邀请好友 4替好友充值 5每日看广告 6签到,7完善用户资料,8每日充值

            taskrow(lang('阅读30分钟'), lang('每日阅读30分钟奖励60金豆'), 60, 0, 0, 2, () {
              pop(context);
            }, () {
              var obj = Jsq();
              int readtime = obj.gettime();
              lqjl('task/read', {'readsec': readtime}, '2', 60);
            }),
            taskrow(lang('每日充值'), lang('每日充值任意金额奖励100金豆'), 100, 0, 0, 8,
                () async {
              await gourl(context, Recharge());
              //刷新
              inittask();
            }, () {
              lqjl('task/pay', {}, '8', 100);
            }),
            taskrow(lang('每日标记'), lang('给阅读的书添加标记，每本书只能添加一次'), 25, 0, 3, 11,
                () async {
              // pop(context);
              List book;
              List data2;
              var tmp;
              String hotbooks;
              // await Future.wait<dynamic>([
              // book = await T('book')
              //     .where({'isgroom': '1', 'uid': getuid()})
              //     .order('addtime desc')
              //     .getall();
              book =
                  await T('read as v left join book as b on v.bookid=b.bookid')
                      .wherestring('v.uid=' +
                          getuid() +
                          " and v.type in (1,2) group by b.bookid")
                      .limit('500')
                      .order('readtime desc')
                      .getall();

              hotbooks = (await http('mark/getbook', null, gethead(), 10))!;
              if (!isnull(book)) {
                show(context, lang('你还没阅读任何书籍哦'));
                return;
              } else {
                //取远程一条书籍
                // var hotbooks = await http('book/new', null, gethead());
                tmp = getdata(context, hotbooks);
                data2 = tmp['selectin'];
                List data3 = tmp['list'];
                var tmpcoin = '25';
                var temptype = '11';
                var boosl;
                var type;
                Novel? novel = null;
                if (!isnull(data2)) {
                  if (!isnull(data3)) {
                    novel = Novel.fromDb(book[0]);
                  } else {
                    int id = 0;
                    if (data3[0] is String) {
                      id = int.parse(data3[0]);
                    } else {
                      id = data3[0];
                    }
                    if (id > 50000) {
                      type = 2;
                    } else {
                      type = 1;
                    }

                    novel = await Novel.fromID(id, type);
                  }
                  boosl = await gourl(context, MarkBook(novel: novel!));

                  if (isnull(boosl) && boosl > 0) {
                    User.addcoin(tmpcoin);
                    showcai(lang('奖励到账'), tmpcoin);
                    if (isnull(taskdata, temptype)) {
                      taskdata[temptype]['num'] =
                          (1 + int.parse(taskdata[temptype]['num'])).toString();
                      reflash();
                    } else {
                      taskdata[temptype] = {'num': '1'};
                      reflash();
                    }
                  } else {}
                  return;
                } else {
                  var id = '0';

                  if (!isnull(data3)) {
                    for (var bok in book) {
                      id = bok['bookid'].toString();

                      if (!data2.contains(id)) {
                        novel = Novel.fromDb(bok);
                        break;
                      }
                    }
                  } else {
                    for (var bok in data3) {
                      id = bok.toString();

                      if (!data2.contains(id)) {
                        if (int.parse(id) > 50000) {
                          type = 2;
                        } else {
                          type = 1;
                        }
                        novel = await Novel.fromID(int.parse(id), type);
                        break;
                      }
                    }
                  }

                  if (isnull(novel)) {
                    boosl = await gourl(context, MarkBook(novel: novel!));

                    if (isnull(boosl) && boosl > 0) {
                      User.addcoin(tmpcoin);
                      showcai(lang('奖励到账'), tmpcoin);
                      if (isnull(taskdata, temptype)) {
                        taskdata[temptype]['num'] =
                            (1 + int.parse(taskdata[temptype]['num']))
                                .toString();
                        reflash();
                      } else {
                        taskdata[temptype] = {'num': '1'};
                        reflash();
                      }
                    }
                    return;
                  }
                }
                show(context, lang('你阅读书籍已经全部标记了，请阅读新的书籍，再来参与任务'));
                return;
              }
            }, () {}),

            taskrow(
                lang('每日分享'),
                lang(
                    '分享到不同平台（facebook、twitter、wahtapp..）,至少一个好友阅读文章，既可领取100金豆'),
                100,
                0,
                4,
                1, () async {
              // pop(context);
              var book = await T('book')
                  .where({'isgroom': '1', 'uid': getuid()})
                  .order('addtime desc')
                  // .limit('250')
                  .getone();
              if (isnull(book)) {
                Novel novel = Novel.fromDb(book);
                gourl(context, NovelDetailScene(novel, true));
              } else {
                //取远程一条书籍
                var hotbooks = await http('book/new', null, gethead());
                var data2 = getdata(context, hotbooks);
                if (isnull(data2)) {
                  var rng = Random();
                  var randindex = rng.nextInt(data2.length);
                  var hotbook = data2[randindex];
                  Novel novel = Novel.fromJson(hotbook);
                  gourl(context, NovelDetailScene(novel, true));
                }
              }
            }, () {}),

            taskrow(lang('看视频'), lang('领取丰厚奖励'), 50, 0, 5, 5, () async {
              // gourl(context, Ads());
              // var data = await gourl(context, Ads());
              show(context, lang('视频加载中，请稍等..'));
              g('admob').load((bool isget) {
                if (isnull(isget)) {
                  d('回调');
                  //执行结算
                  lqjl2('task/ad', {}, '5', 50);
                }
              });
            }, () {}),
            taskrow(lang('完善用户资料'), lang('完善用户资料奖励100金豆'), 100, 0, 0, 7,
                () async {
              await gourl(context, EditUser());
              //刷新
              inittask();
            }, () async {
              lqjl('task/endeditinfo', {}, '7', 100);
              // await
              // inittask();
            }),
            // taskrow(lang('应用评价'), lang('5星好评领取奖励'), 200, 0, 0, 9, () async {
            //   AdBridge.call('googlopj');

            // }, () async {

            // }),
            taskrow(
                lang('应用评价'),
                lang('应用评价领取100~500金豆。提交评论截图给客服，奖励将在一到两个工作日到账'),
                500,
                0,
                0,
                9, () async {
              await openStoreListing(appStoreId: '');
              //退出对话框，去提交评论截图
              // d('回到评价页面');
              showgokf();
            }, () async {}),
            taskrow(lang('阅读本地小说'), lang('导入任意本地小说，领取100金豆'), 100, 0, 0, 10,
                () async {
              // await openStoreListing();
              eventBus.emit('EventToggleTabBarIndex', 0);
              pop(context);
              eventBus.emit('xsdrsj');

              // showgokf();
            }, () async {
              lqjl('task/readlocal', {}, '10', 100);
            }),
            taskrow(lang('邀请好友'), lang('领取丰厚奖励'), 500, 0, 0, 3, () {
              gourl(context, Friend());
              // pop(context);
            }, () {}, false),
          ],
        ));
  }

  lqjl(jlapi, Map<String, dynamic> data, String type, coin) {
    http(jlapi, data, gethead()).then((data) {
      var data2 = getdata(context, data);
      if (isnull(data2)) {
        User.upcoin(data2['remainder']);
        showcai(lang('奖励到账'), coin);
        taskdata[type] = 1;
        reflash();
      }
    });
  }

  Future<void> openStoreListing({
    /// Required for IOS & MacOS
    required String appStoreId,
  }) async {
    final bool isIOS = Platform.isIOS;
    final bool isMacOS = Platform.isMacOS;
    if (isIOS || isMacOS) {
      // ignore: unnecessary_null_comparison
      assert(appStoreId != null);

      final Uri uri = Uri(
        scheme: isIOS ? 'https' : 'macappstore',
        host: 'apps.apple.com',
        path: 'app/id$appStoreId',
        queryParameters: {'action': 'write-review'},
      );

      await _launchUrl(uri.toString());
    } else if (Platform.isAndroid) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String packageName = packageInfo.packageName;

      await _launchUrl(
          'https://play.google.com/store/apps/details?id=$packageName');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  lqjl2(jlapi, Map<String, dynamic> data, String type, coin) {
    http(jlapi, data, gethead()).then((data) {
      var data2 = getdata(context, data);
      if (isnull(data2)) {
        User.upcoin(data2['remainder']);
        showcai(lang('奖励到账'), coin);
        taskdata[type]['num'] =
            (1 + int.parse(taskdata[type]['num'])).toString();
        reflash();
      } else {
        if (int.parse(taskdata[type]['num']) >= 5) {
          show(g('context'), lang('今日该任务已经奖励已经达到上限'));
        } else {
          //  show(g('context'),lang(''));
        }
      }
    });
  }

  Widget taskrow(String title, String desc, int coin, int nums, int totalnum,
      int type, Function callgo, Function callget,
      [bool showline = true]) {
    int status = 0;
    int rate = 0;
    switch (type) {
      case 2:
        var obj = Jsq();
        // obj.clear();
        int readtime = obj.gettime();

        if (readtime > 1800) {
          status = 1;
        }
        if (isnull(taskdata)) {
          if (isnull(taskdata['2'])) {
            status = 2;
          }
        }
        break;
      case 5:
        if (isnull(taskdata, '5')) {
          nums = int.parse(taskdata['5']['num']);
        }

        break;
      case 11:
        if (isnull(taskdata, '11')) {
          nums = int.parse(taskdata['11']['num']);
        }

        break;
      case 8:
        if (todaypay) {
          status = 1;
        }

        if (isnull(taskdata)) {
          if (isnull(taskdata['8'])) {
            status = 2;
          }
        }
        break;
      case 9:
        if (isnull(taskdata)) {
          if (isnull(taskdata['9'])) {
            status = 2;
          }
        }
        break;
      case 10:
        //判断数据库有没有本地小说类型书籍，有就状态为可以领取

        if (isnull(havebook)) {
          status = 1;
        }
        if (isnull(taskdata)) {
          if (isnull(taskdata['10'])) {
            status = 2;
          }
        }
        break;
      case 1:
        if (isnull(taskdata)) {
          if (isnull(taskdata['1'])) {
            nums = int.parse(taskdata['1']['num']);
            if (nums >= 4) {
              status = 2;
            }
          }
        }
        break;
      case 7:
        if (true) {
          var user = User.get();
          if (isnull(taskdata, '7')) {
            status = 2;
          } else {
            //显示百分比
            // {nickname: เต้าหู้กับซอส, more: 快快快, avater: null, sex: 2, borth: 1991-11-14 00:00:00.000}

            if (isnull(user, 'nickname')) {
              rate = rate + 20;
            }
            if (isnull(user, 'more')) {
              rate = rate + 20;
            }
            if (isnull(user, 'avater')) {
              rate = rate + 20;
            }
            if (isnull(user, 'borth')) {
              rate = rate + 20;
            }
            if (isnull(user, 'sex')) {
              rate = rate + 20;
            }
            if (rate == 100) {
              status = 1;
            } else {
              status = 0;
            }
          }
        }
        break;
      default:
    }
    var r = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 15, color: SQColor.black)),
              SizedBox(height: 2),
              Text(desc,
                  overflow: TextOverflow.clip,
                  style: TextStyle(fontSize: 13, color: SQColor.gray)),
              SizedBox(height: 2),
              Row(children: [
                Container(
                    margin: EdgeInsets.only(bottom: 2, left: 2),
                    child: Image.asset('assets/images/bean.png', width: 15)),
                Text((type == 9 ? ("100-500") : coin.toString()) + lang('金豆'),
                    style: TextStyle(fontSize: 13, color: Colors.orange)),
              ]),
              SizedBox(height: 8),
            ])),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          getstatus(status, callgo, callget),
          isnull(totalnum)
              ? Text('$nums/$totalnum',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ))
              : Container(),
          type == 7
              ? status == 0
                  ? Text('$rate%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ))
                  : Container()
              : Container(),
        ]),
      ],
    );
    return Column(
      children: <Widget>[
        r,
        showline
            ? Divider(
                height: 1,
                color: Colors.grey[300],
              )
            : Container(),
      ],
    );
  }

  getstatus(
    int status,
    Function callgo,
    Function callget,
  ) {
    String text = "";
    Color c = Color.fromARGB(0, 0, 0, 0),
        c2 = Color.fromARGB(0, 0, 0, 0),
        c3 = Color.fromARGB(0, 0, 0, 0);
    Function f = () {};
    c2 = SQColor.white;
    c3 = Colors.black;
    if (status == 0) {
      //去完成

      text = lang('去完成');
      c = const Color.fromARGB(255, 255, 216, 77);
      f = callgo;
    }
    if (status == 1) {
      //领取奖励
      text = lang('领取奖励');
      c = const Color.fromARGB(255, 255, 211, 128);
      c2 = const Color.fromARGB(255, 255, 223, 128);
      f = callget;
    }
    if (status == 2) {
      text = lang('已完成');
      c = const Color.fromARGB(255, 255, 238, 128);
      c3 = Colors.grey;
      f = () {};
    }

    var box = Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      padding: EdgeInsets.only(top: 3, bottom: 3, right: 9, left: 9),
      decoration: new BoxDecoration(
        border: new Border.all(width: 1.0, color: c),
        color: c2,
        borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 12, color: c3, fontWeight: FontWeight.w500)),
    );
    return GestureDetector(
      // onTap: () async {
      //   await gourl(context, Ads());
      // },
      onTap: () {
        f();
      },
      child: box,
    );
  }

  Widget getday(int day) {
    var tmpinfo;
    if (isnull(prolist)) {
      tmpinfo = prolist[day - 1];
    }
    var m2 = maozhua;

    if (isnull(tmpinfo['issign']) &&
        int.parse(tmpinfo['num']) > 5 &&
        int.parse(tmpinfo['sign_multiple']) > 1) {
      m2 = maozhua2;
    }
    var c = Container(
        margin: EdgeInsets.only(top: 2, bottom: 2),
        width: objw,
        child: Stack(alignment: AlignmentDirectional.center, children: [
          SizedBox(
            height: 40,
          ),
          chooseday == day ? choose : Container(),
          Text(
            day.toString(),
            textAlign: TextAlign.center,
          ),
          isnull(tmpinfo['issign']) ? m2 : Container(),
        ]));
    return GestureDetector(
      onTap: () {
        choosedayfun(day);
      },
      child: c,
    );
  }

  choosedayfun(var day) {
    chooseday = day;
    info = prolist[day - 1];
    reflash();
  }

  Widget getkongbai([String? str]) {
    if (isnull(str)) {
      return Container(
          padding: EdgeInsets.all(5),
          width: objw,
          child: Text(str!, textAlign: TextAlign.center));
    } else {
      return Container(padding: EdgeInsets.all(2), width: objw);
    }
  }

  Widget calendars() {
    var calendarinfo = Calendar.get(year, month, context);

    List<Widget> th = [
      getkongbai(lang('一')),
      getkongbai(lang('二')),
      getkongbai(lang('三')),
      getkongbai(lang('四')),
      getkongbai(lang('五')),
      getkongbai(lang('六')),
      getkongbai(lang('日')),
    ];
    List<Widget> td = [];
    for (var a = 1; a < calendarinfo['offset']; a++) {
      td.add(getkongbai());
    }
    for (var i = 1; i <= calendarinfo['nums']; i++) {
      td.add(getday(i));
    }
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 15, bottom: 0),
          child: Center(
            child: Text(
              month.toString().padLeft(2, '0') + '/' + year.toString(),
              style: TextStyle(
                fontSize: 15,
                letterSpacing: 3,
                fontFamily: 'LoveCraft',
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          color: Color(0xfff4f7ff),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: th,
          ),
        ),
        Wrap(children: td),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  getob() {
    var calendarobj = calendars();
    return Container(
      width: objw * 7 + 2,
      //height: 600,
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: new BoxDecoration(
        color: SQColor.white,
        borderRadius: new BorderRadius.circular(10), // 圆角度
        //border: new Border.all(color: Color(0xf1aec1e2), width: 1),
        boxShadow: [
          BoxShadow(
            color: SQColor.primary2,
            offset: Offset(1.0, 1.0),
            blurRadius: 1.0,
          ),
        ],
      ),
      child: calendarobj,
    );
  }

  //签到展示部分
  // Widget _signbottom() {
  //   return Positioned(top: barheight + topheight, child: getob());
  // }

//挂钩
  Widget _signbottomg() {
    // var ico = Icon(Icons.access_alarm);
    var ico = Container(
      width: 10,
      height: 20,
      decoration: new BoxDecoration(
        color: Color(0xffe6e6e6),
        borderRadius: new BorderRadius.circular(6), // 圆角度
        //border: new Border.all(color: Color(0xf1aec1e2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Color(0xffbdc2bc),
              offset: Offset(1.0, 1.0),
              //blurRadius: 1.0,
              spreadRadius: 1.0),
        ],
      ),
    );
    return Positioned(
        top: barheight + topheight - 28,
        child: Container(
          width: objw * 7 + 2,
          margin: EdgeInsets.only(left: 10, right: 10),
          // decoration: new BoxDecoration(

          //   borderRadius: new BorderRadius.circular(10), // 圆角度
          //   border: new Border.all(color: Color(0xf1aec1e2), width: 1),

          // ),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Center(
                child: ico,
              )),
              SizedBox(
                width: 1,
              ),
              Expanded(
                  child: Center(
                child: ico,
              )),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // if (isnull(g('locallg'))) {
    //   RegExp chapterMatch = RegExp(r"(th|CN|zh|TH)+.?");
    //   // d(g('locallg').toString());
    //   if (chapterMatch.hasMatch(g('locallg').toString())) {
    //     //广告只在中国跟泰国显示
    //     showad = true;
    //   }
    // } else {
    //   showad = false;
    // }

    if (!isnull(info)) {
      return Loadbox(
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
    }
    var body = Column(
      children: [
        // g('admob').getnvad(),
        Container(
          padding: EdgeInsets.only(
            top: barheight,
            // bottom: 1,
          ),
          child: _signtop(),
        ),
      ],
    );
    return Scaffold(
      // resizeToAvoidBottomPadding: false, //输入框抵住键盘
      body: Container(
          height: getScreenHeight(context),
          decoration: topcolor,
          child: SingleChildScrollView(
              child: SizedBox(
                  child: Stack(
            // overflow: Overflow.visible,
            children: <Widget>[
              body,
              _signbottomg(),
              buildNavigationBar(),
            ],
          )))),
    );
  }

  showgokf() {
    msgbox(context, () {
      gourl(context, Kefu());
    }, null, Text(lang('评论完成，去提交截图给客服')), Text(lang('取消')), Text(lang('确定')));
  }
}
