import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';

import 'edit_user.dart';

class MeHeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeHeaderState();
}

class MeHeaderState extends State<MeHeader> {
  late Map user = {};
  late BuildContext contexttmp;
  // MeHeader()
  @override
  Widget build(BuildContext context) {
    //this.context = context;
    contexttmp = context;
    //var user = UserManager.currentUser;
    try {
      user = User.get();
    } catch (e) {}

    var img;

    if (isnull(user) && isnull(user['avater'])) {
      img = CachedNetworkImageProvider(user['avater']);
    } else {
      img = AssetImage('assets/images/placeholder_avatar.png');
    }
    var b = GestureDetector(
      onTap: () {},

      //  buildItems(),
      child: Column(children: [
        SizedBox(
          height: 40,
        ),
        Center(
          child: GestureDetector(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: SQColor.white,
              backgroundImage: img,
            ),
            onTap: clickhead,
          ),
        ), //头像
        SizedBox(
          height: 10,
        ),
        Center(
          child: GestureDetector(
              child: Text(
                isnull(user) ? user['nickname'] : lang('游客'),
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'LoveCraft',
                ),
              ),
              onTap: clickhead),
        ), //文字
        SizedBox(
          height: 10,
        ),
        Center(
          child: GestureDetector(
              child: Text(
                (isnull(user)
                        ? isnull(user['more'])
                            ? user['more']
                            : lang('编辑用户')
                        : lang('点击登入')) +
                    '>',
                style: TextStyle(fontSize: 12, color: SQColor.gray),
              ),
              onTap: clickhead),
        ), //文字
        SizedBox(
          height: 10,
        ),

        Container(
          height: 8,
          color: SQColor.lightGray,
          // margin: EdgeInsets.only(
          //     left: isnull(line_padding_left) ? line_padding_left : 60),
        ),
        TextButton(
          child: Row(
            children: <Widget>[
              // Icon(Icons.card_giftcard),
              SizedBox(
                height: 60,
              ),
              Image.asset(
                'assets/images/bean.png',
                width: 20,
              ),
              SizedBox(width: 20),
              Text(lang('书豆'), style: TextStyle(fontSize: 18)),
              Expanded(child: Container()),
              Text(user != null ? User.getcoin().toString() : '0.0',
                  style: TextStyle(fontSize: 18)),
              Text(' | '),
              Ink(
                child: SizedBox(
                  child: Text(
                    lang('充值'),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: SQColor.primary),
                  ),
                ),
              ),

              // SizedBox(width: 20),
            ],
          ),
          onPressed: () async {
            var uid = getuid();
            if (isnull(uid)) {
              await gourl(context, Recharge());
              reflash();
            } else {
              gourl(context, Index());
            }
          },
        ),
        Container(
          height: 8,
          color: SQColor.lightGray,
        ),
      ]),
    );

    return b;
  }

  Future<bool> _islogin() async {
    user = User.get();
    if (isnull(user)) {
      return true;
    }
    await gourl(contexttmp, Index());
    reflash(); //刷新
    return false;
  }

  reflashuser(httpuser) {
    if (isnull(httpuser)) {
      user.addAll(httpuser);
    }

    // User.set(user);
    reflash();
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    eventBus.on('reflashuser', reflashuser);
  }

  @override
  void dispose() {
    eventBus.off('reflashuser');
    super.dispose();
  }

  //点击头像登入，或者编辑信息
  clickhead() async {
    bool b = await _islogin();
    if (b) {
      gourl(contexttmp, EditUser());
    }
  }

  //点击头像登入，或者充值页面
  rercharge() async {
    bool b = await _islogin();
    if (b) {}
  }

  Widget buildItems() {
    user = User.get();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment :CrossAxisAlignment.end,
      children: <Widget>[
        buildItem(user != null ? user['uid'].toString() : '0', lang('ID')),
        GestureDetector(
          child: buildItem(
              //user != null ? user['remainder'].toStringAsFixed(1) : '0.0',
              user != null ? User.getcoin().toString() : '0.0',
              lang('书豆')),
          onTap: rercharge,
        ),
        // buildItem(user != null ? user.coupon.toString() : '0', '书券（张）'),
        // buildItem(user != null ? user.monthlyTicket.toString() : '0', '月票'),
        Container(
          color: SQColor.primary,
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(right: 8),
          child: InkWell(
            child: SizedBox(
              child: Text(
                lang('充值'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            onTap: () {
              var uid = getuid();
              if (isnull(uid)) {
                gourl(context, Recharge());
              } else {
                gourl(context, Index());
              }
            },
          ),
        )
        //Container(),
      ],
    );
  }

  Widget buildItem(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: SQColor.gray),
        ),
      ],
    );
  }
}
