import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ng169/page/mall/mall.dart';

import 'package:ng169/style/sq_color.dart';

import 'package:ng169/tool/function.dart';

import 'package:ng169/tool/http.dart';

import 'package:ng169/tool/url.dart';

import '../app.dart';

//登入页面
class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  // AnimationController
  //     _controller; //AnimationController是Animation的一个子类，它可以控制Animation，可以控制动画的时间，类型，过渡3曲线
  // Animation _animation;
  final period = const Duration(seconds: 1);
  final api = 'common/begin_advert';
  int count = 3; //倒计时3秒
  Widget img = SizedBox();
  @override
  void initState() {
    new Mall(); //这里是预加载app；
    getimg();
    gethttpimg();
    Timer.periodic(period, dsq);
    super.initState();
  }

  dsq(timer) {
    count--;
    reflash();
    if (count <= 0) {
      //取消定时器，避免无限回调
      goindex();
      timer.cancel();
      timer = null;
    }
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  getimg() {
    //取缓存图片，缓存有就读缓存
    //没缓存就是静态资源
    hidetitlebar();
    var startpage = getcache('startpage');
    if (isnull(startpage) && isnull(startpage['advert_pic'])) {
      // img = Image.asset(
      //   'assets/images/startpage.png',
      //   fit: BoxFit.cover,
      // );

      img = Image.network(
        startpage['advert_pic'],
        fit: BoxFit.cover, //图片铺满
        scale: 2.0, //进行缩放
      );
    } else {
      img = Image.asset(
        'assets/images/startpage.png',
        fit: BoxFit.cover,
      );
    }
  }

  gethttpimg() {
    //加载服务器图片资源
    //保存到本地
    http(api, {}, gethead()).then((onValue) {
      //保存成缓存
      var tmpdata = getdata(context, onValue);
      if (isnull(tmpdata)) {
        //setcache('startpage', tmpdata, '-1');
      }
    });

    // switch (int.parse(info['api'])) {
    //       case 1:
    //         //浏览器
    //         gourl(context, new Bow(url: info['url'], title: info['title']));
    //         break;
    //       default:
    //         gourl(
    //             context, new MallPage(api: info['url'], title: info['title']));
    //       //页面
    //     }
  }

  goindex() {
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) {
    //   return App();
    // }), (route) => route == null);
    // // pop(context);
    gourl(context, App());
  }

  @override
  void dispose() {
    // _controller.dispose(); //释放动画
    showtitlebar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = getScreenWidth(context) * 0.03;
    var h = getScreenHeight(context) * 0.03;
    return Scaffold(
      //透明度动画组件
      //opacity: _animation, //动画
      // child: Image.network(
      //   'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1546851657199&di=fdd278c2029f7826790191d59279dbbe&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F0112cb554438090000019ae93094f1.jpg%401280w_1l_2o_100sh.jpg',
      //   fit: BoxFit.cover, //图片铺满
      //   scale: 2.0, //进行缩放
      // ),
      body: Stack(fit: StackFit.expand, children: [
        img,
        Positioned(
          right: w,
          top: h,
          child: TextButton(
              // shape: CircleBorder(
              //   side: BorderSide(
              //     color: SQColor.btm,
              //   ),
              // ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return SQColor.btm;
                }),
                // foregroundColor: MaterialStateProperty.resolveWith((states) {
                //   return Styles.getTheme()['activefontcolor'];
                // }),
                // padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                shape: WidgetStateProperty.resolveWith((states) {
                  return CircleBorder(
                    side: BorderSide(
                      color: SQColor.btm,
                    ),
                  );
                }),
              ),
              onPressed: () {
                goindex();
              },
              // color: SQColor.btm,
              child: Text(
                '$count' + 's',
                style: TextStyle(color: SQColor.white),
              )),
        )
      ]),
    );
  }
}
