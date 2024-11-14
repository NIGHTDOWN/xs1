import 'dart:async';
import 'dart:convert';
import 'package:ng169/model/user.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/ngsock.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'global.dart';

class Im {
  late WebSocketChannel _channel;
  late final String _serverUrl;
  bool _isConnected = false;
  late Timer _heartbeatTimer;

  StreamController<String> _messageController = StreamController<String>();

  Stream<String> get messageStream => _messageController.stream;

  Im(_serverUrl) {
    this._serverUrl = _serverUrl;
    _startConnection();
    //如果连接成功就登入
    login();
    // 启动心跳定时器
    _heartbeatTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      // 发送心跳消息
      sendMessage('{"action": "heartbeat"}');
    });
  }
  login() {
    var data = {
      "action": "login",
      "data": {
        "uid": getuid(),
      }
    };
    var s = jsonEncode(data);
    sendMessage(s);
  }

// 重连方法
  void _reconnect() {
    if (!_isConnected) {
      _isConnected = false;
      // 可以设置一个延迟来避免立即重连导致的快速失败
      Future.delayed(Duration(seconds: 1), () {
        _startConnection();
      });
    }
  }

  void _startConnection() async {
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(_serverUrl));
      _isConnected = true;
      _channel.stream.listen((data) {
        _messageController.add(data);
      }, onError: (error) {
        d('连接错误: $error');
        _reconnect(); // 尝试重连
      }, onDone: () {
        d('WebSocket 连接已关闭');
        _reconnect(); // 尝试重连
      });
    } catch (e) {
      d('连接异常错误: $e');
    }
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void dispose() {
    // _channel.sink.close();
    // _messageController.close();
  }
  sendmsg(var postdata) {
    var data = {
      "action": "msg",
      "data": {
        "msgnum": "1",
        "msg": postdata,
        "uid": getuid(),
      }
    };
    var s = jsonEncode(data);
    sendMessage(s);
  }

//获取ws ip；
////建立链接
  ///监听事件
  static Future<Im?> init() async {
    var data = await http("im/getws");
    var tdata = Bgetdata(data);
    if (!isnull(tdata)) return null;
    var ip = tdata['ip'];
    var port = tdata['port'];
    var url = tdata['url'];
    Im im = Im(url);
    s("im", im);
    im.messageStream.listen((message) {
      print('收到消息3：$message');
      Im.msg_on(message);

// bar_im_on
    });
    return im;
  }

  static msg_on(msg) {
    //判断当前用户界面是否聊天窗口界面
    var msg2 = jsonDecode(msg);
    // d("消息解析失败丢弃");
    if (!isnull(msg2)) return;
    if (!User.islogin()) return false;
    if (msg2['action'] == 'adminmsg') {
      var realmsg = msg2['data'];
      if (!isnull(g("inmsgpage"))) {
        int msgnum = toint(g("msg"));
        msgnum += 1;
        s("msg", msgnum);
        eventBus.emit('bar_im_on', realmsg); //底部bar状态图标
        //用户页面状态图标
        eventBus.emit('user_im_on', realmsg);
      } else {
        //直接更新消息页面
        eventBus.emit('msg_im_on', realmsg);
      }
    } else {
      //其他类型系统消息不处理
    }

    // //消息页面状态图标
    // eventBus.emit('msg_im_on', msg);
  }
}
