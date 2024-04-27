import 'package:flutter/material.dart';
import 'package:ng169/page/app.dart';

import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';

import 'package:ng169/style/theme.dart' as indextheme;
import 'package:ng169/tool/power.dart';
import 'package:ng169/conf/conf.dart';

Future main() async {
  //flutter 1.9必须执行 WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  checkpower();
  // if (!await Power.requestPermissions()) {
  //   //检查权限
  //   //  await AppUtils.popApp();
  // } else {}

  // runApp(new MyApp());
  i().then((data) {
    //加载缓存
    //加载sql

    runApp(new MyApp());
  });
}

checkpower() async {
  await Power.requestPermissions();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget app=new SizedBox();
    s('context', context);

    try {
      app = new MaterialApp(
        debugShowCheckedModeBanner: isdebug, //关闭debug标志
        title: lang('LookStory'),
        theme: new ThemeData(
          // primarySwatch: indextheme.Theme.loginGradientStart,
          // primarySwatch: Colors.black,
          primaryColor: indextheme.Theme.appbar,
        ),
        home: new App(),
        // localeResolutionCallback: (deviceLocale, supportedLocales) {
        //  d('deviceLocale: $deviceLocale');

        //   s('locallg', deviceLocale);
        // },
        // home: new StartPage()
      );
    } catch (e) {
      d(e);
    }
    return app;
  }
}
