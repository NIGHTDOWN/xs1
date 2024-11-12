import 'dart:async';
// ignore: unused_import
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';

import 'function.dart';

class Ngsock {
  late Socket socket;
  wsscoket(String host, int port) async {
    try {
      //从server里面分割出host和port

      // 创建Socket连接
      socket = await Socket.connect(host, port);
      // 设置TCP_NODELAY选项
      // 发送数据到服务器
      login();
      socket.listen((data) async {
        print('Server response: ${String.fromCharCodes(data)}');
        srecv(data);
      });
    } on PlatformException catch (e) {
      d("Failed to load dex: '${e.message}'.");
      return "";
    }
  }

  login() {
    var sdata = {
      "type": "login",
      "data": {
        "uid": getuid(),
      }
    };
    var s = jsonEncode(sdata);
    ssend(s);
  }

  sendmsg() {
    var sdata = {
      "type": "login",
      "data": {
        "uid": getuid(),
      }
    };
    var s = jsonEncode(sdata);
    ssend(s);
  }

  ssend(String encodedata) async {
    // 发送数据到服务器
    socket.write(encodedata);
    // 等待服务器响应
    await socket.flush();
  }

  srecv(Uint8List data) async {
    String hex =
        data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
    print('Hex: $hex');
  }
}
