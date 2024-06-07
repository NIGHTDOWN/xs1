import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter/material.dart';

import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';

class BatteryView extends StatefulWidget {
  @override
  _BatteryViewState createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> {
  double batteryLevel = 0;
  var levels, level;
  @override
  void initState() {
    super.initState();
    getBatteryLevel();
  }

  getBatteryLevel() async {
    try {
// 如果出现编译报错      A problem occurred evaluating project ':app'.
// > Could not find method classpath() for arguments [org.jetbrains.kotlin:kotlin-gradle-plugin:1.5.31] on object of type
//请到对应插件文件修改 C:\Users\Administrator\AppData\Local\Pub\Cache\hosted\mirrors.tuna.tsinghua.edu.cn%47dart-pub%47\battery_plus-5.0.0\android\build.gradle
//把第49行变量 改成1.5.31
      //1.5.31
      this.level = (await BatteryInfoPlugin().androidBatteryInfo)?.batteryLevel;
      // this.level = await Battery().batteryLevel;
      if (this.level > 100 || this.level < 0) {
        this.level = 100;
      }
      if (this.level != null && mounted) {
        setState(() {
          levels = level;

          this.batteryLevel = level / 100.0;
        });
      }
    } catch (e) {
      // 处理错误情况，例如设置 batteryLevel 为 0 或者其他默认值
      dt(e);
      setState(() {
        this.batteryLevel = 100;
      });
    }
  }

  double pleft = 13;
  @override
  Widget build(BuildContext context) {
    var a = UnconstrainedBox(
      // width: 50,
      // height: 12,
      child: Stack(
        children: <Widget>[
          Image.asset('assets/images/reader_battery.png',
              color: Styles.getTheme()['batterycolor'], width: 50, height: 12),
          Container(
            margin: EdgeInsets.fromLTRB(pleft, 2, 2, 2),
            width: batteryLevel > 0 ? 20 * batteryLevel : 0,
            height: 8,
            color: Styles.getTheme()['titlefontcolor'],
          ),
          isnull(levels)
              ? Container(
                  margin: EdgeInsets.fromLTRB(pleft, 2, 2, 2),
                  // width: 100,
                  child: Text(
                    levels.toString(),
                    style: TextStyle(
                      fontSize: 5.5,
                      fontWeight: FontWeight.bold,
                      color: Styles.getTheme()['batteryfontcolor'],
                    ),
                  ),
                )
              : Container(
                  // child: Text("22"),
                  )
        ],
      ),
    );
    return Container(
      child: a,
      width: 50,
      height: 12,
    );
  }
}
