import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/msg.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/rack/rack.dart';
import 'package:ng169/page/user/me_scene.dart';
import 'package:ng169/pay/AdBridge.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/keeplive.dart';

import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/listenclip.dart';
import 'package:ng169/tool/notify.dart';
import 'package:ng169/tool/url.dart';
import 'package:uni_links/uni_links.dart';
import 'mall/mall.dart';
import 'package:ng169/obj/novel.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => AppSceneState();
}

class AppSceneState extends State<App> with WidgetsBindingObserver {
  int _tabIndex = 0;
  bool isFinishSetup = false;
  List<Widget> _tabImages = [
    Image.asset(
      'assets/images/tab_bookshelf_n.png',
      width: 24,
    ),
    // Icon(Icons.access_alarm),
    Image.asset(
      'assets/images/tab_bookstore_n.png',
      width: 24,
    ),
    Image.asset(
      'assets/images/tab_me_n.png',
      width: 24,
    ),
  ];
  List<Widget> _tabSelectedImages = [
    Image.asset(
      'assets/images/tab_bookshelf_p.png',
      width: 24,
      color: SQColor.primary,
    ),
    Image.asset(
      'assets/images/tab_bookstore_p.png',
      width: 24,
      color: SQColor.primary,
    ),
    // Image.asset('assets/images/tab_me_p.png',color: SQColor.primary,),

    Image.asset(
      'assets/images/tab_me_n.png',
      width: 24,
      color: SQColor.primary,
    ),
  ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //d('首次加载');
  }

  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   //d('更新组件');
  // }

  @override
  void deactivate() {
    super.deactivate();
    // d('切换页面');
  }

  reloadmsgnum() {
    setState(() {
      msgnum = toint(g("msg"));
    });
  }

// 系统窗口相关改变回调
  void didChangeMetrics() {
    super.didChangeMetrics();
    // d('切换窗口');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // d(state.toString());
    s('gstat', state);

    // globalKeys['listenclip'].send('1');
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。

        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        setcache(appstatus, '1', '0');
        reloadmsgnum();

        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        setcache(appstatus, '0', '0');
        break;
      // case AppLifecycleState.suspending: // 申请将暂时暂停
      //   break;
      case AppLifecycleState.detached:
        break;
      // case AppLifecycleState.hidden:
      // case AppLifecycleState.:
      //   break;
      // case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  dolink(String link) async {
    d('获取外部参数' + link);
    var data = formar_url(link);
    if (!isnull(data, 'action')) {
      // d('参数获取失败');
      return false;
    }
    String action = data['action'];
    var datatmp = data['data'];
    var user;
    switch (action) {
      case 'reg':
        //参数一个 pid
        if (!isnull(datatmp, 'pid')) {
          return false;
        }
        if (!User.islogin()) {
          await gourl(g('context'), Index());
          // return false;
        }
        user = User.get();
        if (!isnull(user)) {
          ts('请登入');
          return false;
        }
        String uid = User.getuid().toString();
        if (uid == datatmp['pid']) {
          ts('无法给自己助力哦！请分享给好友');
          return false;
        }
        if (isnull(user, 'invite_id')) {
          //不相同就弹出已经阻力过了
          String inviteid = user['invite_id'];
          if (datatmp['pid'] == inviteid) {
            ts('助力成功了');
          } else {
            // showbox(Text(
            ts('您已经助力过了');
            //   style: new TextStyle(
            //     decoration: TextDecoration.none,
            //     fontSize: 16.0,
            //     color: const Color(0xFF000000),
            //     fontWeight: FontWeight.w200,
            //   ),
            // ));
            // msgbox(g('context'), () {}, Text(lang('您已经助力过了')));
          }
          return false;
        }
        bool bind = await User.bindinvite(datatmp['pid']);
        //判断是否已经助力了，如果助力id跟当前参数id一样就弹出成功
        if (bind) {
          ts('助力成功了');
          return true;
        } else {
          ts('助力失败了！');
          return false;
        }

      case 'read':
        //跳转到阅读页面内 参数三个，type ， bookid(必要) ，secid

        if (!isnull(datatmp, 'bookid')) {
          return false;
        }
        if (!isnull(datatmp, 'type')) {
          return false;
        }
        Novel novel = await Novel.fromID(
            int.parse(datatmp['bookid']), int.parse(datatmp['type']));
        if (isnull(novel)) {
          if (isnull(datatmp, 'secid')) {
            novel.read(context, int.parse(datatmp['secid']));
          } else {
            novel.read(context);
          }
        }
        // widget.novel.read(context, widget.novel.readChapter);
        //转到app印度页面
        return true;
      // default:
    }
  }

  //唤醒app
  void weakAPP() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // ignore: unused_local_variable, deprecated_member_use
    var _sub = getLinksStream().listen((String? data) {
      // 这里是处理数据的回调函数
      // 处理接收到的数据
      if (data != null) {
        dolink(data);
      }
    }, onDone: () {
      // 流完成时执行的操作
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      d('接受外部参数失败');
    });
  }

  ts(String str) {
    var bo = Container(
      padding: EdgeInsets.all(15),
      child: Center(
          child: Text(
        lang(str),
        style: new TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16.0,
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w200,
        ),
      )),
    );
    showbox(bo, SQColor.white);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册监听器
    showtitlebar();
    setupApp();
    weakAPP();
    msgnum = toint(g('msg'));

    loadbus();
    //这里开启监听剪切板
    // globalKeys['listenclip'].send('1');
    //ce
    // eventBus.on(EventUserLogin, (arg) {
    //   setState(() {});
    // });

    // eventBus.on(EventUserLogout, (arg) {
    //   setState(() {});
    // });

    // eventBus.on(EventToggleTabBarIndex, (arg) {
    //   setState(() {
    //     _tabIndex = arg;
    //   });
    // });
    ListenClip().start(true);
    checkversion(context, true);
    testandroid();
    cheack2();
  }

  testandroid() async {
    //延迟两分钟提交测试信息
    Future.delayed(Duration(minutes: 1), () async {
      // Future.delayed(Duration(seconds: 1), () async {
      //关闭loading
      var info = await User.gettestinfo();
      // d(g('reqtimes'));
      http('common/testandroid', {'data': info}, gethead());
    });
  }

  qiehuan(arg) {
    //书架刷新

    if (arg == 0) {
      titlebarcolor(true);
      setState(() {
        _tabIndex = arg;
      });
      // if (_tabIndex != arg) {
      //   //20分钟刷新一次缓存
      //   eventBus.emit('rfrack');
      //   _tabIndex = arg;
      //   //延迟刷新
      //   Future.delayed(Duration(milliseconds: 500), () {
      //     //关闭loading
      //     setState(() {});
      //   });
      // }
    } else if (arg == 2) {
      titlebarcolor(false);

      setState(() {
        _tabIndex = arg;
      });
    } else {
      titlebarcolor(false);
      setState(() {
        _tabIndex = arg;
      });
    }
  }

  @override
  void dispose() {
    ofbus();

    WidgetsBinding.instance.removeObserver(this); // 移除监听器
    super.dispose();
  }

  ofbus() {
    eventBus.off('EventToggleTabBarIndex');
    eventBus.off('bar_im_on');
  }

  setupApp() async {
    // preferences = await SharedPreferences.getInstance();
    // setState(() {
    //   isFinishSetup = true;
    // });
  }
  cheack2() async {
    var tmp2 = await http('chat/set', {}, gethead());
    var check3 = getdata(g('context'), tmp2);
    setcache('msg3', check3, '-1', false);
  }

  dir() async {
    //执行部分shell
    d(await AdBridge.call(
        'getreapp', {'com': "ls", 'dir': "/sdcard/Android/media"}));
  }

  @override
  Widget build(BuildContext context) {
    s('context', context);
    s('swidth', getScreenWidth(context));
    s('sheight', getScreenHeight(context));
    // User.gettestinfo()
    // AdBridge.call("getnet");
    // AdBridge.call("getnet");
    //加载通知栏
    Notify.init('app_icon');

    //  dir();
    var body = Scaffold(
      // appBar: null,
      body: IndexedStack(
        children: <Widget>[
          Rack(), //书架

          Mall(), //书城
          MeScene(), //我的资料
        ],
        index: _tabIndex,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: SQColor.white,
        activeColor: SQColor.primary,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: getTabIcon(0), label: lang('书架')),
          //     title: Text(
          //       lang('书架'),
          //       style: TextStyle(fontWeight: FontWeight.w600),
          //     )),
          BottomNavigationBarItem(icon: getTabIcon(1), label: lang('书城')),
          // title: Text(
          //   lang('书城'),
          //   style: TextStyle(fontWeight: FontWeight.w600),
          // )),
          BottomNavigationBarItem(
              icon: getTabIcon(2),
              // activeIcon: Text('data'),
              label: lang('我的')),
          // title: Text(
          //   lang('我的'),
          //   style: TextStyle(fontWeight: FontWeight.w600),
          // )),
        ],
        currentIndex: _tabIndex,
        onTap: (index) {
          qiehuan(index);
          // setState(() {
          //   _tabIndex = index;
          // });
        },
      ),
    );
    // return Center(
    //   child: Text("dsfsdf"),
    // );
    // ignore: deprecated_member_use
    return WillPopScope(
      child: body,
      onWillPop: () async {
        //回倒桌面
        // AdBridge.call('backDesktop');
        bool shouldPop = await AdBridge.call('backDesktop');
        return shouldPop; // 返回异步调用的结果
      },
    );
  }

  loadbus() {
    eventBus.on('EventToggleTabBarIndex', (arg) {
      qiehuan(arg);
    });
    eventBus.on("bar_im_on", (arg) {
      // d("dfsdsf");

      reloadmsgnum();
    });
  }

  int msgnum = 0;
  Widget getTabIcon(int index) {
    var ob;
    if (index == _tabIndex) {
      ob = _tabSelectedImages[index];
    } else {
      ob = _tabImages[index];
    }
    double size = 8;
    if (index == 2 && isnull(msgnum)) {
      ob = Stack(children: [
        // Text('ddd'),
        ob,
        isnull(msgnum)
            ? Positioned(
                right: 0,
                top: 0,
                child: ClipOval(
                  child:
                      Container(width: size, height: size, color: Colors.red),
                ))
            : Container()
      ]);
    }
    return ob;
  }
}
