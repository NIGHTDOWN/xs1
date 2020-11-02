// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_review/in_app_review.dart';
// import 'package:ng169/model/base.dart';

// class Apppj extends LoginBase {
//   final InAppReview _inAppReview = InAppReview.instance;
//   String _appStoreId = '';
//   bool _isAvailable;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (Platform.isIOS || Platform.isMacOS) {
//         _inAppReview.isAvailable().then((bool isAvailable) {
//           setState(() {
//             _isAvailable = isAvailable;
//           });
//         });
//       } else {
//         setState(() {
//           _isAvailable = false;
//         });
//       }
//     });
//   }

//   void _setAppStoreId(String id) => _appStoreId = id;

//   Future<void> _requestReview() async {
//     if (await _inAppReview.isAvailable()) {
//       _inAppReview.requestReview();
//     }
//   }

//   Future<void> _openStoreListing() =>
//       _inAppReview.openStoreListing(appStoreId: _appStoreId);

//   @override
//   Widget build(BuildContext context) {
//     const loadingMessage = 'LOADING';
//     const availableMessage = 'AVAILABLE';
//     const unavailableMessage = 'UNAVAILABLE';

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('InAppReview Example')),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'InAppReview status: ${_isAvailable == null ? loadingMessage : _isAvailable ? availableMessage : unavailableMessage}',
//             ),
//             TextField(
//               onChanged: _setAppStoreId,
//               decoration: InputDecoration(hintText: 'App Store ID'),
//             ),
//             RaisedButton(
//               onPressed: _requestReview,
//               child: Text('Request Review'),
//             ),
//             RaisedButton(
//               onPressed: _openStoreListing,
//               child: Text('Open Store Listing'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }