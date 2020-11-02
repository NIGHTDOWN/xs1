// import 'package:advertising_id/advertising_id.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
// import 'package:flutter/material.dart';
// import 'package:ng169/model/base.dart';
// import 'package:ng169/tool/function.dart';
//这里是fb广告代码
// class Ads extends LoginBase {
//   bool _isInterstitialAdLoaded = false;
//   bool _isRewardedAdLoaded = false;
//   bool _isRewardedVideoComplete = false;
//   String fbplacementId = '309300910199195_309421653520454';

//   /// All widget ads are stored in this variable. When a button is pressed, its
//   /// respective ad widget is set to this variable and the view is rebuilt using
//   /// setState().
//   Widget _currentAd = SizedBox(
//     width: 0.0,
//     height: 0.0,
//   );

//   @override
//   void initState() {
//     super.initState();

//     FacebookAudienceNetwork.init(
//       testingId: "b9f2908b-1a6b-4a5b-b862-ded7ce289e41",
//     );

//     _loadInterstitialAd();
//     _loadRewardedVideoAd();
//   }

//   Future<void> _loadInterstitialAd() async {
//     // d(await AdvertisingId.id);
//     FacebookInterstitialAd.loadInterstitialAd(
//       placementId: fbplacementId,
//       // "IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617", //"IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617" YOUR_PLACEMENT_ID
//       listener: (result, value) {
//         print(">> FAN > Interstitial Ad: $result --> $value");
//         if (result == InterstitialAdResult.LOADED)
//           _isInterstitialAdLoaded = true;

//         /// Once an Interstitial Ad has been dismissed and becomes invalidated,
//         /// load a fresh Ad by calling this function.
//         if (result == InterstitialAdResult.DISMISSED &&
//             value["invalidated"] == true) {
//           _isInterstitialAdLoaded = false;
//           _loadInterstitialAd();
//         }
//       },
//     );
//   }

//   void _loadRewardedVideoAd() {
//     FacebookRewardedVideoAd.loadRewardedVideoAd(
//       placementId: fbplacementId,
//       listener: (result, value) {
//         print("Rewarded Ad: $result --> $value");
//         if (result == RewardedVideoAdResult.LOADED) _isRewardedAdLoaded = true;
//         if (result == RewardedVideoAdResult.VIDEO_COMPLETE)
//           _isRewardedVideoComplete = true;

//         /// Once a Rewarded Ad has been closed and becomes invalidated,
//         /// load a fresh Ad by calling this function.
//         if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
//             value["invalidated"] == true) {
//           _isRewardedAdLoaded = false;
//           _loadRewardedVideoAd();
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Flexible(
//           child: Align(
//             alignment: Alignment(0, -1.0),
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: _getAllButtons(),
//             ),
//           ),
//           fit: FlexFit.tight,
//           flex: 2,
//         ),
//         // Column(children: <Widget>[
//         //   _nativeAd(),
//         //   // _nativeBannerAd(),
//         //   _nativeAd(),
//         // ],),
//         Flexible(
//           child: Align(
//             alignment: Alignment(0, 1.0),
//             child: _currentAd,
//           ),
//           fit: FlexFit.tight,
//           flex: 3,
//         )
//       ],
//     );
//   }

//   Widget _getAllButtons() {
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 2,
//       childAspectRatio: 3,
//       children: <Widget>[
//         _getRaisedButton(title: "Banner Ad", onPressed: _showBannerAd),
//         _getRaisedButton(title: "Native Ad", onPressed: _showNativeAd),
//         _getRaisedButton(
//             title: "Native Banner Ad", onPressed: _showNativeBannerAd),
//         _getRaisedButton(
//             title: "Intestitial Ad", onPressed: _showInterstitialAd),
//         _getRaisedButton(title: "Rewarded Ad", onPressed: _showRewardedAd),
//         _getRaisedButton(title: "InStream Ad", onPressed: _showInStreamAd),
//       ],
//     );
//   }

//   Widget _getRaisedButton({String title, void Function() onPressed}) {
//     return Padding(
//       padding: EdgeInsets.all(8),
//       child: RaisedButton(
//         onPressed: onPressed,
//         child: Text(
//           title,
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   _showInterstitialAd() {
//     if (_isInterstitialAdLoaded == true)
//       FacebookInterstitialAd.showInterstitialAd();
//     else
//       print("Interstial Ad not yet loaded!");
//   }

//   _showRewardedAd() {
//     if (_isRewardedAdLoaded == true)
//       FacebookRewardedVideoAd.showRewardedVideoAd();
//     else
//       print("Rewarded Ad not yet loaded!");
//   }

//   _showInStreamAd() {
//     setState(() {
//       _currentAd = FacebookInStreamVideoAd(
//         height: 300,
//         listener: (result, value) {
//           print("In-Stream Ad: $result -->  $value");
//           if (result == InStreamVideoAdResult.VIDEO_COMPLETE) {
//             setState(() {
//               _currentAd = SizedBox(
//                 height: 0,
//                 width: 0,
//               );
//             });
//           }
//         },
//       );
//     });
//   }

//   _showBannerAd() {
//     setState(() {
//       _currentAd = FacebookBannerAd(
//         placementId: fbplacementId,
//         //     "IMG_16_9_APP_INSTALL#2312433698835503_2964944860251047", //testid
//         bannerSize: BannerSize.STANDARD,
//         listener: (result, value) {
//           print("Banner Ad: $result -->  $value");
//         },
//       );
//     });
//   }

//   _showNativeBannerAd() {
//     setState(() {
//       _currentAd = _nativeBannerAd();
//     });
//   }

//   Widget _nativeBannerAd() {
//     return FacebookNativeAd(
//       placementId: fbplacementId,
//       // placementId: "IMG_16_9_APP_INSTALL#2312433698835503_2964953543583512",
//       adType: NativeAdType.NATIVE_BANNER_AD,
//       bannerAdSize: NativeBannerAdSize.HEIGHT_100,
//       width: double.infinity,
//       backgroundColor: Colors.blue,
//       titleColor: Colors.white,
//       descriptionColor: Colors.white,
//       buttonColor: Colors.deepPurple,
//       buttonTitleColor: Colors.white,
//       buttonBorderColor: Colors.white,
//       listener: (result, value) {
//         print("Native Banner Ad: $result --> $value");
//       },
//     );
//   }

//   _showNativeAd() {
//     setState(() {
//       _currentAd = _nativeAd();
//     });
//   }

//   Widget _nativeAd() {
//     return FacebookNativeAd(
//       // placementId: "IMG_16_9_APP_INSTALL#2312433698835503_2964952163583650",
//       placementId: fbplacementId,
//       adType: NativeAdType.NATIVE_AD,
//       width: double.infinity,
//       height: 300,
//       backgroundColor: Colors.blue,
//       titleColor: Colors.white,
//       descriptionColor: Colors.white,
//       buttonColor: Colors.deepPurple,
//       buttonTitleColor: Colors.white,
//       buttonBorderColor: Colors.white,
//       listener: (result, value) {
//         print("Native Ad: $result --> $value");
//       },
//       keepExpandedWhileLoading: false,
//       expandAnimationDuraion: 1000,
//     );
//   }
// }
