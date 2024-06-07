import 'dart:async';

// import 'package:intent/intent.dart' as inters;
// import 'package:intent/action.dart' as intersaction;

import 'package:flutter/services.dart';

import 'package:ng169/model/user.dart';
import 'package:receive_intent/receive_intent.dart';

// import 'package:url_launcher/url_launcher.dart';

import 'function.dart';

class ListenClip {
  static ListenClip? _instance = null;
  ListenClip() {}
// class _ListenClip {
  // 声明一个静态的 late 变量

  bool flag = false;
  int seconds = 0;

  // 私有构造函数

  start(var b) {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (flag) {
        timer.cancel(); // 取消重复计时
        return;
      }
      ListenClip.getClipboardContents();
      // getClipboardContents();
      // d('剪切板' + ListenClip().seconds.toString());
      // if (g('gstat') != AppLifecycleState.paused) {
      //   ListenClip().seconds++; // 秒数+1
      //   // setcache(timecachename, seconds, '-1');
      // }
    });
  }

  end() {
    flag = true;
  }

  /// 使用异步调用获取系统剪贴板的返回值。
  static getClipboardContents() async {
    // 访问剪贴板的内容。
    var user = User.get();
    if (!isnull(user)) {
      //用户未登入
      return false;
    }

    if (isnull(user, 'invite_id')) {
      //用户已经绑定
      if (isnull(_instance)) {
        _instance!.end();
      }

      return false;
    }

    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    // 剪贴板不为空时。
    if (clipboardData != null && clipboardData.text!.trim() != '') {
      String _name = clipboardData.text!.trim();
      // 淘口令的正则表达式，能判断类似“￥lookstory￥123456￥”的文本。
      // d(RegExp(r'[\uffe5]lookstory[\uffe5]+.+[\uffe5]').hasMatch(_name));
      RegExp reg = new RegExp(r'[\uffe5]lovenovel[\uffe5]+(\d+)[\uffe5]');
      d('剪切板数据监听');
      String? getid;
      if (reg.hasMatch(_name)) {
        Iterable<Match> matches = reg.allMatches(_name);

        for (Match m in matches) {
          getid = m.group(1);
          // print(m.group(0));
          // print(m.group(1));
        }
        if (!isnull(getid)) {
          //参数获取失败
          _instance!.clear();
          return false;
        }
        if (User.getuid().toString() == getid) {
          //id跟自己相同
          _instance!.clear();
          return false;
        }
        _instance!.clear();
        User.bindinvite(getid!);
        //绑定用户id
        // ListenClip().open();
        // 处理淘口令的业务逻辑。
        // showDialog<Null>(
        //   context: g('context'),
        //   barrierDismissible: true,
        //   builder: (BuildContext context) {
        //     //清空
        //     Clipboard.setData(new ClipboardData(text: ''));
        //     //

        //     return CupertinoAlertDialog(
        //       title: Text('淘口令'),
        //       content: GestureDetector(
        //           child: Text(_name),
        //           onTap: () {
        //             ListenClip().open();
        //           }),
        //     );
        //   },
        // );
      }
    }
  }

  clear() {
    Clipboard.setData(new ClipboardData(text: ''));
  }

// ignore: unused_field
  late StreamSubscription _intentSub;
  open() async {
    await ReceiveIntent.setResult(kActivityResultOk, data: {
      "scheme": "lovenovel",
      "host": 'com.ng.lovenovel',
      "path": "456"
    });
    // inters.Intent()
    //   ..setAction(intersaction.Action.ACTION_VIEW)
    //   ..setData(Uri(scheme: "lookstory", host: 'com.ng.lovenovel', path: "456"))
    //   ..startActivity().catchError((e) => d(e));
// Listen to media sharing coming from outside the app while the app is in the memory.
    // _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
    //   // setState(() {
    //   //   _sharedFiles.clear();
    //   //   _sharedFiles.addAll(value);

    //   //   print(_sharedFiles.map((f) => f.toMap()));
    //   // });
    // }, onError: (err) {
    //   print("getIntentDataStream error: $err");
    // });

    // // Get the media sharing coming from outside the app while the app is closed.
    // ReceiveSharingIntent.getInitialMedia().then((value) {
    //   // setState(() {
    //   //   _sharedFiles.clear();
    //   //   _sharedFiles.addAll(value);
    //   //   print(_sharedFiles.map((f) => f.toMap()));

    //   //   // Tell the library that we are done processing the intent.
    //   //   ReceiveSharingIntent.reset();
    //   // });
    //   ReceiveSharingIntent.reset();
    // });
  }
  //检测到了数据之后，
  //持续等待到本次完成，
  //检测完成后覆盖剪切板数据
}
