import 'dart:async';
import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';


import 'package:ng169/style/theme.dart' as theme;
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/brige.dart';
import 'package:ng169/tool/cache.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';

import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';
// import 'package:url_launcher/url_launcher.dart';

///登入界面
class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  /// 利用FocusNode和FocusScopeNode来控制焦点
  /// 可以通过FocusNode.of(context)来获取widget树中默认的FocusScopeNode
  FocusNode emailFocusNode = new FocusNode();
  FocusNode passwordFocusNode = new FocusNode();
  FocusScopeNode focusScopeNode = new FocusScopeNode();
  TextEditingController username = new TextEditingController();
  TextEditingController pwd = new TextEditingController();
  bool cansubmit = true;
  GlobalKey<FormState> _signInFormKey = new GlobalKey();
  late  NgBrige ngbrige;
  late Map<String, String> fromdata;
  bool isShowPassWord = false;

  late BuildContext context;
  late NgCache cache;
  late String tmpfbcode;
  late FlutterWebviewPlugin flutterWebviewPlugin;
  // ignore: unused_field
  late StreamSubscription<WebViewStateChanged> _onStateChanged;
  // GoogleSignIn _googleSignIn;
  @override
  void initState() {

    super.initState();
    // _googleSignIn = GoogleSignIn(
    //   scopes: [
    //     'email',
    //     'https://www.googleapis.com/auth/contacts.readonly',
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    loadwebviewlisten();
    //flutterWebviewPlugin = new FlutterWebviewPlugin();

    //  监听页面滚动事件
// final flutterWebviewPlugin = new FlutterWebviewPlugin();
// flutterWebviewPlugin.onScrollYChanged.listen((double offsetY) {

// });
// flutterWebviewPlugin.getCookies().then((Map<String,String> _cookies){
//           print(_cookies);
//           _saveCookie();
//         });
// flutterWebviewPlugin.onScrollXChanged.listen((double offsetX) {

// });
// 复制代码
// 隐藏webview：

// final flutterWebviewPlugin = new FlutterWebviewPlugin();

// flutterWebviewPlugin.launch(url, hidden: true);
// 关闭webview：

// flutterWebviewPlugin.close();

    this.context = context;
    ngbrige = NgBrige.of(context)!;
    cache = g('cache');
    var positioned = new Positioned(
      child: buildSignInButton(),
      top: 170,
    );
    //忘记密码下面的or线条
    Padding padding = Padding(
      padding: EdgeInsets.only(top: 10),
      child: new Row(
//                          mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            height: 1,
            width: 100,
            decoration: BoxDecoration(
                gradient: new LinearGradient(colors: [
              Colors.white10,
              Colors.white,
            ])),
          ),
          new Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: new Text(
              "Or",
              style: new TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          new Container(
            height: 1,
            width: 100,
            decoration: BoxDecoration(
                gradient: new LinearGradient(colors: [
              Colors.white,
              Colors.white10,
            ])),
          ),
        ],
      ),
    );
    return new Container(
      padding: EdgeInsets.only(top: 23),
      child: new Stack(
        alignment: Alignment.center,
        //        /**
        //         * 注意这里要设置溢出如何处理，设置为visible的话，可以看到孩子，
        //         * 设置为clip的话，若溢出会进行裁剪
        //         */
        // fit:StackFit.expand,
        //  overflow: Overflow.clip,
        children: <Widget>[
          new Column(
            children: <Widget>[
              //创建表单
              buildSignInTextForm(),
              new SizedBox(
                height: 40,
              ),
              padding,
              new SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: _fb,
                child: new Container(
                  padding:
                      EdgeInsets.only(left: 42, right: 42, top: 10, bottom: 10),
                  margin: EdgeInsets.only(
                    left: 42,
                    right: 42,
                  ),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gradient: theme.Theme.primaryGradient,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          FontAwesomeIcons.facebookF,
                          color: Color(0xFF0084ff),
                          size: 20,
                        ),
                      ),
                      Text(
                        lang('Facebook登入'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              new SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: _google,
                child: new Container(
                  padding:
                      EdgeInsets.only(left: 42, right: 42, top: 10, bottom: 10),
                  margin: EdgeInsets.only(
                    left: 42,
                    right: 42,
                  ),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gradient: theme.Theme.primaryGradient,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          FontAwesomeIcons.google,
                          color: Color(0xFF0084ff),
                          size: 20,
                        ),
                      ),
                      Text(
                        lang('google登入') + "   ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded(
              //   child: new Column(
              //     children: <Widget>[
              //       Padding(
              //         padding: const EdgeInsets.only(top: 50),
              //         child: new Text(
              //           lang('Forgot Password') + "?",
              //           style: new TextStyle(
              //               fontSize: 16,
              //               color: Colors.white,
              //               decoration: TextDecoration.underline),
              //         ),
              //       ),
              //       padding,
              //       /**
              //  * 显示第三方登录的按钮
              //  */
              //       new SizedBox(
              //         height: 10,
              //       ),
              //       new Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: <Widget>[
              //           new Container(
              //             padding: EdgeInsets.all(10),
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               color: Colors.white,
              //             ),
              //             child: new IconButton(
              //                 icon: Icon(
              //                   FontAwesomeIcons.facebookF,
              //                   color: Color(0xFF0084ff),
              //                 ),
              //                 onPressed: _fb),
              //           ),
              //           new SizedBox(
              //             width: 40,
              //           ),
              //           new Container(
              //             padding: EdgeInsets.all(10),
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               color: Colors.white,
              //             ),
              //             child: new IconButton(
              //                 icon: Icon(
              //                   FontAwesomeIcons.google,
              //                   color: Color(0xFF0084ff),
              //                 ),
              //                 onPressed: _google),
              //           ),
              //         ],
              //       )
              //     ],
              //   ),
              // )
            ],
          ),
          positioned
        ],
      ),
    );
  }

  _fb() async {
    // keytool -exportcert -alias key -keystore d:\\key.jks | openssl sha1 -binary | openssl base64
    // var facebookLogin = new FacebookLogin();
    // var result = await facebookLogin.logInWithReadPermissions(['email']);

    // switch (result.status) {
    //   case FacebookLoginStatus.loggedIn:
    //     final accessToken = result.accessToken;

    //     http('https://graph.facebook.com/v2.12/me?fields=id,name,email,age_range,first_name,last_name,birthday,link,gender,locale,picture,timezone,updated_time,verified&access_token=${accessToken.token}')
    //         .then((value) {
    //       var json = jsonDecode(value);
    //       if (!isnull(json)) {
    //         d('获取fb信息失败');
    //         return false;
    //       }

    //       thirdlogin(
    //           json['id'], json['name'], json['picture']['data']['url'], 1);
    //     });

    //     break;
    //   case FacebookLoginStatus.cancelledByUser:
    //     d('Facebook: cancelledByUser');
    //     break;
    //   case FacebookLoginStatus.error:
    //     d('Facebook: ${result.errorMessage}');
    //     break;
    // }
  }

  _google() {
    // googleSignIn().then((GoogleSignInAccount userinfo) {
    //   thirdlogin(userinfo.id, userinfo.displayName, userinfo.photoUrl, 2);
    // }).catchError((e) {
    //   d(e);
    // });
  }

  Future<dynamic> googleSignIn() async {
    try {
      // GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      return null;
      // return googleUser;
    } catch (e) {
      dt(e);
    }

    // d(googleUser);
    // d(googleUser.displayName);
    // d(googleUser.toString());
    // GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // d(googleAuth);
    // FirebaseUser firebaseUser = await _auth.signInWithGoogle(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );
    // User user = GlobalData.user;
    // user.source = 'google';
    // user.sourceId = googleUser.id;
    // print("signed in " + firebaseUser.displayName);
    // return firebaseUser;
  }

  loadwebviewlisten() {
    flutterWebviewPlugin = new FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen(fblogin2);
    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        if (state.type == WebViewState.finishLoad) {
          Bow.isload = false;
          //页面内容加载完成执行
          // flutterWebviewPlugin.evalJavascript(
          //     "window.localStorage.setItem('LOCAL_STORAGE','SOMETOKEN');" +
          //         "document.getElementById('showLocalStorageBtn').click();");
        }
      }
    });
  }

  fblogin() {
    var url =
        "https://www.facebook.com/v3.2/dialog/oauth?client_id=$fb_app_id&response_type=code&redirect_uri=$fb_LoginUrl&scope=email&state=1";
    gourl(
        context,
        new Bow(
          url: url, title: '',
          //title: "标题",
        ));
  }

  fblogin2(url) {
    //当前fb已经回调

    RegExp exp = new RegExp(fb_LoginUrl);
    var z = exp.hasMatch(url);

    // re.exec();
    if (z) {
      Bow.close(context);
      // flutterWebviewPlugin.close();

      // Navigator.of(context).pop(1);
      Uri u = Uri.parse(url);

      String? code = u.queryParameters['code'];
      if (!isnull(code)) {
        // Bow.close(context);
        return false;
        //show(context, lang('获取fb_code失败'));
      }
      if (code == tmpfbcode) {
        //  Bow.close(context);
        return false;
        //防止重复执行，code拉一次就失效了
      } else {
        tmpfbcode = code!;
      }
      //这里获取fbtoken
      String tokenurl =
          "https://graph.facebook.com/v3.2/oauth/access_token?code=$code&redirect_uri=$fb_LoginUrl&client_id=$fb_app_id&client_secret=$fb_app_secret";
      http(tokenurl).then((data) {
        var res = getres(); //重新取源json，这里是异步；容易获取失败
        var token = res.data['access_token']; //fbtoken

        //获取到了fb的token222222
        if (isnull(token)) {
          var fbuserinfo =
              "https://graph.facebook.com/me?fields=id,name,email,age_range,first_name,last_name,birthday,link,gender,locale,picture,timezone,updated_time,verified&access_token=$token";
          http(fbuserinfo).then((onValue) {
            var json = jsonDecode(onValue!);
            var postdata = {
              'uid': json['id'],
              'nickname': json['name'],
              'icon': json['picture']['data']['url'],
              'login_type': 1,
            };
            http('login/run', postdata, gethead()).then((onValue) async {
              //d(onValue);
              // Map json=jsonDecode(onValue);
              // d(json);
              var getdatas = getdata(context, onValue!);

              //d(getdatas);
              User.set(getdatas);
              //gourl(context, new Rack());
              // gourl(context, new App());
              pop(context);
            });
          });
        }

        //提交到我们接口登入
      });
      //d(tokenurl);
    } else {
      //登入失败，或者无法打开fb
      show(context, lang('无法访问facebook，请检查网络'));
    }
  }

  thirdlogin(String thirdid, String thirdname, String headurl, int type) {
    var postdata = {
      'uid': thirdid,
      'nickname': thirdname,
      'icon': headurl,
      'login_type': type,
    };
    http('login/run', postdata, gethead()).then((onValue) async {
      var getdatas = getdata(context, onValue!);

      User.set(getdatas);
      pop(context);
      // gourl(context, new App());
    });
  }
  // _launchURL(urls) async {
  //   await launch(urls);
  //   if (await canLaunch(urls)) {
  //     await launch(urls);
  //   } else {
  //     throw 'Could not launch $urls';
  //   }
  //   return null;
  // }

  /// 点击控制密码是否显示
  Future showPassWord() async => setState(() {
        isShowPassWord = !isShowPassWord;
      });

  ///创建登录界面的TextForm

  Widget buildSignInTextForm() {
    var textFormField = new TextFormField(
      //关联焦点
      // autovalidate:true,
      focusNode: emailFocusNode,
      controller: username,
      onEditingComplete: () {
        // ignore: unnecessary_null_comparison
        if (focusScopeNode == null) {
          focusScopeNode = FocusScope.of(context);
        }
        focusScopeNode.requestFocus(passwordFocusNode);
      },

      decoration: new InputDecoration(
          icon: new Icon(
            Icons.verified_user,
            color: Colors.black,
          ),
          hintText: lang('账号'),
          border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String? value) {
        if (value!.isEmpty) {
          cansubmit = cansubmit && false;
          return lang('请填写账号');
        }
        return '';
      },
      onSaved: (value) {},
    );
    var textStyle = new TextStyle(fontSize: 16, color: Colors.black);
    var textFormField2 = new TextFormField(
      focusNode: passwordFocusNode,
      // autovalidate:true,
      controller: pwd,
      decoration: new InputDecoration(
          icon: new Icon(
            Icons.lock,
            color: Colors.black,
          ),
          hintText: lang('密码'),
          border: InputBorder.none,
          suffixIcon: new IconButton(
              icon: new Icon(
                !isShowPassWord
                    ? Icons.remove_red_eye
                    : Icons.visibility_off, //没找到闭眼图标；随便了一个
                color: Colors.black,
              ),
              onPressed: showPassWord)),
      //输入密码，需要用*****显示
      obscureText: !isShowPassWord,
      style: textStyle,
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 3) {
          cansubmit = cansubmit && false;
          return "请填写密码";
        }
        return null;
      },
      onSaved: (value) {
        // fromdata.username=value;
        // fromdata.putIfAbsent('username', value);
      },
    );
    return new Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white),
      width: 300,
      height: 190,
      /**
           * Flutter提供了一个Form widget，它可以对输入框进行分组，
           * 然后进行一些统一操作，如输入内容校验、输入框重置以及输入内容保存。
           */
      child: new Form(
        key: _signInFormKey,
        //开启自动检验输入内容，最好还是自己手动检验，不然每次修改子孩子的TextFormField的时候，其他TextFormField也会被检验，感觉不是很好
        // autovalidate: true,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              //用户名
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: textFormField,
              ),
            ),
            new Container(
              height: 1,
              width: 250,
              color: Colors.grey[400],
            ),
            Flexible(
              //密码
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
                child: textFormField2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 创建登录界面的按钮
  Widget buildSignInButton() {
    return new GestureDetector(
      child: new Container(
        padding: EdgeInsets.only(left: 42, right: 42, top: 10, bottom: 10),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          gradient: theme.Theme.primaryGradient,
        ),
        child: new Text(
          lang('登入'),
          style: new TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      onTap: () async {
        /**利用key来获取widget的状态FormState
              可以用过FormState对Form的子孙FromField进行统一的操作
           */
        cansubmit = true;
        _signInFormKey.currentState?.validate();

        if (cansubmit) {
          //如果输入都检验通过，则进行登录操作

          Function load = ngbrige.fun['loadding'];
          Function hide = ngbrige.fun['hideing'];
          load();

          // ngbrige.fun['loading']();
          // Scaffold.of(context)
          //     .showSnackBar(new SnackBar(content: new Text("执行登录操作")));
          //调用所有自孩子的save回调，保存表单内容

          // _signInFormKey.currentState.save();
          if (!ngbrige.data['isload']) {
            http(
                    'login/login',
                    {'username': username.text, 'password': pwd.text},
                    gethead())
                .then((data) async {
              var gets = getdata(context, data!);

              if (isnull(gets)) {
                _signInFormKey.currentState?.reset();
                username.clear();
                pwd.clear();
                User.set(gets);
                pop(context);
                //gourl(context, new Rack());
              }

              hide();
            });
          } // d(Form.of(context));
        } else {
          //上次请求还没结束，继续等待
        }
//          debugDumpApp();
      },
    );
  }
}
