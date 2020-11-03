import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/msg.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/task/friend.dart';
import 'package:ng169/page/task/sign.dart';
import 'package:ng169/page/user/historypage.dart';
import 'package:ng169/page/user/rechargelog.dart';
import 'package:ng169/page/user/recordlog.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/event_bus.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/url.dart';
import 'package:ng169/page/commect/kefu.dart';
import 'package:ng169/tool/function.dart';
import 'expendLog.dart';
import 'me_header.dart';
import 'setting_scene.dart';
import 'me_cell.dart';
import 'me_cells.dart';
import 'me_cellss.dart';

class MeScene extends StatelessWidget {
  BuildContext context;
  Widget buildCells(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          MeCell(
            title: lang('福利任务'),
            iconName: 'assets/images/u5.png',
            right_widget: Row(
              children: <Widget>[
                Text(lang('去赚书豆')),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: SQColor.gray,
                )
              ],
            ),
            onPressed: () {
              gourl(context, Sign());
            },
          ),
          MeCell(
            title: lang('邀请好友'),
            iconName: 'assets/images/u1.png',
            // right_widget: Icon(Icons.group_add),
            onPressed: () {
              gourl(context, Friend());
            },
          ),
           MeCell(
            title: lang('我要写作'),
            iconName: 'assets/images/u7.png',
            right_widget: Row(
              children: <Widget>[
                Text(lang('赚现金')),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: SQColor.gray,
                )
              ],
            ),
            onPressed: () {
              gourl(
                  context,
                  Bow(
                    url: serverurl + 'index/author/run',
                    title: lang('写原创'),
                    needtoken: true,
                  ));
            },
          ),
          Container(
            height: 8,
            color: SQColor.lightGray,
          ),
          MeCell(
            title: lang('消费记录'),
            iconName: 'assets/images/u6.png',
            onPressed: () {
              gourl(context, ExpendLog());
            },
          ),
          MeCell(
            title: lang('充值记录'),
            iconName: 'assets/images/u2.png',
            onPressed: () {
              gourl(context, RechargeLog());
            },
          ),
          MeCell(
            title: lang('奖励记录'),
            iconName: 'assets/images/u3.png',
            onPressed: () {
              gourl(context, RecordLog());
            },
            haveline: false,
          ),
          Container(
            height: 8,
            color: SQColor.lightGray,
          ),
          MeCell(
            title: lang('阅读记录'),
            iconName: 'assets/images/me_buy.png',
            onPressed: () {
              gourl(context, HistoryPage());
            },
          ),
          // MeCell(
          //   title: lang('打赏记录'),
          //   iconName: 'assets/images/me_record.png',
          //   onPressed: () {},
          //   haveline: false,
          // ),
          // Container(
          //   height: 8,
          //   color: SQColor.lightGray,
          // ),
          // MeCell(
          //   title: lang('我的收藏'),
          //   iconName: 'assets/images/me_favorite.png',
          //   onPressed: () {},
          // ),
          MeCells(
            title: lang('联系客服'),
            iconName: 'assets/images/u4.png',
            onPressed: () async {
              await gourl(context, Kefu());
              eventBus.emit('reflashuser', User.get());
            },
          ),
          MeCellss(
            title: lang('设置'),
            iconName: 'assets/images/me_setting.png',
            havemsg: checkversionnum(),
            onPressed: () async {
              await gourl(context, SettingScene());
              eventBus.emit('reflashuser', User.get());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return Scaffold(
      body: RefreshIndicator(
        // value: SystemUiOverlayStyle.dark,
        onRefresh: gethttpdata,
        child: Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              MeHeader(),
              SizedBox(height: 10),
              buildCells(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> gethttpdata() async {
    // var tmp = await http('user/userinfo', {}, gethead());

    // var httpuser = getdata(context, tmp);
    var user = await User.gethttpuser(context);
    eventBus.emit('reflashuser', user);
    Msg.cheack();
  }
}
