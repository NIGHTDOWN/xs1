import 'dart:async';
import 'dart:convert';
import 'package:ng169/model/user.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'global.dart';

class Im {
  late String ip;
  late String port;
  late String url;
  static int msgid = 1;
  static WebSocketChannel? _channel;
  final Map<int, Map> _messageQueue = {};
  Timer? _resendTimer;
  int _reconnectAttempts = 0; // 添加重连尝试计数器
  Im() {
    if (!isnull(Im._channel)) {
      init();
      d("启动定时器");
      _resetResendTimer();
    } else {
      return;
    }
  }
  bool isok() {
    return (isnull(Im._channel));
  }

  Future<void> _reconnect() async {
    if (_reconnectAttempts < 50) {
      // 限制重连尝试次数，避免无限重连
      await Future.delayed(Duration(seconds: 1), () {
        // 延迟重连，避免过于频繁
        _reconnectAttempts++;
        print('Reconnecting attempt $_reconnectAttempts');
        connect(); // 尝试重新连接
      });
    } else {
      print('Max reconnect attempts reached');
      // 可以在这里处理达到最大重连尝试后的行为，例如通知用户
    }
  }

  // 连接WebSocket服务器
  Future<void> connect() async {
    // String url;
    // if (_channel != null && _channel.closeCode) {
    if (Im._channel != null) {
      print('WebSocket is already open, not reconnecting');
      return;
    }
    url = "ws://" + ip + ":" + port + "/socket.io/?EIO=3&transport=websocket";
    // url =
    //     "ws://192.168.10.5:4563/socket.io/?EIO=3&transport=websocket&sid=9258795c2c93d94105ad5283";
    try {
      Im._channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      Im._channel = null;
      _reconnect(); // 如果连接失败，尝试重连
      dt(e);
    }
    void recvmsg(String message) {
      try {
        d(message);
        List<int> decodedBytes = base64Decode(message);
        message = String.fromCharCodes(decodedBytes);
        Map<String, dynamic> data = jsonDecode(message);
        d(data);
      } catch (e) {
        d(e);
      }
    }

    // await _channel?.ready;
    Im._channel!.stream.listen(
      (message) {
        // 收到消息时的处理
        d(message);
        recvmsg(message);
        // print('Received: $message');
        // d(message);
      },
      onDone: () {
        // 连接关闭时的处理
        print('WebSocket is closed');
        Im._channel = null;
        _reconnect(); // 如果连接正常关闭，尝试重连
      },
      onError: (error) {
        // 连接发生错误时的处理
        print('WebSocket error: $error');
        Im._channel = null;
        _reconnect(); // 如果发生错误，尝试重连
      },
    );
  }

  // 发送消息到WebSocket服务器
  Future<void> send(String message) async {
    if (Im._channel != null) {
      // Im._channel!.sink.add(message);
      _sendmsg(message);
    } else {
      print('WebSocket is not open, cannot send message');
    }
  }

  void lgoin() {
    int uid = User.getuid();
  }

  // 添加一个新的方法来处理消息确认
  void _messageConfirmed(int messageId) {
    // 从队列中移除已确认的消息
    _messageQueue.remove(messageId);
    // _messageQueue.removeWhere((msg) => jsonDecode(msg)['msgid'] == messageId);
  }

  void _resendMessages() {
    // 遍历队列，重发所有待确认的消息
    int rttime = toint(gettime());
    for (var entry in Map.from(_messageQueue).entries) {
      int vt = toint(entry.value["rttime"]);
      if ((rttime - vt) > 5) {
        // 如果消息超过5秒未确认，则重发
        entry.value["rttime"] = rttime;
        //重发
        d("重发");
        __sendmsg(entry.value);
      }
    }
  }

  // 重置并启动重发定时器
  void _resetResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _resendMessages();
    });
  }

  void _sendmsg(String data) {
    var tmpdata = {
      "touid": "0",
      "msgid": msgid++,
      "fromuid": tostring(User.getuid()),
      "time": gettime(),
      "rttime": gettime(),
      "msg": data,
    };
    //加入消息队列
    __sendmsg(tmpdata);
  }

  void __sendmsg(Map tmpdata) {
    //加入消息队列
    var js = jsonEncode(tmpdata);
    List<int> bytes = utf8.encode(js);
    // 对字节列表进行 Base64 编码
    String base64String = base64Encode(bytes);
    Im._channel!.sink.add(base64String);
  }

  // 关闭WebSocket连接
  Future<void> close() async {
    if (Im._channel != null) {
      await Im._channel!.sink.close();
      Im._channel = null;
    }
  }

//获取ws ip；
////建立链接
  ///监听事件
  Future<void> init() async {
    var data = await http("im/getws");
    var tdata = Bgetdata(data);
    if (!isnull(tdata)) return;
    ip = tdata['ip'];
    port = tdata['port'];
    url = tdata['url'];
    connect();
  }
}
