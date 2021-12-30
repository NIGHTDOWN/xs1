import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/app.dart';
import 'package:ng169/page/rack/rack.dart';
import 'package:ng169/style/theme.dart' as theme;
import 'package:ng169/tool/brige.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

/// 注册界面
class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController username = new TextEditingController();
  TextEditingController pwd = new TextEditingController();
  TextEditingController nickname = new TextEditingController();
  TextEditingController cpwd = new TextEditingController();
  GlobalKey<FormState> _signInFormKey = new GlobalKey();
  NgBrige ngbrige;
  bool isShowPassWord = false, isShowcPassWord = false, cansubmit = true;
  @override
  Widget build(BuildContext context) {
    //this.context = context;
    ngbrige = NgBrige.of(context);
    var cache = g('cache');
    return new Container(
        padding: EdgeInsets.only(top: 23),
        child: new Stack(
          alignment: Alignment.topCenter,
          overflow: Overflow.visible,
          children: <Widget>[
            new Container(
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                width: 300,
                height: 360,
                child: buildSignUpTextForm()),
            new Positioned(
              child: new Center(
                child: GestureDetector(
                  onTap: () async {
                    /**利用key来获取widget的状态FormState
              可以用过FormState对Form的子孙FromField进行统一的操作
           */
                    cansubmit = true;
                    _signInFormKey.currentState.validate();

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
                        http('login/reg', {
                          'nickname': nickname.text,
                          'username': username.text,
                          'password': pwd.text
                        },gethead()).then((data) async {
                          var gets = getdata(context, data);

                          if (gets != false) {
                            _signInFormKey.currentState.reset();
                            username.clear();
                            pwd.clear();
                          
                            User.set(gets);
                            // gourl(context, new App());
                            pop(context);
                          }

                          hide();
                        });
                      } // d(Form.of(context));
                    } else {
                      //上次请求还没结束，继续等待
                    }
//          debugDumpApp();
                  },
                  child: new Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 42, right: 42),
                    decoration: new BoxDecoration(
                      gradient: theme.Theme.primaryGradient,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: new Text(
                      lang("注册"),
                      style: new TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                ),
              ),
              top: 340,
            )
          ],
        ));
  }

  Future showPassWord() async => setState(() {
        isShowPassWord = !isShowPassWord;
      });
  Future cshowPassWord() async => setState(() {
        isShowcPassWord = !isShowcPassWord;
      });
  Widget buildSignUpTextForm() {
    return new Form(
        key: _signInFormKey,
        child: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            //用户名字
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: new TextFormField(
                  controller: nickname,
                  decoration: new InputDecoration(
                      icon: new Icon(
                        FontAwesomeIcons.user,
                        color: Colors.black,
                      ),
                      hintText: lang('昵称'),
                      border: InputBorder.none),
                  style: new TextStyle(fontSize: 16, color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      cansubmit = cansubmit && false;
                      return "请填写您的昵称";
                    }
                    return null;
                  },
                ),
              ),
            ),
            new Container(
              height: 1,
              width: 250,
              color: Colors.grey[400],
            ),
            //账号
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: new TextFormField(
                  controller: username,
                  decoration: new InputDecoration(
                      icon: new Icon(
                        Icons.verified_user,
                        color: Colors.black,
                      ),
                      hintText: lang('账号'),
                      border: InputBorder.none),
                  style: new TextStyle(fontSize: 16, color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      cansubmit = cansubmit && false;
                      return "请填写账号";
                    }
                    return null;
                  },
                ),
              ),
            ),
            new Container(
              height: 1,
              width: 250,
              color: Colors.grey[400],
            ),
            //密码
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: new TextFormField(
                  controller: pwd,
                  decoration: new InputDecoration(
                    icon: new Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    hintText: lang("密码"),
                    border: InputBorder.none,
                    suffixIcon: new IconButton(
                        icon: new Icon(
                          // Icons.remove_red_eye,
                          !isShowPassWord
                              ? Icons.remove_red_eye
                              : Icons.visibility_off, //没找到闭眼图标；随便了一个

                          color: Colors.black,
                        ),
                        onPressed: () {
                          showPassWord();
                        }),
                  ),
                  obscureText: !isShowPassWord,
                  style: new TextStyle(fontSize: 16, color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      cansubmit = cansubmit && false;
                      return "请填写密码";
                    }
                    if (value.length < 6) {
                      cansubmit = cansubmit && false;
                      return "密码长度不能少于6位";
                    }
                    return null;
                  },
                ),
              ),
            ),
            new Container(
              height: 1,
              width: 250,
              color: Colors.grey[400],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 20, bottom: 20),
                child: new TextFormField(
                  controller: cpwd,
                  decoration: new InputDecoration(
                    icon: new Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    hintText: lang("确认密码"),
                    border: InputBorder.none,
                    suffixIcon: new IconButton(
                        icon: new Icon(
                          // Icons.remove_red_eye,
                          !isShowcPassWord
                              ? Icons.remove_red_eye
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          cshowPassWord();
                        }),
                  ),
                  obscureText: !isShowcPassWord,
                  style: new TextStyle(fontSize: 16, color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      cansubmit = cansubmit && false;
                      return "请再次输入密码";
                    }
                    if (value != pwd.text) {
                      cansubmit = cansubmit && false;
                      return "两次输入密码不匹配";
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
