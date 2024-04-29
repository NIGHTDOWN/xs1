import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/style/theme.dart' as indextheme;
import 'package:ng169/tool/global.dart';
import 'function.dart';

class Bow extends StatelessWidget {
  const Bow({Key? key, required this.url, required this.title, this.needtoken = false})
      : super(key: key);

  final String url;
  final String title;
  final bool needtoken;
  static var isload = true;
  @override
  Widget build(BuildContext context) {
    loadwebviewlisten();
    String langs = "?lang=" + getlang();
    if (needtoken) {
      var user = User.get();
      if (isnull(user)) {
        langs += "&uid=" + User.getuid().toString();
        langs += "&token=" + user['token'];
      }
    }
    var web = new WebviewScaffold(
      url: url + langs,
      // userAgent: "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ng169.com",
      withLocalStorage: true,
      appBar: !isnull(title)
          ? null
          : new AppBar(
              title: new Text(title),
            ),
    );
    var ret = Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: Bow.isload ? 2 : 0,
        child: LinearProgressIndicator(
          backgroundColor: indextheme.Theme.loginGradientEnd,
          valueColor:
              AlwaysStoppedAnimation(indextheme.Theme.loginGradientStart),
          // valueColor: ColorTween(begin: Colors.blue, end: Colors.green).animate(_controller),
        ),
      ),
    );
    var body = Column(
      children: <Widget>[
        Expanded(
          child: web,
        ),
        ret,
      ],
    );

    // ignore: deprecated_member_use
    return WillPopScope(
      child: Scaffold(
        // appBar: PreferredSize(
        //   child: AppBar(
        //     title: Text(title,
        //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
        //     elevation: 0,
        //   ),
        //   preferredSize: Size.fromHeight(44),
        // ),
        body: Center(
          child: body,
        ),
      ),
      onWillPop: () {
        //print("返回键点击了");
        //Navigator.pop(context);
        Bow.close(context);
        return Future.value(false);  
      },
    );
    // return SafeArea(
    //   child: body,

    // );
  }

  loadwebviewlisten() {
    var flutterWebviewPlugin = new FlutterWebviewPlugin();
    // flutterWebviewPlugin.onUrlChanged.listen(fblogin2);
    // var _onStateChanged =
    flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (state.type == WebViewState.finishLoad) {
        Bow.isload = false;
      }
    });
  }

  static close(BuildContext context) {
    FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.close();
    Navigator.of(context).pop(1);
  }
}