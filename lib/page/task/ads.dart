// // 这里是fb广告代码
// import 'dart:io';

// import 'package:firebase_admob/firebase_admob.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:ng169/model/base.dart';
// import 'package:ng169/tool/function.dart';
// import 'package:ng169/tool/global.dart';
// import 'package:ng169/tool/lang.dart';
// import 'package:ng169/conf/conf.dart';
// import 'package:ng169/style/FrameAnimationImage.dart';

// class Ads {
//   MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//     // testDevices: [testDevice],
//     // keywords: <String>['foo', 'bar'],
//     contentUrl: 'https://lookstory.xyz',
//     childDirected: false,
//     nonPersonalizedAds: true,
//   );
//   // int _coins = 0;
//   bool isload = false;
//   bool isget = false;
//   String adappid = 'ca-app-pub-1390959630806254~6526996358'; //app id
//   String adid = 'ca-app-pub-1390959630806254/7843931549'; //app广告位id
//   String debugadid = 'ca-app-pub-3940256099942544/5224354917'; //app广告位id
//   BannerAd bannerAd;
//   NativeAd _nativeAd;
//   var call;
//   init() {
//     FirebaseAdMob.instance.initialize(appId: adappid);
//     // bannerAd = createBannerAd()..load();
//     // getnvad();
//     RewardedVideoAd.instance.listener =
//         (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
//       d("RewardedVideoAd event $event");
//       if (event == RewardedVideoAdEvent.failedToLoad) {
//         d('加载失败');
//         show(g('context'), lang('视频加载失败'));
//         // pop(g('context'));
//       }
//       if (event == RewardedVideoAdEvent.loaded) {
//         d('加载成功');
//         isload = true;
//         showad();
//       }
//       if (event == RewardedVideoAdEvent.rewarded) {
//         //看完谷歌广告成功领取奖励
//         d('结算');
//         isget = true;
//       }
//       if (event == RewardedVideoAdEvent.closed) {
//         //看完谷歌广告成功领取奖励
//         d('结算返回');
//         //  pop(g('context'));
//         // pop(g('context'), isget ? 1 : 0);
//         if (isnull(call)) {
//           call(isget);
//           //回调之后上次结算重置
//           isget = false;
//         }
//         // isget = true;
//       }
//     };
//   }

//   BannerAd createBannerAd() {
//     return BannerAd(
//       adUnitId: BannerAd.testAdUnitId,
//       size: AdSize.banner,
//       targetingInfo: targetingInfo,
//       listener: (MobileAdEvent event) {
//         d("BannerAd event $event");
//       },
//     );
//   }

//   getbanner() {
//     return bannerAd..show(horizontalCenterOffset: -150, anchorOffset: 100);
//   }

// //加载广告
//   load(callback) async {
//     call = callback;
//     await RewardedVideoAd.instance.load(
//         adUnitId: isdebug ? debugadid : adid, targetingInfo: targetingInfo);
//   }

// //显示激励广告
//   showad() {
//     RewardedVideoAd.instance.show();
//   }

//   createNativeAd() async {
//     //  createNativeAd()..load();
//     // return NativeAd(
//     //   adUnitId: 'ca-app-pub-3940256099942544/2247696110',
//     //   factoryId: 'adFactoryExample',
//     //   targetingInfo: targetingInfo,
//     //   listener: (MobileAdEvent event) {
//     //     print("$NativeAd event $event");
//     //   },
//     // );
//   }

//   getnvad() {
//     NativeAd(
//       adUnitId: 'ca-app-pub-3940256099942544/2247696110',
//       factoryId:
//           'adFactoryExample', //这里要重写java NativeAdFactory ,然后在mainactivity里面注册，很麻烦，弃用
//       targetingInfo: targetingInfo,
//       listener: (MobileAdEvent event) {
//         print("$NativeAd event $event");
//       },
//     )
//       ..load()
//       ..show(
//         anchorType: Platform.isAndroid ? AnchorType.bottom : AnchorType.top,
//       );
//     return _nativeAd;
//     // ..load()
//   }
// }
