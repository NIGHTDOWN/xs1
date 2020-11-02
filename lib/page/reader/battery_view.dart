import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';

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
    // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // if (Platform.isAndroid) {
    //   var androidInfo = await deviceInfo.androidInfo;
    //   if (!androidInfo.isPhysicalDevice) {
    //     return;
    //   }
    // }
    // if (Platform.isIOS) {
    //   var iosInfo = await deviceInfo.iosInfo;
    //   if (!iosInfo.isPhysicalDevice) {
    //     return;
    //   }
    // }

    this.level = await Battery().batteryLevel;
    if (!mounted) return;
    setState(() {
      levels = level;
      this.batteryLevel = level / 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 12,
      child: Stack(
        children: <Widget>[
          Image.asset(
            'assets/images/reader_battery.png',
            color: Styles.getTheme()['batterycolor'],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
            width: 20 * batteryLevel,
            color: Styles.getTheme()['titlefontcolor'],
          ),
          isnull(levels)
              ? Container(
                  margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                  //width: 20 * batteryLevel,

                  child: Text(
                    levels.toString(),
                    style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                      color: Styles.getTheme()['batteryfontcolor'],
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
