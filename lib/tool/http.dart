import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/tool/url.dart';
import 'function.dart';
import 'global.dart';
import 'lang.dart';

dynamic res;
List times = [];
var reqlock = {};
var DeviceTypesSecret = {
  'wxapp': {
    'key': '4c917b5d90a5732cf34e7e5545138f9c',
    'secret': 'dbc0fc07525b37772d47303c1b3d7d98'
  },
  'wap': {
    'key': 'd621b33de3cfa050c7bb8614d6ad50ea',
    'secret': '8a8b79104e3a3695c8b0e06db8a9e5b0'
  },
  'iphone': {
    'key': '755975d21db2ada29e3b279897caffb9',
    'secret': '47281f0bf8bcf5f62cb5190d9e004d7f'
  },
  'android': {
    'key': '9b4af02fddc12d2a38e2deae747beff0',
    'secret': '35ffc40f96f9e129f59c63ca6732578b'
  },
};
getsigin(Map m, String url) {
  String secret = DeviceTypesSecret[m['devicetype']]!['secret']!;
  String key = DeviceTypesSecret[m['devicetype']]!['key']!;
  // 获取所有请求的参数
  Map<String, dynamic> allPar = {
    'apiKey': key,
    'timestamp': m['timestamp'],
    'deviceType': m['devicetype'],
    // 'version': m['version'],
    // 'tokens': m['token'],
    // 'deviceToken': m['idfa'],
  };
  // 根据键对数组进行升序排序
  allPar = Map.fromEntries(
      allPar.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  String hashData = '';
  allPar.forEach((key, value) {
    hashData += value.toString();
  });
  // 生成签名

  String _apiSign = _hmacMd5(hashData, secret);

  return _apiSign;
}

String _hmacMd5(String data, String secret) {
  //md5加密
  var content = new Utf8Encoder().convert(data + secret);
  var result = md5.convert(content);
  return result.toString();
}

Future<String?> http(String url,
    [Map<String, dynamic>? datas,
    Map<String, dynamic>? header,
    int? reqlockmiao]) async {
  Dio dio = Dio();
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback = (cert, host, port) {
      return true; // 返回true强制通过
    };
  };
  // if (!isnull(apiurl)) return "";
  //设置代理
  dio.options.baseUrl = apiurl;
  //设置连接超时时间
  dio.options.connectTimeout = Duration(seconds: 10);
  //设置数据接收超时时间
  dio.options.receiveTimeout = Duration(seconds: 10);
  var index = url.hashCode;
  if (isnull(reqlockmiao)) {
    //配置了避免重复请求
    if (isnull(reqlock, index)) {
      int latime = int.parse(reqlock[index]);
      int now = int.parse(gettime());
      if (now - latime <= reqlockmiao!) {
        //时间间隔太短，不请求数据
        // reqlock[index] = now.toString();
        return null;
      }
      reqlock[index] = now.toString();
    } else {
      // reqlock.addAll({index: gettime()});
      reqlock[index] = gettime();
    }
  }

  int reqstime = DateTime.now().millisecondsSinceEpoch;
  int reqetime = DateTime.now().millisecondsSinceEpoch;
  if (null != header) {
    if (loghttp) {
      d(header);
    }
    header['apisign'] = getsigin(header, url);
    dio.options.headers = header;
  }
  dio.options.contentType =
      ContentType.parse("application/x-www-form-urlencoded").toString();
  try {
    //以表单的形式设置请求参数
    // Map<String, String> queryParameters = {'format': '2', 'key': '939e592487c33b12c509f757500888b5', 'lon': '116.39277', 'lat': '39.933748'};
    if (loghttp || loghttprq) {
      d(url, 2);
      if (isnull(datas) && loghttp) {
        d(datas);
      }
    }
    Response response = await dio.post(url, data: datas);
    if (response.statusCode == 200) {
      res = response;
      var responseData = response.data.toString();
      //var responseData = response.data;
      reqetime = DateTime.now().millisecondsSinceEpoch;
      int b = (reqetime - reqstime);
      if (times.length >= 20) {
        times = [];
      }
      times.add(b);
      if (loghttp) {
        d('耗时' + ':' + (b).toString() + 'ms', 2);
        d(url + ':' + responseData, 2);
      }
      return responseData;
    }
  } catch (e) {
    d("请求失败: $e");
    d(url, 2);
  }
  // on DioError catch (e) {
  //   d("请求失败: $e");
  // }
  return '';
}

//不等待响应
Future<String> httpnodeal(String url,
    [Map<String, dynamic>? datas, Map<String, dynamic>? header]) async {
  Dio dio = Dio();
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback = (cert, host, port) {
      return true; // 返回true强制通过
    };
  };
  dio.options.baseUrl = apiurl;
  dio.options.receiveTimeout = Duration(seconds: 1);
  // dio.options.connectTimeout = 1;
  // dio.options.receiveTimeout = 1;
  if (null != header) {
    dio.options.headers = header;
  }
  dio.options.contentType =
      ContentType.parse("application/x-www-form-urlencoded").toString();
  dio.post(url, data: datas);

  return '';
}

dynamic getres() {
  return res;
}

dynamic getdata(BuildContext? context, String? responseData) {
  var js;
  if (!isnull(context)) {
    context = g("context");
  }
  if (!isnull(responseData)) {
    //请求无数据返回的时候不要报错
    return null;
  }
  try {
    js = jsonDecode(responseData!);
  } catch (e) {
    dt(e);
    if (loghttpcn) {
      show(context!, lang('请求错误：1'));
    } else {
      if (isdebug) {
        show(context!, '404');
      }
    }
    return null;
  }
  int code;
  if (js['code'] is String) {
    code = int.parse(js['code']);
  } else {
    code = js['code'];
  }
  if (code == 1) {
    //请求成功
    return js['result'];
  } else if (code == 100110) {
    //这里清空缓存，重新进入登入页面
    g('cache').del('user');
    User.clear();
    // show(context, js['msg']);
    show(context!, lang('请登入'));
    gourl(context, new Index() as Widget);
    return null;
  } else {
    if (loghttpcn) {
      show(context!, js['msg']);
    } else {
      show(context!, js['code']);
    }
    return null;
  }
}

dynamic Bgetdata(String? responseData) {
  var js;

  if (!isnull(responseData)) {
    //请求无数据返回的时候不要报错
    return null;
  }
  try {
    js = jsonDecode(responseData!);
  } catch (e) {
    dt(e);
    if (loghttpcn) {
      d(('请求错误：1'));
    } else {
      if (isdebug) {
        d('404');
      }
    }
    return null;
  }
  int code;
  if (js['code'] is String) {
    code = int.parse(js['code']);
  } else {
    code = js['code'];
  }
  if (code == 1) {
    //请求成功
    return js['result'];
  }
}

Future<String> httpfile(String url,
    [Map<String, dynamic>? datas, Map<String, dynamic>? header]) async {
  Dio dio = Dio();
  //设置代理
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    client.badCertificateCallback = (cert, host, port) {
      return true; // 返回true强制通过
    };
  };
  dio.options.baseUrl = apiurl;
  //设置连接超时时间
  dio.options.connectTimeout = Duration(seconds: 10);
  //设置数据接收超时时间
  dio.options.receiveTimeout = Duration(seconds: 10);
  // dio.options.headers[HttpHeaders.authorizationHeader] = '1233';
  // dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

  if (null != header) {
    if (loghttp) {
      d(header);
    }
    header['apisign'] = getsigin(header, url);
    dio.options.headers = header;
  }
  dio.options.contentType = ContentType.parse("multipart/form-data").toString();

  try {
    //以表单的形式设置请求参数s
    FormData datatmp = FormData.fromMap(datas!);
    Response response = await dio.post(url, data: datatmp);
    if (response.statusCode == 200) {
      res = response;
      var responseData = response.data.toString();
      //var responseData = response.data;

      d(responseData);
      return responseData;
    }
  } on DioException catch (e) {
    d("请求失败: $e");
  }

  return '';
}
