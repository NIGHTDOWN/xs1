//通知栏回调处理器

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ng169/page/commect/kefu.dart';
import 'package:ng169/tool/down.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/im.dart';
import 'package:ng169/tool/url.dart';

class Notifyfunction {
  late BuildContext context;
  String args = "";
  String function = "";
  Notifyfunction(context, NotificationResponse plod) {
    this.context = context;

    this.function = plod.payload ?? "";
    this.args = getcache(function);
    this.exec();
  }
  exec() {
    switch (this.function) {
      case 'install_upapk':
        this.install_upapk();
        break;
      case 'go_msg':
        this.go_msg();
        break;
      default:
        break;
    }
  }

  install_upapk() {
    Down.open(this.args);
  }

  go_msg() async {
    d("tiaoyemian");
    await gourl(context, Kefu());
    Im.immsgflag(0);
  }
}
//设置上下文
