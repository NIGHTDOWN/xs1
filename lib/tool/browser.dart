// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import 'function.dart';

// class Browser extends StatelessWidget {
//   const Browser({Key key, this.url, this.title}) : super(key: key);

//   final String url;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       //  appBar: AppBar(
//       //    title: Text(title),
//       //  ),
//       body: WebView(
//           initialUrl: url,
//           javascriptMode: JavascriptMode.unrestricted,
//           onWebViewCreated: (WebViewController webview) async {
//             //对webview做处理
//            d(await webview.currentUrl()) ;
//             // return webview.reload();
//           }),
//     );
//   }
// }
