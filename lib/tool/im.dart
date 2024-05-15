import 'dart:async';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Im {
  Im() {
    init();
  }
  WebSocketChannel? _channel;
  // 连接WebSocket服务器
  Future<void> connect(String url) async {
    // if (_channel != null && _channel.closeCode) {
    if (_channel != null) {
      print('WebSocket is already open, not reconnecting');
      return;
    }
    _channel = WebSocketChannel.connect(Uri.parse(url));
    await _channel?.ready;
    _channel!.stream.listen(
      (message) {
        // 收到消息时的处理
        print('Received: $message');
      },
      onDone: () {
        // 连接关闭时的处理
        print('WebSocket is closed');
        _channel = null;
      },
      onError: (error) {
        // 连接发生错误时的处理
        print('WebSocket error: $error');
        _channel = null;
      },
    );
  }

  // 发送消息到WebSocket服务器
  Future<void> send(String message) async {
    if (_channel != null) {
      _channel!.sink.add(message);
    } else {
      print('WebSocket is not open, cannot send message');
    }
  }

  // 关闭WebSocket连接
  Future<void> close() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
  }

//获取ws ip；
////建立链接
  ///监听事件
  static Future<void> init() async {
    d("加载im信息");
    var data = await http("im/getws");
    d(data);
  }
}
