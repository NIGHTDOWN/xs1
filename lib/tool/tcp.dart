import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';


import 'function.dart';

class Tcp {
  late IOWebSocketChannel channel;
  late Function callbacks;

  // Tcp(String ws) {
  //   open(ws);
  // }
  open(ws) {
    d('开启sock');
    this.channel = new IOWebSocketChannel.connect(ws);
    //IOWebSocketChannel.connect
    //this.channel.sink.add('test');
  }

  send(data) {
    d(data);
    d(this.channel.sink);
    this.channel.sink.add(data);
  }

  listen() {
    // unreachable
    d('绑定数据接收');
    StreamBuilder(
      stream: this.channel.stream,
      builder: (context, snapshot) {
        // ignore: unnecessary_null_comparison
        if (snapshot.hasData && null != callbacks) {
          this.callbacks(snapshot.data);
        }
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            d('Select lot');
            break;
          case ConnectionState.waiting:
            d('Awaiting bids...');
            break;
          case ConnectionState.active:
            d('\$${snapshot.data}');
            break;
          case ConnectionState.done:
            d('\$${snapshot.data} (closed)');
            break;
        }
        return SizedBox();
        //return Text(snapshot.hasData ? '${snapshot.data}' : '');
      },
    );
  }

  recv(Function fun) {
    callbacks = fun;
  }

  close() {
    this.channel.sink.close();
  }
}

class MessageUtils {
  static WebSocket? _webSocket;
  // ignore: unused_field
  static num _id = 0;

  static void open(ws) {
    d(ws);
    //protocols

//     User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like
//  Gecko) Chrome/76.0.3809.100 Safari/537.36

// Origin: http://localhost:8080

// Accept-Encoding: gzip, deflate
// Accept-Language: zh-CN,zh;q=0.9
// Sec-WebSocket-Key: iwxAW58ls/qeWMycVr2Sag==
// Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits
    // var head = {
    //   'User-Agent': 'ng169',
    //   // 'Origin': 'http://sss:8080',
    //   'Accept-Encoding': 'deflate',
    //   'Accept-Language': 'zh-CN,zh;q=0.9',
    // };
    Future<WebSocket> futureWebSocket =
        WebSocket.connect(ws); // Api.WS_URL 为服务器端的 websocket 服务
    futureWebSocket.then((WebSocket ws) {
      _webSocket = ws;
      _webSocket?.readyState;
      // send('sdfsdf');
      // 监听事件
      void onData(dynamic content) {
        _id++;
        // _sendMessage("收到");
        // _createNotification("新消息", content + _id.toString());
      }

      _webSocket?.listen(onData,
          onError: (a) => print("error"), onDone: () => print("done"));
    });
  }

  static void closeSocket() {
    _webSocket?.close();
  }

  // 向服务器发送消息
  static void send(String message) {
    d(message);
    //_webSocket.add('0x1');
    _webSocket?.add(message);
  }

  //接收数据
  static void g(String message) {
    _webSocket?.add(message);
  }
  // 手机状态栏弹出推送的消息
  // static void _createNotification(String title, String content) async {
  //   await LocalNotifications.createNotification(
  //     id: _id,
  //     title: title,
  //     content: content,
  //     onNotificationClick: NotificationAction(
  //         actionText: "some action",
  //         callback: _onNotificationClick,
  //         payload: "接收成功！"),
  //   );
  // }

  // static _onNotificationClick(String payload) {
  //   LocalNotifications.removeNotification(_id);
  //   _sendMessage("消息已被阅读");
  // }
}
