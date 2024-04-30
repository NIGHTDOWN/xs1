import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

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
      this.level = await Battery().batteryLevel;
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
        this.batteryLevel = 0;
      });
    }
  }

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
            margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
            width: batteryLevel > 0 ? 20 * batteryLevel : 0,
            color: Styles.getTheme()['titlefontcolor'],
          ),
          isnull(levels)
              ? Container(
                  margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                  //width: 20 * batteryLevel,
                  child: Text(
                    levels.toString(),
                    style: TextStyle(
                      fontSize: 1.0,
                      fontWeight: FontWeight.bold,
                      color: Styles.getTheme()['batteryfontcolor'],
                    ),
                  ),
                )
              : Container()
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
