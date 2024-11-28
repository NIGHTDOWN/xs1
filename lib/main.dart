import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/page/app.dart';

import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';

import 'package:ng169/style/theme.dart' as indextheme;
import 'package:ng169/tool/power.dart';
import 'package:ng169/conf/conf.dart';

import 'page/startpage/satrtpage.dart';

Future main() async {
  //flutter 1.9必须执行 WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  checkpower();

  i().then((data) {
    // 加载缓存
    // 加载sql
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: false);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
    ));
    Widget w = MyApp();
    runApp(w);
  });
}

checkpower() async {
  await Power.requestPermissions();
  // await i();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget app = new SizedBox();
    s('context', context);
    // try {
    app = new MaterialApp(
        debugShowCheckedModeBanner: isdebug, //关闭debug标志
        title: lang('LoveNovel'),
        theme: new ThemeData(
          // primarySwatch: indextheme.Theme.loginGradientStart,
          // primarySwatch: Colors.black,
          primaryColor: indextheme.Theme.appbar,
        ),
        // home: new App(),
        // localeResolutionCallback: (deviceLocale, supportedLocales) {
        //  d('deviceLocale: $deviceLocale');

        //   s('locallg', deviceLocale);
        // },

        home: new StartPage());
    // } catch (e) {
    //   d(e);
    // }
    return app;
  }
}
