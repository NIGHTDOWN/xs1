// import 'package:location/location.dart';
// import 'package:ng169/tool/function.dart';

// class Locatetiones {
//   //获取定位
//   static Future getlocation() async {
//     Location location = Location();
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//     LocationData _locationData;
//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//     _locationData = await location.getLocation();
//     return _locationData;
//   }

//   //获取定位经纬度
//   getwd() {
//     getlocation().then((value) {
//       if (value != null) {
//         d(value);
//       }
//     });
//   }

//   //获取定位地址；非经纬度
//   getaddress() {
//     getlocation().then((value) {
//       if (value != null) {
//         d(value);
//       }
//     });
//   }
// }
