import 'package:ng169/model/user.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/t.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/global.dart';

class Msg {
  // ignore: non_constant_identifier_names
  String fuid = '0';
  String msgid = '0';
  String tuid = '0';
  String type = '0';
  String sendtime = '0';
  String contenttype = '0';
  String content = '';
  bool flag = false;
  int id = 0;
  Msg.fromJson(Map<String, dynamic> data)
      : content = data['content'] ?? '',
        id = data['id'] ?? 0 {
    fuid = tostring(data['fuid']) ?? '';
    msgid = tostring(data['msgid']) ?? '';
    tuid = tostring(data['tuid']) ?? '';
    type = tostring(data['type']) ?? '0';
    flag = tobool(data['flag']);
    sendtime = tostring(data['sendtime']);
    contenttype = tostring(data['contenttype']);
  }
  Msg.fromhttpJson(Map<String, dynamic> data)
      : content = '',
        id = 0 {
    msgid = User.getuid().toString();
    if (data['type'] == null) {
      fuid = '0';
      tuid = msgid;
    } else {
      fuid = msgid;
      tuid = '0';
    }
    type = data['type']?.toString() ?? '0';
    id = int.parse(data['id']) ?? 0;
    sendtime = data['sendtime']?.toString() ?? '';
    contenttype = data['contenttype']?.toString() ?? '0';
    content = data['content'] ?? '';
  }
  savedb() async {
    var insert = {
      'fuid': fuid,
      'tuid': tuid,
      'type': type,
      'id': id,
      'sendtime': sendtime,
      'contenttype': contenttype,
      'content': content,
      'msgid': msgid,
    };
    var where = {
      'id': id,
    };
    var ins = await T('msg').where(where).getone();
    if (isnull(ins)) {
      //update
      T('msg').update(insert, where);
    } else {
      //add
      T('msg').add(insert);
    }
  }

  Msg.carete(int type, String text) {
    if (isnull(text)) {
      var uid = User.getuid().toString();
      fuid = uid;
      msgid = uid;
      tuid = '0';
      sendtime = gettime();
      contenttype = type.toString();
      content = text;
    }
  }
  send() async {
    //http发送成功在入库
    var tmp = await http(
        'chat/send',
        {
          'contenttype': contenttype,
          'content': content,
        },
        gethead());
    var data = getdata(g('context'), tmp!);
    var insert;
    if (isnull(data)) {
      //发送成功
      insert = {
        'fuid': fuid,
        'msgid': msgid,
        'tuid': tuid,
        'type': type,
        'sendtime': sendtime,
        'contenttype': contenttype,
        'content': content,
        'flag': 0,
        'id': data //插入后台id
      };
      T('msg').add(insert);
    } else {
      //发送失败
      insert = {
        'fuid': fuid,
        'msgid': msgid,
        'tuid': tuid,
        'type': type,
        'sendtime': sendtime,
        'contenttype': contenttype,
        'content': content,
        'flag': 1,
      };
      T('msg').add(insert);
    }
    //http 发送
    return insert;
  }

  static cheack() async {
    if (!User.islogin()) return false;
    //10秒只能一次
    var checktmp = await http('chat/havemsg', {}, gethead(), 60);
    var check = getdata(g('context'), checktmp ?? "");
    // d(check);
    if (isnull(check)) {
      //不为空才保存
      s('msg', check);
    }

    return check;
    //if (isnull(check)) {}
  }

  static clearread() {
    if (!User.islogin()) return false;
    d('调用');
    setcache('msg', 0, '0');
    return;
  }
}
