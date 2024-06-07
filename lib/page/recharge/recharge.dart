import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/commect/kefu.dart';
import 'package:ng169/page/smallwidget/gifload.dart';

import 'package:ng169/pay/googlepay.dart';

import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';

import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/loadbox.dart';
import 'package:ng169/tool/url.dart';

import '../../pay/pay.dart';

// ignore: must_be_immutable
class Recharge extends LoginBase {
  final String bookid;
  final String type;
  final String secid;
  late bool needlogin = true;

  List<Widget> more = [SizedBox()];
  bool debug = false;
  var cachedata = 'rechargesearch_data_',
      cachedatatime = 'rechargesearch_data_time_',
      page = 1;
  List prolist = [];
  String api = 'order/get_charge';
  String creat_order_api = 'order/creat';
  String cancel_order_api = 'order/fail';
  String order_log_api = 'order/order_log';
  String order_sure_api = 'google/payv3';
  late String order_num;
  //2 是用户取消，3是其他
  late int pay_status;
  int pay_type = 4; //1为paypal 4为google 5 appstore
  int click = 0;
  late var select = "0";
  List sign_data = [];
  late var user;
  String failmsg = "";
  late Pay googlepayobj;
  var style1 = new TextStyle(
      fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500);
  var style11 = new TextStyle(
      fontSize: 16, color: Colors.black38, fontWeight: FontWeight.w300);
  var style2 = new TextStyle(
      fontSize: 18, color: SQColor.primary, fontWeight: FontWeight.w700);
  var style3 = new TextStyle(
      fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w400);
  var style4 = new TextStyle(
      fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500);
  var style5 = new TextStyle(
      fontSize: 20, color: Colors.black, fontWeight: FontWeight.w900);
  var style6 = new TextStyle(
      fontSize: 15, color: Colors.black38, fontWeight: FontWeight.w300);
  var firstsend = new TextStyle(
      fontSize: 10, color: SQColor.white, fontWeight: FontWeight.w600);
  var firstsend1 = new TextStyle(
      fontSize: 15, color: SQColor.white, fontWeight: FontWeight.w600);
  var color1 = Colors.black54;
  var color2 = SQColor.red;
  var color3 = SQColor.primary4;
  var style41;
  var style51;
  var style61;
  var color11;
  bool payok = false;
  var bean = SizedBox(
    //width: 5,
    child: Image.asset('assets/images/bean.png', width: 18),
  );

  Recharge([this.bookid = '0', this.type = '0', this.secid = '0']);
  Future<void> gethttpdata() async {
    var tmp = await http(api, null, gethead());
    var data2 = getdata(context, tmp);
    if (isnull(data2)) {
      prolist = data2;
    }

    setcache(cachedata, prolist, '-1');
    setcache(cachedatatime, 1, '3600');
    reflash();
  }

  @override
  void initState() {
    super.initState();
    sign_data.add("进入支付页面" + gettime());
    _initgooglepay();
    style41 =
        new TextStyle(fontSize: 13, color: color2, fontWeight: FontWeight.w500);
    style51 =
        new TextStyle(fontSize: 20, color: color2, fontWeight: FontWeight.w800);
    style61 =
        new TextStyle(fontSize: 15, color: color2, fontWeight: FontWeight.w300);
    color11 = Colors.black54;
    loadpage();
  }

  //加载页面
  //先读缓存
  //在读http数据
  loadpage() async {
    var tmp = getcache(cachedata);
    prolist = tmp ?? [];
    if (!isnull(getcache(cachedatatime))) {
      await gethttpdata();
    } else {
      //prolist = tmp;
      gethttpdata();
    }
    sign_data.add("充值展示页面加载" + gettime());
  }

  // reflash() {
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    titlebarcolor(false);
    if (!isnull(prolist)) {
      return Gifload();
      // return Loadbox(
      //   // key: this.key,
      //   loading: true,
      //   color: SQColor.primary,
      //   bgColor: SQColor.gray,
      //   width: 80,
      //   height: 80,
      //   opacity: 0.0,
      //   child: Container(
      //     height: getScreenHeight(context),
      //     width: getScreenWidth(context),
      //     color: SQColor.white,
      //     child: SizedBox(
      //       height: getScreenHeight(context),
      //       width: getScreenWidth(context),
      //       child: Text(''),
      //     ),
      //   ),
      // );
    }
    var margintop = SizedBox(
      height: 15,
    );

    String coin = User.getcoin().toString();
    var lchid = ListView(
      children: <Widget>[
        //margintop,
        //余额
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                lang('我的余额'),
                style: style1,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(coin, style: style2),
                  SizedBox(
                    width: 5,
                  ),
                  bean,
                ],
              ),
            ),
          ],
        ),
        margintop,
        SizedBox(
          width: getScreenWidth(context),
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xdddddddd)),
          ),
        ),
        margintop,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                lang('请选择金额'),
                style: style11,
              ),
            ),
            Text(
              lang("单位") + ':USD',
              style: style11,
            ),
          ],
        ),
        // margintop,
        //充值挡位列表
        Wrap(
          children: prolist.map((json) => pro(json)).toList(),
          spacing: 10,
          alignment: WrapAlignment.spaceBetween,
        ),
        margintop,
        //立即充值按钮
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return color2;
            }),
            // foregroundColor: MaterialStateProperty.resolveWith((states) {
            //   return Styles.getTheme()['activefontcolor'];
            // }),
            padding: WidgetStateProperty.all(EdgeInsets.all(10)),
            shape: WidgetStateProperty.resolveWith((states) {
              return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10));
            }),
          ),

          // color: color2,
          // padding: EdgeInsets.all(10),
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Text(
            lang('立即充值'),
            style: firstsend1,
          ),
          onPressed: () {
            _buy();
          },
        ),
        debug
            ? TextButton(
                // color: color2,
                // padding: EdgeInsets.all(10),
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10)),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return color2;
                  }),
                  // foregroundColor: MaterialStateProperty.resolveWith((states) {
                  //   return Styles.getTheme()['activefontcolor'];
                  // }),
                  padding: WidgetStateProperty.all(EdgeInsets.all(10)),
                  shape: WidgetStateProperty.resolveWith((states) {
                    return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10));
                  }),
                ),
                child: Text(
                  lang('回调测试'),
                  style: firstsend1,
                ),
                onPressed: () {
                  var data =
                      '{"packagename":"com.ng.lovenovel", "sku":"payidls_1", "token":"ngfgloomgjnpfhjebilckdil.AO-J1Oyb2DPUUA182tZE-Y79VBFmSYOkCHqOXeyKcR5L0ROpUiT3DOBHn0dni6UzFZK5hDMBOhxW176hw3XWnGaQX8v7SMOsRXcY14H4RiY9cfSjXSqrKNg", "purchasestate":"1", "fluttersku":"payidls_1", "purchasetime":"1578033450708", "flutterpayload":"测试是不是加入payload", "consumetoken":"ngfgloomgjnpfhjebilckdil.AO-J1Oyb2DPUUA182tZE-Y79VBFmSYOkCHqOXeyKcR5L0ROpUiT3DOBHn0dni6UzFZK5hDMBOhxW176hw3XWnGaQX8v7SMOsRXcY14H4RiY9cfSjXSqrKNg", "orderid":"GPA.3315-9027-5593-93708"}';
                  buySuccess(data);
                },
              )
            : SizedBox(),
        //温馨提示
        margintop,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                lang('温馨提示'),
                style: style11,
              ),
            ),
          ],
        ),
        tips(),
      ],
    );
    var w = getScreenWidth(context) * .05;
    var body = Container(
      padding: EdgeInsets.only(
          top: Screen.navigationBarHeight * .2, left: w, right: w), //顶部间距
      child: RefreshIndicator(
        onRefresh: gethttpdata,
        child: lchid,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(lang('充值')),
      ),
      backgroundColor: SQColor.white,
      body: body,
    );
  }

  Widget pro(json) {
    if (!isnull(json)) return SizedBox();
    var pid = json['applepayId'];
    var w = getScreenWidth(context);
    var ww = w * .25;
    if (json['invite'] == '1' && !isnull(select)) {
      //默认选中
      select = pid;
    }
    var postion = Positioned(
      right: -ww * .07,
      top: -ww * .03,
      child: Container(
          width: ww * .8,
          //foregroundDecoration:new Decoration(),
          decoration: new BoxDecoration(
            color: Colors.red,
            //设置四周圆角 角度
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2.0),
              topRight: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(2.0),
            ),
            //设置四周边框
            border: new Border.all(width: 1, color: Colors.red),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                lang('送'),
                style: firstsend,
              ),
              Text(
                json['first_send'],
                style: firstsend1,
              ),
            ],
          )),
    );
    var p = Stack(
      // overflow: Overflow.visible,
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //设置四周边框
            border: new Border.all(
                width: 1, color: select == pid ? color2 : color1),
          ),
          margin: EdgeInsets.all(5),
          width: ww,
          height: w * .2,
          child: Container(
            color: select == pid ? color3 : SQColor.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text("\$", style: select == pid ? style41 : style4),
                    Text(
                      json['USD'].toString(),
                      style: select == pid ? style51 : style5,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(json['dummy_icon'],
                        style: select == pid ? style61 : style6),
                    SizedBox(
                      width: 2,
                    ),
                    bean,
                  ],
                )
              ],
            ),
          ),
        ),
        isnull(json['first_send']) ? postion : SizedBox()
      ],
    );
    var b = Container(
      margin: EdgeInsets.only(top: 10),
      constraints: BoxConstraints(
          // maxWidth: getScreenWidth(context) * .2,
          // maxHeight: 50,
          ),
      child: GestureDetector(
        child: Container(
          child: p,
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onTap: () {
          select = pid;
          reflash();
        },
      ),
    );
    return b;
  }

  Widget tips() {
    var s = TextStyle(color: Colors.black38);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 3),
      Text(lang('充值遇到问题，请联系客服.'), style: s),
      SizedBox(height: 3),
      Row(children: [
        GestureDetector(
            child: Text(lang('点击进入'),
                style: TextStyle(
                  color: SQColor.blue,
                  decoration: TextDecoration.underline,
                )),
            onTap: () {
              gourl(context, Kefu());
            }),
        Text(lang('客服页面'), style: s)
      ])
    ]);
    // return SizedBox();
  }

  //初始化谷歌支付
  _initgooglepay() {
    googlepayobj = new Pay();
    googlepayobj.initializeInAppPurchase(
        func_success: isok, func_fail: initfail, func_cancel: initcancel);
    // sign_data.add("初始化googlePay" + gettime());

    // googlepayobj.init(
    //     func_success: isok, func_fail: initfail, func_cancel: initcancel);
  }

  //谷歌支付
  _buy() async {
    order_num = "";
    if (click != 0) {
      //非第一次充值，清空初始化信息
      sign_data = [];
    }
    click++;
    sign_data.add("点击购买按钮" + gettime() + "次数" + click.toString());

    if (payok || debug) {
      //检查支付挡位有没有选中
      if (!isnull(select)) {
        show(context, lang("清选择购买挡位"));
        sign_data.add("没选中挡位" + gettime());
        return;
      }
      sign_data.add("创建订单" + gettime());
      //创建订单
      await _createorder(select);
      //调起支付`

      if (isnull(order_num)) {
        sign_data.add("进入google支付" + gettime() + "_" + order_num);
        loadbox(context); //加载框
        // googlepayobj.buyProduct(
        //     sku: select,
        //     payload: order_num,
        //     func_success: buySuccess,
        //     func_fail: buyfail,
        //     func_cancel: onCancelled);
        googlepayobj.buyProduct(select,
            payload: order_num,
            func_success: buySuccess,
            func_fail: buyfail,
            func_cancel: onCancelled);
      }
      //支付回调
      //googlepayobj.buy(sku: select);
    } else {
      show(context, lang("调起支付失败") + failmsg);
    }
  }

  //创建订单
  _createorder(String sku) async {
    var postdata = {
      "pay_type": pay_type,
      "applepayId": sku,
      "type": type,
      'book_id': bookid,
      'section_id': secid
    };
    var tmp = await http(creat_order_api, postdata, gethead());
    var data = getdata(context, tmp);
    if (isnull(data)) {
      order_num = data['order_num'];
      sign_data.add("创建订单成功" + gettime() + "_" + order_num);
      reflash();
    } else {
      sign_data.add("创建订单失败" + gettime() + data);
    }
  }

  //取消订单
  _cancelorder() {
    if (debug) return;
    if (isnull(order_num)) {
      //取消订单

      http(cancel_order_api, {"pay_status": pay_status, "order_num": order_num},
          gethead());

      //记录日志
    }
  }

  _orderlog() {
    if (isnull(order_num)) {
      //取消订单
      http(
          order_log_api,
          {
            "pay_type": pay_type,
            "order_num": order_num,
            "applepayId": select,
            "sign_data": sign_data.toString()
          },
          gethead());

      //记录日志
    }
  }

  void isok([data]) {
    payok = true;
    reflash();
    sign_data.add("初始化googlePay成功" + gettime());
  }

  Future buySuccess([data]) async {
    //这里解析
    var json = jsonDecode(data);

    if (isnull(json)) {
      sign_data.add("googlePay成功,json解析成功" + gettime() + data);
      //解析成功回调服务器端接口验证
      //var tmp = {"purtoken":json["token"],"applepayId":json["sku"],"order_num":order_num,"g_orderid":json["orderid"]};
      var tmp = {
        "purtoken": json["token"],
        "applepayId": json["sku"],
        //"order_num": "2020010610441908367",
        "order_num": order_num,
        "g_orderid": json["orderid"]
      };
      var tmp2 = await http(order_sure_api, tmp, gethead());
      var tmp3 = getdata(context, tmp2);
      if (isnull(tmp3)) {
        //更新充值信息；弹出页面
        User.upcoin(tmp3['remainder']);
        reflash();
        pop(context);
      }
      sign_data.add("服务端回调结果" + gettime() + tmp2!);
    } else {
      sign_data.add("googlePay成功,json解析失败" + gettime() + data);
    }

    _orderlog();
    pop(context);
  }

  void initfail([data]) {
    // d("进入onFailure" + data);
    failmsg = data;
    sign_data.add("初始化googlePay失败" + gettime() + data);
    pop(context);
  }

  void initcancel([data]) {
    // d("进入onFailure" + data);
    failmsg = data;
    sign_data.add("初始化主动取消" + gettime() + data);
  }

  void buyfail([data]) {
    // d("进入onFailure" + data);
    failmsg = data;
    pay_status = 3;
    reflash();
    show(context, lang("支付失败") + failmsg);
    sign_data.add("google支付失败" + gettime() + order_num + failmsg);
    _cancelorder();
    _orderlog();
    pop(context);
  }

  void onCancelled([data]) {
    pay_status = 2;
    //d("进入onCancelled" + data);
    sign_data.add("取消支付" + gettime() + order_num + data);
    reflash();
    _cancelorder();
    _orderlog();
    pop(context);
  }

  static Future loadbox(BuildContext context, [Widget? body]) async {
    var body = StatefulBuilder(
      builder: (ctx, state) {
        // Down.reflash = state;
        // var point = Down.progress * 100;
        Widget theam = getloadobj(context);
        // ignore: deprecated_member_use
        return WillPopScope(
            child: Center(child: theam),
            onWillPop: () {
              return Future.value(false);
              // pop(context);
            });
      },
    );
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => body,
    );
    return await action;
  }

  static Widget getloadobj(BuildContext context) {
    var boxw = getScreenWidth(context);
    var boxh = getScreenHeight(context);
    var boxsize = boxw > boxh ? boxh : boxw;
    boxsize /= 2.5;
    var fontstyle = new TextStyle(
        color: SQColor.white,
        fontSize: 15.0,
        fontWeight: FontWeight.w100,
        letterSpacing: 0,
        height: 1,
        wordSpacing: 0,
        //fontStyle: FontStyle.italic,
        //textBaseline: TextBaseline.ideographic,
        decoration: TextDecoration.none);
    Widget loadc = Column(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: boxsize / 5,
              ),
              CircularProgressIndicator(
                //strokeWidth: 4.0,
                // backgroundColor: Colors.blue,
                //value: 0.0,
                valueColor: new AlwaysStoppedAnimation<Color>(SQColor.white),
              ),
              SizedBox()
            ],
          ),
        ),
        Expanded(
            child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: boxsize / 8,
              ),
              Container(
                //margin: const EdgeInsets.all(5.0),
                //padding: const EdgeInsets.all(5.0),
                child: Text(
                  lang('等待响应') + '...',
                  style: fontstyle,
                ),
              ),
              Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    lang('请勿操作'),
                    style: fontstyle,
                  ))
            ],
          ),
        )),
      ],
    );
    return Container(
        height: boxsize,
        // width: boxsize,
        decoration: new BoxDecoration(
          //背景
          //color: Colors.blue,
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          //设置四周边框
          //border: new Border.all(width: 1, color: Colors.red),
        ),
        child: loadc);
  }
}
