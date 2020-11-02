import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'function.dart';

//app不适合测速并发，线程太多加卡死。
//并发线程
class Supervene {
  //启动线程
  //执行任务
  static init(int threadlength, Function call) async {
    //启动所有线程，在延迟3秒同时执行

    var time = (int.parse(gettime()) + threadlength + 13).toString() + '000';
    //延迟10秒
    var send = {'time': time, 'fun': call};

    for (var i = 0; i < threadlength; i++) {
      Isolate.spawn(testthred, send);
    }
  }

  static testthred(var threddataobj) async {
    // d('时间戳' + satrttime);
    //var threddataobj = jsonDecode(threddata);
    String satrttime = threddataobj['time'];
    Function fun = threddataobj['fun'];
    var time;
    // d(getmirtime());
    time = Timer.periodic(Duration(microseconds: 1), (data) {
      // d(data);
      // d(sendPort);
      // d(getmirtime());
      if (int.parse(getmirtime()) >= int.parse(satrttime)) {
        //d(fun);
        d('执行时间' + getmirtime());
        fun();

        // exit(1); //退出线程
        time.cancel();
      }
    });
  }
}
