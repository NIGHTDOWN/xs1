//通知栏回调处理器

import 'package:flutter/cupertino.dart';
import 'package:ng169/tool/down.dart';
import 'package:ng169/tool/function.dart';

class Notifyfunction {
  BuildContext context;
  String args;
  String function;
  Notifyfunction(context, function) {
    this.context = context;
    this.function = function;
    this.args = getcache(function);
    this.exec();
  }
  exec() {
    switch (this.function) {
      case 'install_upapk':
        this.install_upapk();
        break;
      default:
    }
  }

  install_upapk() {
    Down.open(this.args);
  }
}
//设置上下文
