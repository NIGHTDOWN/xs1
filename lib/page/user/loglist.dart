import 'package:flutter/material.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/commom.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';

class LogList extends StatelessWidget {
  final List data;
  final int type;

  LogList(this.data, this.type);

  @override
  Widget build(BuildContext context) {
    var novels = data;
    if (novels.length <= 0) {
      return Container();
    }

    List<Widget> children = [];
    for (var i = 0; i < novels.length; i++) {
      var json = novels[i];

      children.add(cell(json, type));
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
        // controller: scrollController,
      ),
    );
  }
}

// ignore: missing_return
Widget cell(json, type) {
  var line_padding_left = 16.0;
  //1充值 2人工送 3好友代充
  String typestring;

  if (type == 1) {
    switch (json['charge_type']) {
      case "1":
        typestring = lang('充值');
        break;
      case "2":
        typestring = lang('赠送');
        break;
      case "3":
        typestring = lang('代充');
        break;
      default:
        typestring = lang('充值');
    }

    return Container(
      margin:
          EdgeInsets.only(left: line_padding_left, right: line_padding_left),
      color: Colors.white,
      child: Column(
        // crossAxisAlignment :CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: SQColor.white,
            height: 60,
            //padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                //三列（类型，时间，金额图标）

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(typestring, style: TextStyle(fontSize: 18)),
                    Text(gettime2(json['addtime']),
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),

                Expanded(child: Container()),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(children: [
                        Text("+" + json['charge_icon'] + " ",
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.red,
                                fontWeight: FontWeight.w700)),
                        SizedBox(
                          child:
                              Image.asset('assets/images/bean.png', width: 18),
                        )
                      ]),
                      isnull(json['send_coin'])
                          ? Row(children: [
                              Text("+" + json['send_coin'] + " ",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red[300],
                                      fontWeight: FontWeight.w700)),
                              SizedBox(
                                child: Image.asset('assets/images/bean.png',
                                    width: 18),
                              )
                            ])
                          : SizedBox()
                    ]) // isnull(right_widget) ? right_widget : qjin,
              ],
            ),
          ),
          Divider(height: 1)
        ],
      ),
    );
  }
  if (type == 2) {
    return Container(
      margin:
          EdgeInsets.only(left: line_padding_left, right: line_padding_left),
      color: Colors.white,
      child: Column(
        // crossAxisAlignment :CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: SQColor.white,
            height: 60,
            //padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                //三列（类型，时间，金额图标）
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Text(json['bother_name'].toString(),
                            // maxLines: 2,
                            // softWrap: true,
                            style: TextStyle(fontSize: 13)),
                      ),
                      Flexible(
                        child: Text(json['section_title'],
                            overflow: TextOverflow.ellipsis,
                            // maxLines: 2,
                            // softWrap: true,
                            style:
                                TextStyle(fontSize: 12, color: SQColor.gray)),
                      ),
                      Text(gettime2(json['addtime']),
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                // fixab(child: Container()),
                Text("-" + json['expend_red'] + " ",
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.red,
                        fontWeight: FontWeight.w700)),
                SizedBox(
                  child: Image.asset('assets/images/bean.png', width: 18),
                )
                // isnull(right_widget) ? right_widget : qjin,
              ],
            ),
          ),
          Divider(height: 1)
        ],
      ),
    );
  }
  if (type == 3) {
    // `task_type` int(11) DEFAULT '1' COMMENT '任务类型 1每日分享 2每日阅读 3邀请好友 4替好友充值 5每日看广告 6签到',
    // 1每日分享 2每日阅读 3邀请好友 4替好友充值 5每日看广告 6签到,7完善用户资料,8每日充值
    // d(json);
    switch (json['task_type']) {
      case "1":
        typestring = lang('每日分享');
        break;
      case "2":
        typestring = lang('每日阅读');
        break;
      case "3":
        typestring = lang('邀请好友');
        break;
      case "4":
        typestring = lang('替好友充值');
        break;
      case "5":
        typestring = lang('每日看广告');
        break;
      case "6":
        typestring = lang('签到');
        break;
      case "7":
        typestring = lang('完善资料');
        break;
      case "8":
        typestring = lang('每日充值');
        break;
      case "9":
        typestring = lang('应用评价');
        break;
      case "10":
        typestring = lang('阅读本地小说');
        break;
      case "11":
        typestring = lang('每日标记');
        break;
      default:
        typestring = '';
        ;
    }

    return Container(
      margin:
          EdgeInsets.only(left: line_padding_left, right: line_padding_left),
      color: Colors.white,
      child: Column(
        // crossAxisAlignment :CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: SQColor.white,
            height: 60,
            //padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                //三列（类型，时间，金额图标）
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(typestring, style: TextStyle(fontSize: 18)),
                    Text(gettime2(json['addtime']),
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),

                Expanded(child: Container()),
                Text("+" + json['treward_coin'] + " ",
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.red,
                        fontWeight: FontWeight.w700)),
                SizedBox(
                  child: Image.asset('assets/images/bean.png', width: 18),
                )
                // isnull(right_widget) ? right_widget : qjin,
              ],
            ),
          ),
          Divider(height: 1)
        ],
      ),
    );
  }
  return Container();
}
