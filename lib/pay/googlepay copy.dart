// import 'package:flutter/material.dart';
// import 'package:google_pay/google_pay.dart';


// import 'package:ng169/style/screen.dart';
// import 'package:ng169/style/sq_color.dart';
// import 'package:ng169/tool/function.dart';
// import 'package:ng169/tool/http.dart';
// import 'package:ng169/tool/lang.dart';
// import 'package:flutter/services.dart';



// class Googlepay extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => GooglepayState();
// }

// class GooglepayState extends State<Googlepay> {
//   String api = 'order/get_charge';
//   String _platformVersion = 'Unknown';
//   String _googlePayToken = 'Unknown';
//   Future<void> gethttpdata() async {
//     // var tmp = await http(api, null, gethead());

//     // setcache(cachedata, prolist, '3600');
//     // refresh();
//   }

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//     loadpage();
//   }

//   // 初始化谷歌支付sdk.
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       platformVersion = await GooglePay.platformVersion;
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }
//     d(platformVersion);
//     //await GooglePay.initializeGooglePay("payidls_1");
//     //await GooglePay.initializeGooglePay("pk_test_H5CJvRiPfCrRS44bZJLu46fM00UjQ0vtRN");
//     await GooglePay.initializeGooglePay(
//         "pk_test_JG1ze3xBAOzZlOjGwAWrRhkB004LdyGdxS");

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }

//   //加载页面
//   //先读缓存
//   //在读http数据
//   loadpage() async {}

//   refresh() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('googlepay sdk'),
//         ),
//         body: Center(
//           child: Column(children: <Widget>[
//             Text('Running on: $_platformVersion\n'),
//             Text('Google pay token: $_googlePayToken\n'),
//             FlatButton(
//               child: Text("Google Pay Button"),
//               onPressed: onButtonPressed,
//             )
//           ]),
//         ),
//       ),
//     );
//   }

//   void onButtonPressed() async {
//     setState(() {
//       _googlePayToken = "Fetching";
//     });
//     return ;
//     try {
//       await GooglePay.openGooglePaySetup(
//           price: "1.0",
//           onGooglePaySuccess: onSuccess,
//           onGooglePayFailure: onFailure,
//           onGooglePayCanceled: onCancelled);
//       setState(() {
//         _googlePayToken = "Done Fetching";
//       });
//     } on PlatformException catch (ex) {
//       setState(() {
//         _googlePayToken = "Failed Fetching";
//       });
//     }
//   }

//   void onSuccess(String token) {
//     setState(() {
//       _googlePayToken = token;
//     });
//   }

//   void onFailure() {
//     setState(() {
//       _googlePayToken = "Failure";
//     });
//   }

//   void onCancelled() {
//     setState(() {
//       _googlePayToken = "Cancelled";
//     });
//   }
// }
