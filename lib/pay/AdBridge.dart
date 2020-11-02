import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:ng169/tool/function.dart';

typedef ASuccessCallback = void Function([dynamic data]);
typedef AFailureCallback = void Function([dynamic data]);
typedef ACancelCallback = void Function([dynamic data]);

//安卓桥
class AdBridge {
  static MethodChannel _channel = MethodChannel('com.ng.story/adbridge');

  static ASuccessCallback success = null;
  static AFailureCallback fail = null;
  static ACancelCallback cancel = null;

  static Future<dynamic> call(String functions,
      [Map<String, dynamic> params]) async {
    dynamic data = await _channel.invokeMethod(functions, params);
    _channel.setMethodCallHandler(_javaCallHandler);
    return data;
  }

  static void callback(
  {  ASuccessCallback function_success,
    AFailureCallback function_fail,
    ACancelCallback function_cancel}
  ) {
    if (isnull(function_success)) {
      success = function_success;
    }
    if (isnull(function_fail)) {
      fail = function_fail;
    }
    if (isnull(function_cancel)) {
      cancel = function_cancel;
    }
    // return data;
  }

  static Future<dynamic> _javaCallHandler(MethodCall call) async {
    d('Call to native call handler:\n');
    d(call.method);
    d(call.arguments);
    var result = call.arguments;
    try {
      switch (call.method) {
        case 'success':
          if (success != null) {
            success(result);
          }
          break;
        case 'fail':
          if (fail != null) {
            fail(result);
          }
          break;
        case 'cancel':
          if (cancel != null) {
            cancel(result);
          }
          break;
        default:
          throw Exception('unknown method called from native');
      }
    } on Exception catch (ex) {
      d('nativeCallHandler caught an exception:\n');
      d(ex);
    }
    return false;
  }
}
