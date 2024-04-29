
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

class EditPwd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditPwdState();
}

class EditPwdState extends State<EditPwd> {
  TextEditingController oldpwd = new TextEditingController();
  TextEditingController pwd = new TextEditingController();
  TextEditingController cpwd = new TextEditingController();
  // TextEditingController qm, wordname;
  final GlobalKey<FormState> _tmpformKey = GlobalKey<FormState>();
  var user;
  var styles = TextStyle(color: SQColor.gray);

  // var _selectType;

  bool post = false;

  //标题栏
  @override
  void initState() {
    super.initState();

    user = User.get();
  }

  Widget buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
            color: SQColor.white,
            boxShadow: [
              BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
            ],
          ),
          padding: EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 0, 0),
          height: Screen.navigationBarHeight,
          //color: SQColor.white,
          child: Row(
            children: <Widget>[
              //SizedBox(width: 103),
              GestureDetector(
                child: Container(
                    height: kToolbarHeight,
                    width: 44,
                    child: Icon(
                      Icons.arrow_back,
                      color: SQColor.darkGray,
                    )

               
                    ),
                onTap: close,
              ),

              Expanded(
                  child: Center(
                child: Text(
                  lang('修改密码'),
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: SQColor.darkGray),
                  textAlign: TextAlign.left,
                ),
              )),
              SizedBox(
                // width: 44,
                child: GestureDetector(
                    onTap: () {
                      //保存修改
                      saveuser();
                    },
                    child: Text(
                      lang('保存'),
                      style: TextStyle(
                        color: post ? SQColor.black : SQColor.gray,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    )),
              ),
              SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ],
    );
  }

  close() {
    pop(context);
  }

  saveuser() async {
    if (!post) {
      return false;
    }
    if (true) {
      post = false;
      reflash();

      if (!_tmpformKey.currentState!.validate()) {
        return false;
      }
      var data = {
        'newpwd': pwd.text,
        'oldpwd': oldpwd.text,
      };

      var tmp2 = await http('user/cgpwd', data, gethead());
      var tmpdata = getdata(context, tmp2);
      if (!isnull(tmpdata)) return false;
      //user = tmpdata;

      User.set([]);
      close();
      gourl(context, Index());
      reflash();
    }
  }

  @override
  Widget build(BuildContext context) {
    //没书的时候显示加号顶部标题栏
    var textpwd = new TextFormField(
      obscureText: true,
      inputFormatters: <TextInputFormatter>[
        LengthLimitingTextInputFormatter(20) //限制长度
      ],
      maxLines: 1,
      textAlign: TextAlign.right,
      controller: pwd,
      onChanged: (str) {
        if (isnull(str)) {
          post = true;
        }
        if (!isnull(str)) {
          post = false;
        }
        reflash();
      },
      onEditingComplete: () {},
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0), border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: ( value) {
        if (value!.isEmpty) {
          return lang('请输入密码');
        }
        if (value == oldpwd.text) {
          return lang('不能跟原密码相同');
        }
        if (value.length < 6) {
          return lang('密码太弱');
        }
        return null;
      },
    );
    var textcpwd = new TextFormField(
      obscureText: true,
      inputFormatters: <TextInputFormatter>[
        // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
        LengthLimitingTextInputFormatter(20) //限制长度
      ],
      maxLines: 1,
      textAlign: TextAlign.right,
      controller: cpwd,
      onChanged: (str) {
        if (isnull(str)) {
          post = true;
        }
        if (!isnull(str)) {
          post = false;
        }
        reflash();
      },
      onEditingComplete: () {},
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0), border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: ( value) {
        if (value!.isEmpty) {
          return lang('请再次输入密码');
        }
        if (value != pwd.text) {
          return lang('两次密码不相同');
        }
        return null;
      },
    );
    var textoldpwd = new TextFormField(
      obscureText: true,
      inputFormatters: <TextInputFormatter>[
        // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
        LengthLimitingTextInputFormatter(20) //限制长度
      ],
      maxLines: 1,
      textAlign: TextAlign.right,
      controller: oldpwd,
      onChanged: (str) {
        if (isnull(str)) {
          post = true;
        }
        if (!isnull(str)) {
          post = false;
        }
        reflash();
      },
      onEditingComplete: () {},
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0), border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: ( value) {
        if (value!.isEmpty) {
          return lang('请输入旧密码');
        }
        return null;
      },
    );

    return Scaffold(
      backgroundColor: SQColor.white,
      body: Container(
        child: Stack(children: [
          SingleChildScrollView(
            child: Form(
                key: _tmpformKey,
                child: Column(children: [
                  SizedBox(
                    height: kToolbarHeight + Screen.topSafeHeight,
                  ),
                  isnull(user['password'])
                      ? getrow(lang('旧密码'), Expanded(child: textoldpwd), () {})
                      : SizedBox(),
                  getrow(lang('新密码'), Expanded(child: textpwd), () {}),
                  getrow(lang('确认密码'), Expanded(child: textcpwd), () {}),
                ])),
          ),
          buildNavigationBar(),
        ]),
      ),
    );
  }

  Widget getrow(String title, Widget obj, [void Function()? click, bool haveink = false]) {
    return Material(
      color: SQColor.white,
      child: InkWell(
        child: Container(
          color: !haveink ? Colors.white : null,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.only(top: 15, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(title,
                        style: TextStyle(fontSize: 18, color: SQColor.gray)),
                    obj,
                  ],
                ),
              ),
              Container(
                height: 0.5,
                color: SQColor.lightGray,
                margin: EdgeInsets.only(left: 10, right: 10),
              ),
            ],
          ),
        ),
        onTap: click,
      ),
    );
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }
}
