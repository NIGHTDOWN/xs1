// // import 'package:advertising_id/advertising_id.dart';
// // import 'package:facebook_audience_network/facebook_audience_network.dart';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:ng169/model/base.dart';
// import 'package:ng169/tool/function.dart';
// import 'package:tencent_ad/reward.dart';
// import 'package:tencent_ad/tencent_ad.dart';

// // 这里是fb广告代码
// class Ads extends LoginBase {
//   RewardAD rewardAD;
//   num money = 0.00;
//   String posID = '9071022124870538';
//   String appID = '1110638681';

//   @override
//   void initState() {
//     super.initState();
//     loadad();
//   }

//   loadad() async {
//     await TencentADPlugin.config(appID: appID);
//     rewardAD = RewardAD(posID: posID, adEventCallback: _adEventCallback);
//     rewardAD.loadAD();
//     money = Random().nextDouble() + Random().nextInt(100);
//   }

//   @override
//   Widget build(BuildContext context) => Container();

//   void _adEventCallback(RewardADEvent event, Map params) {
//     switch (event) {
//       case RewardADEvent.onADLoad:
//         rewardAD.showAD();
//         break;
//       case RewardADEvent.onADClose:
//       case RewardADEvent.onVideoComplete:
//         pop(context, 1);
//         // Navigator.of(context).pop();
//         // showDialog(
//         //     context: context,
//         //     builder: (context) {
//         //       return Center(
//         //         child: ClipRRect(
//         //           clipBehavior: Clip.antiAliasWithSaveLayer,
//         //           borderRadius: BorderRadius.circular(32.0),
//         //           child: Card(
//         //             child: Container(
//         //               width: 320.0,
//         //               height: 280.0,
//         //               color: Colors.red,
//         //               alignment: Alignment.center,
//         //               child: Text(
//         //                 '恭喜你获得${money.toStringAsFixed(2)}元',
//         //                 textScaleFactor: 2.1,
//         //               ),
//         //             ),
//         //           ),
//         //         ),
//         //       );
//         //     });
//         break;
//       default:
//     }
//   }
// }
