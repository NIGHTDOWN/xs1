import 'dart:async';
// ignore: unused_import
import 'dart:convert';
import 'dart:isolate';

import 'function.dart';

//线程对象
class Thred {
  late SendPort sendPort; //发送端口
  ReceivePort getPort = ReceivePort(); //接收端口
  late Isolate _ioIsolate;
  List _recvdata = [];
  bool _asyn = false;
 late Function callback;
  //杀死线程
  kill() {
    _ioIsolate.kill(priority: Isolate.immediate);
    _ioIsolate = Null as Isolate;
  }

  Future<Thred> init(Function call, [bool? asyn]) async {
    callback = call;
    if (isnull(asyn)) {
      _asyn = asyn!;
    }
    //启动所有线程，在延迟3秒同时执行
    var thredinfo = {
      'function': call,
      'receiveport': getPort.sendPort,
      'asyn': _asyn
    };

    _ioIsolate = await Isolate.spawn(startthred, thredinfo);

    // if (!isnull(sendPort)) {

    //   sendPort = await getPort.first as SendPort;
    // }
    //监听消息
    _recv();
    return this;
  }

  _recv() {
    if (isnull(getPort)) {
      getPort.listen((msg) {
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
    // d((sendPort));
    // d(isnull(sendPort));
    if (isnull(sendPort)) {
      sendPort.send(message);
    }
  }

  static void startthred(var thredinfo) async {
    //线程体
    final port = new ReceivePort();
    //绑定
    Function call = thredinfo['function'];
    SendPort snedport = thredinfo['receiveport'];
    bool asyn = thredinfo['asyn'];
    snedport.send(port.sendPort);
    //监听

    port.listen((message) async {
      //获取数据并解析
      if (isnull(message)) {
        // Function call = message['function'];
        // var msg = message['msg'];
        // bool asyn = message['asyn'];
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
}
