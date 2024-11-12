import 'dart:async';
// ignore: unused_import
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'function.dart';

//线程任务；先init任务函数；
//要启动好时任务；必须要产生至少一次send；才会触发
//线程对象
class Thred {
  SendPort? sendPort = null; //发送端口
  ReceivePort mainport = ReceivePort(); //接收端口
  late Isolate? _ioIsolate;
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
  }

  Future<Thred> init(Function call, [bool? asyn, bool isonce = false]) async {
    callback = call;
    if (isnull(asyn)) {
      _asyn = asyn!;
    }
    //启动所有线程，在延迟3秒同时执行
    var thredinfo = {
      'function': call,
      'receiveport': mainport.sendPort,
      'asyn': _asyn,
      'isonce': isonce,
    };
    _recv();
    _ioIsolate = await Isolate.spawn(startthred, thredinfo);

    // if (!isnull(sendPort)) {
    //   sendPort = await mainport.first as SendPort;
    // }
    //监听消息

    return this;
  }

  _recv() {
    if (isnull(mainport)) {
      mainport.listen((msg) {
        if (isnull(sendPort)) {
          _recvdata.add(msg);
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

  static void startthred(var thredinfo) async {
    // RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    // BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    //线程体
    final mport = new ReceivePort();
    //绑定
    Function call = thredinfo['function'];
    SendPort snedport = thredinfo['receiveport'];
    bool asyn = thredinfo['asyn'];
    bool isonce = thredinfo['isonce'];
    snedport.send(mport.sendPort);
    if (isonce) {
      //直接运行子任务
      var back;

      if (asyn) {
        back = await call();
      } else {
        back = call();
      }
      snedport.send(back);
    } else {
      mport.listen((message) async {
        //常驻内存；获取参数每次执行
        //获取数据并解析

        if (isnull(message)) {
          var back;
          if (asyn) {
            back = await call(message);
          } else {
            back = call(message);
          }
          snedport.send(back);
        }
      });
    }
    //监听
  }

  static Future<Thred> run(var paramdata, Function call) async {
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    // d(rootIsolateToken.toString());
    var t = Thred();
    await t.init((data) => {call(data)}, false);
    await Future.delayed(Duration(seconds: 2));
    var args = {
      'data': paramdata,
      'rootIsolateToken': rootIsolateToken,
    };
    t.send(args);
    return t;
  }
}
