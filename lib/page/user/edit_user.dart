import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/user/edit_pwd.dart';
import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/cutimage.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

class EditUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditUserState();
}

class EditUserState extends State<EditUser> {
  // TextEditingController wordname = new TextEditingController();
  // TextEditingController qm = new TextEditingController();
  TextEditingController qm, wordname, yq;
  var user;
  var styles = TextStyle(color: SQColor.gray);
  String sex = '';
  String borth = '';
  var sexid = '0';
  // var _selectType;
  var image;
  bool post = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //标题栏
  @override
  void initState() {
    super.initState();
    sex = lang('请选择');
    user = User.get();
    if (isnull(user)) {
      sexid = user['sex'];
      if (sexid == '0') {
        sex = lang('请选择');
      }
      if (sexid == '1') {
        sex = lang('男');
      }
      if (sexid == '2') {
        sex = lang('女');
      }
      if (isnull(user['borth'])) {
        borth = user['borth'];
      } else {
        borth = lang('请选择');
      }
      if (isnull(user['nickname'])) {
        String texts = user['nickname'].toString();

        wordname = new TextEditingController(text: texts);
      } else {
        wordname = new TextEditingController();
      }
      if (isnull(user['more'])) {
        qm = new TextEditingController(text: user['more'].toString());
      } else {
        qm = new TextEditingController();
      }
      yq = new TextEditingController();
    } else {
      sex = lang('请选择');
      sexid = '0';
    }
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
                    )),
                onTap: close,
              ),

              Expanded(
                  child: Center(
                child: Text(
                  lang('编辑个人资料'),
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
      var imgurl;
      if (isnull(image)) {
        String path = image.path;

        var tmp = await httpfile('upimg/run',
            {'file': await MultipartFile.fromFile(path)}, gethead());
        imgurl = getdata(context, tmp);
      }

      var data = {
        'nickname': wordname.text,
        'more': qm.text,
        'avater': imgurl,
        'sex': sexid,
        'borth': borth
      };

      var tmp2 = await http('user/edit', data, gethead());
      var tmpdata = getdata(context, tmp2);
      if (!isnull(tmpdata)) return false;
      user = tmpdata;
      User.set(tmpdata);
      reflash();
    } else {
      post = false;
      reflash();
    }
  }

  Future sethead() async {
    // d(image);
  }

  chooshead() {
    List<Widget> childs = [];
    var camera = ListTile(
      title: Text(
        lang("拍照"),
        textAlign: TextAlign.center,
        style: TextStyle(color: SQColor.darkGray),
      ),
      onTap: () async {
        Navigator.pop(context);
        // var tmpimage = await ImagePicker.pickImage(source: ImageSource.camera);
        // cutimg(tmpimage);
        PickedFile tmpimages =
            await ImagePicker.platform.pickImage(source: ImageSource.camera);

        File f = File(tmpimages.path);
        cutimg(f);
        reflash();
      },
    );
    var gallery = ListTile(
      title: Text(
        lang("相册"),
        textAlign: TextAlign.center,
        style: TextStyle(color: SQColor.darkGray),
      ),
      onTap: () async {
        Navigator.pop(context);
        // var tmpimage = await ImagePicker.pickImage(source: ImageSource.gallery);
        PickedFile tmpimages =
            await ImagePicker.platform.pickImage(source: ImageSource.gallery);

        File f = File(tmpimages.path);
        cutimg(f);
        reflash();
      },
    );
    childs.add(camera);
    childs.add(gallery);

    selectbox(context, childs);
  }

  void cutimg(File originalImage) async {
    if (!isnull(originalImage)) {
      return;
    }
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => CutImage(originalImage)));

    if (!isnull(result)) {
      d('裁剪失败');
    } else {
      image = result;
      post = true;
      reflash();
    }
  }

  @override
  Widget build(BuildContext context) {
    //没书的时候显示加号顶部标题栏

    var head = CircleAvatar(
      radius: 35,
      backgroundColor: SQColor.white,
      backgroundImage: isnull(image)
          ? FileImage(image)
          : isnull(user)
              ? isnull(user['avater'])
                  ? CachedNetworkImageProvider(user['avater'])
                  : AssetImage('assets/images/placeholder_avatar.png')
              : AssetImage('assets/images/placeholder_avatar.png'),
    );
    var textFormFieldname = new TextFormField(
      inputFormatters: <TextInputFormatter>[
        // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
        LengthLimitingTextInputFormatter(15) //限制长度
      ],

      maxLines: 1,
      textAlign: TextAlign.right,

      // initialValue: isnull(user) ? user['nickname'] : '',
      controller: wordname,
      onChanged: (str) {
        if (str != user['nickname'] && isnull(wordname.text)) {
          post = true;
        }
        if (!isnull(str)) {
          post = false;
        }
        reflash();
      },
      onEditingComplete: () {},
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0),
          //hintText: lang("书名/作者/关键词"),
          border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String value) {
        if (value.isEmpty) {
          //cansubmit = cansubmit && false;
          return lang('昵称不能为空');
        }
        // if (value.length > 18) {
        //   return lang('长度不能超过20个字符');
        // }
        return '';
      },
      onSaved: (value) {},
    );
    var textFormFieldqm = new TextFormField(
      inputFormatters: <TextInputFormatter>[
        // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
        LengthLimitingTextInputFormatter(25) //限制长度
      ],
      maxLines: 1,
      textAlign: TextAlign.right,

      // initialValue: isnull(user) ? user['more'] : '',
      controller: qm,
      onChanged: (str) {
        if (str != user['more']) {
          post = true;
        }
        reflash();
        // if (!isnull(str)) {
        //   post = false;
        // }
      },
      onEditingComplete: () {},
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(top: -4.0),
          //hintText: lang("书名/作者/关键词"),
          border: InputBorder.none),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String value) {
        if (value.isEmpty) {
          //cansubmit = cansubmit && false;
          // return lang('昵称不能为空');
        }

        return '';
      },
      onSaved: (value) {},
    );
    //有书的时候这样显示

    return Scaffold(
      backgroundColor: SQColor.white,
      body: Container(
        child: Stack(children: [
          SingleChildScrollView(
            child: Form(
                // key: _edituserformKey,
                child: Column(children: [
              SizedBox(
                height: kToolbarHeight + Screen.topSafeHeight,
              ),
              getrow(lang('头像'), head, chooshead, true),
              getrow(lang('用户ID'),
                  Text(isnull(user) ? user['id'] : '0', style: styles), () {}),
              getrow(
                  lang('账号'),
                  Text(isnull(user) ? user['username'] ?? '' : '',
                      style: styles),
                  () {}),
              getrow(
                  lang('邀请人ID'),
                  Text(
                      !isnull(user, 'invite_id')
                          ? lang('填写邀请人')
                          : user['invite_id'],
                      style: !isnull(user, 'invite_id')
                          ? TextStyle(color: SQColor.primary)
                          : styles), () {
                if (isnull(user, 'invite_id')) {
                  return;
                }
                showbox(editinvint(), Colors.white, 15.0, false);
              }),
              getrow(lang('昵称'), Expanded(child: textFormFieldname), () {}),
              getrow(lang('性别'), Text(sex), () {
                selectbox(context, _sex());
              }),
              getrow(lang('生日'), Text(showborth(borth)), () {
                // selectbox(context, _sex());
                String langs = getlang();
                LocaleType tmp = LocaleType.en;
                switch (langs) {
                  case 'vi':
                    tmp = LocaleType.vi;
                    break;
                  case 'id':
                    tmp = LocaleType.id;
                    break;
                  case 'ko':
                    tmp = LocaleType.ko;
                    break;
                  case 'th':
                    tmp = LocaleType.th;
                    break;
                  case 'en':
                    tmp = LocaleType.en;
                    break;
                  default:
                }
                DatePicker.showDatePicker(context,
                    // 是否展示顶部操作按钮
                    showTitleActions: true,
                    // 最小时间
                    // minTime: DateTime(2018, 3, 5),
                    // 最大时间
                    maxTime: DateTime.now(),
                    // change事件
                    onChanged: (date) {
                  //print('change $date');
                },
                    // 确定事件
                    onConfirm: (date) {
                  // print('confirm $date');
                  borth = date.toString();
                  user['borth'] = borth;
                  User.set(user);
                  post = true;
                  reflash();
                },
                    // 当前时间
                    currentTime: isnull(user, 'borth')
                        ? DateTime.parse(user['borth'])
                        : DateTime.now(),
                    // 语言
                    // locale: LocaleType.th);
                    locale: tmp);
              }),
              getrow(lang('我的签名'), Expanded(child: textFormFieldqm), () {}),
              getrow(lang('密码'),
                  Text(lang('修改密码'), style: TextStyle(color: SQColor.primary)),
                  () {
                gourl(context, EditPwd());
              }),
            ])),
          ),
          buildNavigationBar(),
        ]),
      ),
    );
  }

  String showborth(String datestr) {
    try {
      DateTime dates = DateTime.parse(datestr);
      if (isnull(dates)) {
        return dates.day.toString() +
            "/" +
            dates.month.toString() +
            '/' +
            dates.year.toString();
      }
    } catch (e) {}

    return datestr;
  }

  Widget editinvint() {
    var textFormFieldyq = new TextFormField(
      keyboardType: TextInputType.number, //限定数字键盘
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        // WhitelistingTextInputFormatter.digitsOnly, //只输入数字
        LengthLimitingTextInputFormatter(15) //限制长度
      ],
      maxLines: 1,
      textAlign: TextAlign.left,
      controller: yq,
      onChanged: (str) {
        // if (str != user['more']) {
        //   post = true;
        // }
        // reflash();
        // if (!isnull(str)) {
        //   post = false;
        // }
      },
      onEditingComplete: () {
        sureyq();
      },
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.only(top: -4.0),
        hintText: lang("输入邀请者用户ID"),
        // border: InputBorder.none
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
          color: Colors.grey[300], //边框颜色为绿色
          width: 1, //宽度为5
        )),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
          color: Colors.grey[300], //边框颜色为绿色
          width: 1, //宽度为5
        )),
        // enabledBorder: OutlineInputBorder(
        //   /*边角*/
        //   borderRadius: BorderRadius.all(
        //     Radius.circular(30), //边角为30
        //   ),
        //   borderSide: BorderSide(
        //     color: Colors.amber, //边线颜色为黄色
        //     width: 2, //边线宽度为2
        //   ),
        // ),
        // focusedBorder: OutlineInputBorder(
        //     borderSide: BorderSide(
        //   color: Colors.green, //边框颜色为绿色
        //   width: 5, //宽度为5
        // )),
      ),
      style: new TextStyle(fontSize: 16, color: Colors.black),
      //验证
      validator: (String value) {
        if (value.isEmpty) {
          return lang('请填写邀请人用户ID');
        }

        return null;
      },
      onSaved: (value) {},
    );

    return Material(
        color: Color(0x00fffff),
        // color: Color(0xfffeeff),
        child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Form(key: _formKey, child: textFormFieldyq),
                  SizedBox(height: 10),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new TextButton(
                            onPressed: () {
                              pop(context);
                            },
                            // color: Color(0xffd3d3d3),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                return Color(0xffd3d3d3);
                              }),
                            ),
                            child: new Text(
                              lang("取消"),
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                              ),
                            )),
                        SizedBox(width: 10),
                        new TextButton(
                            onPressed: () {
                              sureyq();
                            },
                            // color: SQColor.primary,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                return SQColor.primary;
                              }),
                            ),
                            child: new Text(
                              lang("确定"),
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: const Color(0xFF000000),
                                fontWeight: FontWeight.w200,
                              ),
                            ))
                      ])
                ])));
  }

  sureyq() async {
    _formKey.currentState.validate();
    // if (isnull(yq.text)) {
    //   var data =
    //       await http('task/edit_invite', {'inviteid': yq.text}, gethead());
    //   var data2 = getdata(context, data);
    //   if (isnull(data2)) {
    //     //更新用户界面
    //     user['invite_id'] = yq.text;
    //     //更新用户界面
    //     User.set(user);
    //     reflash();
    //     pop(context);
    //   }
    bool b = await User.bindinvite(yq.text);
    if (b) {
      reflash();
      pop(context);
    } else {
      User.gethttpuser(context);
      reflash();
    }
    // User.gethttpuser(context);
    // reflash();
    // }
  }

  Widget getrow(String title, Widget obj, Function click,
      [bool haveink = false]) {
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

  List<Widget> _sex() {
    var values = {'1', '2'};
    var sexname = {'1': lang('男'), '2': lang('女')};
    return values.map((local) {
      return ListTile(
        title: Text(
          "${sexname[local]}",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: local == sexid ? SQColor.primary : SQColor.darkGray),
        ),
        onTap: () {
          sexid = local;
          sex = sexname[local];
          Navigator.pop(context);
          if (sexid != user['sex'].toString() && sexid != '0') {
            post = true;
          }
          if (sexid == '0') {
            post = false;
          }
          reflash();
        },
      );
    }).toList();
  }
}

// SizedBox(
//     child: SizedBox(
//         height: 20,
//         width: 80,
//         child: new DropdownButtonHideUnderline(
//             child: new DropdownButton(
//           items: [
//             new DropdownMenuItem(
//               child: new Text('男'),
//               value: '1',
//             ),
//             new DropdownMenuItem(
//               child: new Text('女'),
//               value: '2',
//             ),
//           ],
//           hint: new Text('请选择'),
//           onChanged: (value) {
//             setState(() {
//               _selectType = value;
//             });
//           },
//           //isExpanded: true,
//           value: _selectType,
//           //elevation: 24, //设置阴影的高度
//           style: new TextStyle(
//             //设置文本框里面文字的样式
//             color: Color(0xff4a4a4a),
//             fontSize: 12,
//           ),
//           // isDense:
//           //     true, //减少按钮的高度。默认情况下，此按钮的高度与其菜单项的高度相同。如果isDense为true，则按钮的高度减少约一半。 这个当按钮嵌入添加的容器中时，非常有用
//           iconSize: 40.0,
//         ))))
