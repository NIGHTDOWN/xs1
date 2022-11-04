import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/NgDashedLine.dart';
import 'package:share/share.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';

// ignore: must_be_immutable
class Friend extends LoginBase {
  bool needlogin = true;
  List<dynamic> invitelist = [
    // {
    //   'avater':
    //       'https://img-blog.csdn.net/20170331120045162?imageView2/1/w/64/h/64/interlace/1',
    //   'flag': '1',
    //   'nickname': 'test'
    // },
    // {
    //   'avater':
    //       'https://img-blog.csdn.net/20170331120045162?imageView2/1/w/64/h/64/interlace/1',
    //   'flag': '0',
    //   'nickname': 'test'
    // },
  ];
  var nums = '0', numyx = '0';
  List rand;
  var coin = '500';
  var size = 10;
  var cachename = 'friendcache';
  var api = 'task/friendinfo';
  var api2 = 'task/friendmore';
  Timer time;
  bool start = true;
  int randindex = 0, page = 1;
  bool isend = false;
  @override
  void initState() {
    super.initState();
    loadcache();
    loadhttp();
    dsq();
  }

  shares() {
    // var uid = User.getuid().toString();
    // var id = novel.id;
    var info = gettime();
    // var uid = '123';
    var uid = User.getuid();
    var langs = getlang();
    var url = serverurl + 'index/down/run?uid=$uid&nap=$info&lang=$langs';

    var str = '#LookStory#' +
        lang('我正在此APP看书，邀请你也来！赶紧来安装') +
        'LookStory APP!' +
        "    " +
        url;
    Share.share(str, subject: lang('LookStory'));
  }

  @override
  void dispose() {
    // eventBus.off(EventUserLogin);
    // eventBus.off(EventUserLogout);
    start = false;
    //reflash();
    super.dispose();
  }

  dsq() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!start) {
        timer.cancel();
      }
      if (!isnull(rand)) {
        return;
      }
      var rng = Random();
      randindex = rng.nextInt(rand.length);

      reflash();
    });
  }

  loadcache() {
    //本地缓存
    var cache = getcache(cachename);
    if (isnull(cache)) {
      rand = cache['rand'];
      nums = cache['num'];
      numyx = cache['nums'];
      invitelist = cache['user'];
    }
  }

  loadhttp() async {
    //远程加载数据
    var datatmp = await http(api, {}, gethead());
    var data = getdata(context, datatmp);
    if (isnull(data)) {
      setcache(cachename, data, '-1');
      rand = data['rand'];
      nums = data['num'];
      numyx = data['nums'];
      invitelist = data['user'];
      reflash();
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Center(child: Text('friend'));
    var topcolor = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-0.5, 1.0),
        end: Alignment(-0.2, -1.0),
        colors: [Color(0xfffca256), Color(0xFFfd725e)], // whitish to gray
      ),
    );

    return Scaffold(
      // resizeToAvoidBottomPadding: false, //输入框抵住键盘
      appBar: AppBar(
          title: Container(
        child: Text(lang("邀请有礼")),
      )),
      body: Container(
          decoration: topcolor,
          child: SingleChildScrollView(
            child: getbody(),
          )),
    );
  }

  String fixname(String number) {
    int lengths = (number.length / 3).ceil();
    String secure = number.replaceFirst(
        RegExp(r'.(.{' + lengths.toString() + '})'), '**', lengths - 1);

    return secure;
  }

  getpmd(int index) {
    if (isnull(rand, index)) {
      String str;
      var name = fixname(rand[index]['nickname']);
      str = name + lang('刚刚领取') + coin + lang('金豆');
      return Text(str,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white));
    }
    return SizedBox();
  }

  Widget getbody() {
    var box = TextButton(
      onPressed: () {
        shares();
      },
      // textColor: Colors.white,
      // clipBehavior: Clip.hardEdge,
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(22.0))),
      // padding: const EdgeInsets.all(0.0),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          return Colors.white;
        }),
        padding: MaterialStateProperty.all(EdgeInsets.all(0.0)),
      ),
      child: Container(
        width: 230,
        height: 44,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xffff8486),
              Color(0xffff6668),
              Color(0xffff484a)
            ],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Container(
            alignment: Alignment.center,
            child: Text(
              lang('立即邀请'),
              style: TextStyle(
                  fontSize: 15,
                  letterSpacing: 3,
                  // color: Color(0xff701000),
                  fontWeight: FontWeight.w600),
            )),
      ),
    ); // FlatButton

    return Column(children: [
      //顶部背景
      Container(
          margin: EdgeInsets.only(bottom: 15),
          // constraints: new BoxConstraints.expand(
          //   height: getScreenWidth(context),
          // ),
          width: getScreenWidth(context),
          //设置背景图片
          decoration: new BoxDecoration(
            // color: Colors.grey,
            // border: new Border.all(width: 2.0, color: Colors.red),
            // borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
            image: new DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                'assets/images/ch.png',
              ),
              //这里是从assets静态文件中获取的，也可以new NetworkImage(）从网络上获取
              // centerSlice: new Rect.fromLTRB(270.0, 180.0, 1360.0, 730.0),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              //标题
              SizedBox(height: 18),

              isnull(rand)
                  ? Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      padding: EdgeInsets.only(
                          top: 5, bottom: 5, left: 10, right: 10),
                      width: getScreenWidth(context) * .6,
                      // height: 40,
                      decoration: new BoxDecoration(
                        color: Color(0x18000000),
                        // border: new Border.all(width: 2.0, color: Colors.red),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(20.0)),
                      ),
                      child: Center(child: getpmd(randindex)))
                  : SizedBox(height: 10),

              Image.asset(
                'assets/images/ch2.png',
                width: getScreenWidth(context) * .6,
              ),
              //滚动栏
              //插画
            ],
          )),
      //

      getbox(
          lang('邀请收益'),
          Column(children: [
            Row(children: [
              Expanded(
                  child: Column(children: [
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      isnull(nums) ? nums : '0',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xfffa2d32),
                      ),
                    ),
                    Text(
                      lang('位'),
                      style: TextStyle(color: Color(0xfffa2d32), height: 3),
                    )
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  lang('已邀请'),
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff701000),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),
              ])),
              Expanded(
                  child: Column(children: [
                // SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      (int.parse(numyx) * int.parse(coin)).toString(),
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xfffa2d32),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Image.asset('assets/images/bean.png', width: 15),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  lang('已赚取'),
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff701000),
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 15),
              ])),
            ]),
            box,
            SizedBox(height: 10)
          ])),
      getbox(
          lang('邀请攻略'),
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [yq(Icons.record_voice_over), gettext('分享链接邀请好友')],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Row(children: [SizedBox(width: 26), getline()]),
                Row(
                  children: [yq(Icons.save_alt), gettext('好友打开链接下载APP')],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Row(children: [SizedBox(width: 26), getline()]),
                Row(
                  children: [yq(Icons.group_add), gettext('新用户注册，老用户登入')],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Row(
                  children: [SizedBox(width: 26), getline()],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Row(children: [
                  yq(Icons.touch_app),
                  gettext('好友回到链接页面点击‘助力好友’按钮，帮助你领取500金豆')
                ]),
                SizedBox(height: 15),
                Divider(
                  height: 1,
                  color: Color(0xffff9f9e),
                ),
                SizedBox(height: 10),
                Text(
                  lang('规则说明'),
                  style: TextStyle(
                      fontSize: 15,
                      color: Color(0xff701000),
                      fontWeight: FontWeight.w700),
                ),
                gettext2('1.无论新老用户都可以参与活动'),
                gettext2('2.已绑定邀请人的用户无法参与活动'),
                gettext2('3.每台手机设备只能参与一次,同一手机多个账号只有一次生效'),
                gettext2('4.新老用户也可以通过编辑用户资料绑定邀请人ID来参与活动'),
              ])),
      isnull(invitelist)
          ? getbox(
              lang('邀请列表'),
              Column(children: [
                SizedBox(height: 15),
                Row(
                  children: [gettext3('用户'), gettext3('奖励'), gettext3('状态')],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                ListView.builder(
                  physics: BouncingScrollPhysics(
                      parent: NeverScrollableScrollPhysics()),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return gettext4(context, index);
                  },
                  itemCount: invitelist.length,
                ),
                invitelist.length < size
                    ? SizedBox()
                    : isend
                        ? gettext7('已经显示全部')
                        : gettext6('点击加载更多')
              ]))
          : SizedBox(),
    ]);
  }

  gettext4(context, int str) {
    if (!isnull(invitelist, str)) {
      return Container();
    }
    var data = invitelist[str];
    var head = isnull(data['avater'])
        ? yq2(Image.network(data['avater']))
        : yq2(Image.asset('assets/images/placeholder_avatar.png'));
    var nickname = data['nickname'];

    var flag = data['flag'];
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Container(
              margin: EdgeInsets.only(top: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                head,
                SizedBox(
                  width: 3,
                ),
                Expanded(
                    child: Text(
                  nickname,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xa9333333),
                    // fontWeight: FontWeight.w700
                  ),
                ))
              ])),
        ),
        Expanded(
          child: gettext5(coin, TextAlign.center),
        ),
        Expanded(
          child: gettext5(
              isnull(flag) ? lang('已领取') : lang('设备重复'), TextAlign.right),
        )
      ]),
      SizedBox(
        height: 10,
      ),
      Divider(
        height: 1,
        color: Color(0xfffcd7b8),
      )
    ]);
  }

  gettext5(String str, TextAlign textAlign) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Text((str),
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xa9333333),
            // fontWeight: FontWeight.w700
          )),
    );
  }

  gettext3(String str) {
    return Container(
      child: Container(
          child: Text(
        lang(str),
        style: TextStyle(
            fontSize: 15,
            color: Color(0xff000000),
            fontWeight: FontWeight.w700),
      )),
    );
  }

  Widget getbox(String title, Widget obj) {
    return Stack(
      children: <Widget>[
        //矩形框

        Row(children: [
          Expanded(
              child: Container(
                  margin:
                      EdgeInsets.only(top: 20, bottom: 15, left: 15, right: 15),
                  child: obj,
                  padding:
                      EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
                  // constraints: new BoxConstraints.expand(
                  //   height: 60,
                  // ),
                  //设置背景图片
                  decoration: new BoxDecoration(
                    color: Color(0xfffdf2e8),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(10.0)),
                  )))
        ]),
        //头部
        Row(
          children: [
            Image.asset(
              'assets/images/chl.png',
              height: 40,
              // width: getScreenWidth(context) * .6,
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              color: Color(0xfffd745e),
              height: 40,
              child: Center(
                  child: Text(
                title,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              )),
            ),
            Image.asset(
              'assets/images/chr.png',
              height: 40,
              // width: getScreenWidth(context) * .6,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )
      ],
    );
  }

  gettext(String str) {
    var wstr = Text(
      lang(
        str,
      ),
      style: TextStyle(
          fontSize: 15, color: Color(0xff701000), fontWeight: FontWeight.w500),
    );
    return Expanded(
        child: Container(
      child: wstr,
      margin: EdgeInsets.only(left: 15, right: 15, top: 5),
    ));
  }

  gettext6(String str) {
    var wstr = Text(
      lang(
        str,
      ),
      style: TextStyle(
          fontSize: 15, color: Color(0xff701000), fontWeight: FontWeight.w500),
    );
    var btn = Center(
        child: Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.filter_list,
          color: Color(0xff701000),
        ),
        wstr
      ]),
      margin: EdgeInsets.only(left: 15, right: 15, top: 5),
    ));
    return GestureDetector(
      child: btn,
      onTap: () async {
        //加载

        var data = await http('task/friendmore', {'page': page++}, gethead());
        var tmp = getdata(context, data);
        if (isnull(tmp)) {
          invitelist.addAll(tmp);
          reflash();
        } else {
          isend = true;
          reflash();
        }
      },
    );
  }

  gettext7(String str) {
    var wstr = Text(
      lang(
        str,
      ),
      style: TextStyle(
          fontSize: 15, color: Color(0xffc1c1c1), fontWeight: FontWeight.w500),
    );
    var btn = Center(
        child: Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        // Icon(
        //   Icons.filter_list,
        //   color: Color(0xff701000),
        // ),
        wstr
      ]),
      margin: EdgeInsets.only(left: 15, right: 15, top: 5),
    ));
    return btn;
  }

  gettext2(String str) {
    var wstr = Text(
      lang(
        str,
      ),
      style: TextStyle(fontSize: 14, color: Color(0x99101420)),
    );
    return Container(
      child: wstr,
      // margin: EdgeInsets.only(left: 5, right: 5, top: 5),
      margin: EdgeInsets.all(5),
    );
  }

  getline() {
    return NgDashedLine(
      axis: Axis.vertical,
      width: 30,
      count: 8,
      // dashedWidth: 1,
      dashedHeight: 3,
      color: Color(0xfffd8a78),
    );
  }

  Widget yq(IconData ico, [double size = 52]) {
    return new Container(
      child: Center(
          child: Icon(
        ico,
        size: size * 0.6,
        color: Color(0xfffde5ce),
      )),
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xfffe9c8d),
            Color(0xfffd8a78),
            Color(0xfffd7560)
          ],
        ),
        shape: BoxShape.circle,
        // image: DecorationImage(
        //   image: AssetImage(
        //     Utils.getImgPath('ali_connors'),
        //   ),
        // ),
      ),
    );
  }

  Widget yq2(Widget obj, [double size = 35]) {
    return Container(
      // margin: EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35.0),
        child: obj,
      ),
      width: size,
      height: size,
    );
  }

  back() {
    pop(context);
  }
}
