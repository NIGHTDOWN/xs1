import 'dart:async';
// ignore: unused_import
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/im.dart';

import 'function.dart';

//线程任务；先init任务函数；
//要启动好时任务；必须要产生至少一次send；才会触发
//线程对象
class Thredim {
  SendPort? sendPort = null; //发送端口
  ReceivePort mainport = ReceivePort(); //接收端口
  late Isolate? _ioIsolate;
  static Isolate? isIslocateRunning;
  List _recvdata = [];
  bool _asyn = false;
  late Function callback;
  SendPort? childport; //子线程发送端口
  SendPort? partantport; //父进程发送端口
  //杀死线程
  kill() {
    mainport.close();
    _ioIsolate!.kill(priority: Isolate.immediate);
    _ioIsolate = null;
    // isstop();
  }

  Future<Thredim> init(Function call, [bool? asyn, bool isonce = false]) async {
    callback = call;
    if (isnull(asyn)) {
      _asyn = asyn!;
    }
    //启动所有线程，在延迟3秒同时执行
    var thredinfo = {
      'function': call,
      'receiveport': mainport.sendPort,
      'asyn': _asyn,
      'isonce': isonce, //是否只执行一次
    };
    _recv();
    _ioIsolate = await Isolate.spawn(startthred, thredinfo);
    isIslocateRunning = _ioIsolate;
    // _ioIsolate!.addErrorListener((v) {} as SendPort);
    // _ioIsolate!.addErrorListener();
    // isstart();
    //监听消息

    return this;
  }

  static String imflag = "imflag";
  static isstart() {
    setcache(imflag, "1", "-1");
  }

  static isstop() {
    setcache(imflag, "0", "-1");
  }

  static getflag() {
    return getcache(imflag);
  }

  _recv() {
    if (isnull(mainport)) {
      mainport.listen((msg) {
        // d("线程收到消息：$msg");
        if (isnull(sendPort)) {
          _recvdata.add(msg);
          if (isnull(msg)) {
            Im.msg_on(msg);
          }
        } else {
          sendPort = msg as SendPort;
        }
      });
    }
  }

  getinfo() {
    return _recvdata;
  }

  send(message) {
    if (isnull(sendPort)) {
      sendPort!.send(message);
    } else {}
  }

  login(tmpuid) {
    var msg = {"call": "login", 'data': tmpuid};
    send(msg);
  }

  sendmsg(var postdata) {
    var msg = {"call": "sendmsg", 'data': postdata};
    send(msg);
  }

  static late Im? imobj = null;
  static SendPort? snedport;
  //子进程给父进程发消息
  static sendtoPartent(msg) {
    if (isnull(snedport)) {
      d("snedport是空");
      return;
    }
    snedport!.send(msg);
  }

  static void startthred(var thredinfo) async {
    //线程体
    final mport = new ReceivePort();
    //绑定
    Function call = thredinfo['function'];
    snedport = thredinfo['receiveport'];
    bool asyn = thredinfo['asyn'];

    snedport!.send(mport.sendPort);
    if (true) {
      //直接运行子任务
      mport.listen((message) async {
        //常驻内存；获取参数每次执行
        var back;
        if (!isnull(imobj)) {
          RootIsolateToken rootIsolateToken = message['rootIsolateToken'];
          BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
          //初始化缓存
          await isolocateinit();
          imobj = await Im.init(isthred: true);
          imobj?.call = (msg) => {snedport!.send(msg)};
          snedport?.send(back);
        } else {
          if (!isnull(message)) {
            return;
          }
          if (!isnull(message, "call")) return;
          String callfun = message["call"];
          var calldata = message["data"];
          if (callfun == "login") {
            imobj!.login(calldata);
          } else {
            // d(calldata);
            imobj!.sendmsg(calldata);
          }
        }
      });
    }
    //监听
  }

  static Future<Thredim> run(var paramdata, Function call) async {
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    // d(rootIsolateToken.toString());
    var t = Thredim();
    await t.init((data) => {call(data)}, false);
    await Future.delayed(Duration(seconds: 2));
    var args = {
      'data': paramdata,
      'rootIsolateToken': rootIsolateToken,
    };
    t.send(args);
    s("im", t);
    return t;
  }
}
