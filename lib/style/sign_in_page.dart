import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart' as nguser;
import 'package:ng169/style/sq_color.dart';

import 'package:ng169/style/theme.dart' as theme;

import 'package:ng169/tool/brige.dart';
import 'package:ng169/tool/cache.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';

import 'package:ng169/tool/lang.dart';

import 'package:third_party_login/third_party_login.dart';

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
  late NgBrige ngbrige;
  late Map<String, String> fromdata;
  bool isShowPassWord = false;

  late BuildContext context;
  late NgCache cache;
  late String tmpfbcode;
  Color bg = Color(0xffF5E7D6);
  Color an = Color(0xff8C9AB3);
  Color wz = Color(0xff24292E);
  // late FlutterWebviewPlugin flutterWebviewPlugin;
  // // ignore: unused_field
  // late StreamSubscription<WebViewStateChanged> _onStateChanged;
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

//按钮
  Widget getbtn(String btntitle, void Function() ontapcall, IconData ico) {
    return GestureDetector(
      onTap: ontapcall,
      child: new Container(
        padding: EdgeInsets.only(left: 42, right: 42, top: 10, bottom: 10),
        margin: EdgeInsets.only(
          left: 42,
          right: 42,
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          gradient: theme.Theme.primaryGradient2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SQColor.white,
              ),
              child: Icon(
                ico,
                color: Color(0xFF0084ff),
                size: 20,
              ),
            ),
            Text(
              btntitle,
              style: TextStyle(color: SQColor.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget input(String hints, String validstr,
      TextEditingController? controllers, IconData? ico) {
    var textFormField = new TextFormField(
      //关联焦点
      // autovalidate:true,
      // focusNode: emailFocusNode,
      controller: controllers,
      onEditingComplete: () {
        // ignore: unnecessary_null_comparison
        if (focusScopeNode == null) {
          focusScopeNode = FocusScope.of(context);
        }
        // focusScopeNode.requestFocus(passwordFocusNode);
      },
      decoration: new InputDecoration(
          icon: new Icon(
            ico,
            color: Colors.black,
          ),
          hintText: hints,
          border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String? value) {
        if (value == null || value.isEmpty || value.length < 3) {
          cansubmit = cansubmit && false;
          return validstr;
        }
        return '';
      },
      onSaved: (value) {},
    );
    return textFormField;
  }

  @override
  Widget build(BuildContext context) {
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
              SQColor.white,
            ])),
          ),
          new Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: new Text(
              "Or",
              style: new TextStyle(fontSize: 16, color: SQColor.white),
            ),
          ),
          new Container(
            height: 1,
            width: 100,
            decoration: BoxDecoration(
                gradient: new LinearGradient(
                    colors: [SQColor.white, Colors.white10])),
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
                height: 20,
              ),
              getbtn(
                lang('Facebook登入'),
                _fb,
                FontAwesomeIcons.facebookF,
              ),
              new SizedBox(
                height: 20,
              ),
              getbtn(
                lang('google登入') + "   ",
                _google,
                FontAwesomeIcons.google,
              ),
            ],
          ),
          positioned
        ],
      ),
    );
  }

  _fb() async {
    ThirdPartyLoginMethods thirdPartyLoginMethods = ThirdPartyLoginMethods();
    final userCredential = await thirdPartyLoginMethods.socialMediaLogin(
        authType: AuthType.facebook);
    d(userCredential);
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

  _google() async {
    ThirdPartyLoginMethods thirdPartyLoginMethods = ThirdPartyLoginMethods();
    final userCredential = await thirdPartyLoginMethods.socialMediaLogin(
        authType: AuthType.google);
    d(userCredential);
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

  thirdlogin(String thirdid, String thirdname, String headurl, int type) {
    var postdata = {
      'uid': thirdid,
      'nickname': thirdname,
      'icon': headurl,
      'login_type': type,
    };
    http('login/run', postdata, gethead()).then((onValue) async {
      var getdatas = getdata(context, onValue!);

      // User.set(getdatas);
      pop(context);
      // gourl(context, new App());
    });
  }

  /// 点击控制密码是否显示
  Future showPassWord() async => setState(() {
        isShowPassWord = !isShowPassWord;
      });

  ///创建登录界面的TextForm

  Widget buildSignInTextForm() {
    Widget textFormField =
        input(lang('账号'), lang('请填写账号'), username, Icons.verified_user);
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

    // Widget textFormField2 = input(lang('密码'), lang('请填写密码'), pwd,
    // !isShowPassWord ? Icons.remove_red_eye : Icons.visibility_off);

    return new Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: SQColor.white),
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
          gradient: theme.Theme.primaryGradient2,
        ),
        child: new Text(
          lang('登入'),
          style: new TextStyle(fontSize: 25, color: SQColor.white),
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
                nguser.User.set(gets);
                pop(context);
                //gourl(context, new Rack());
              }

              hide();
            });
          } // d(Form.of(context));
        } else {
          //上次请求还没结束，继续等待
        }
      },
    );
  }
}
