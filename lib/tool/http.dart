import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
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
Future<String?> http(String url,
    [Map<String, dynamic>? datas,
    Map<String, dynamic>? header,
    int? reqlockmiao]) async {
  Dio dio = Dio();
  //设置代理
  dio.options.baseUrl = apiurl;
  //设置连接超时时间
  dio.options.connectTimeout = 10000;
  //设置数据接收超时时间
  dio.options.receiveTimeout = 10000;
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
  dio.options.baseUrl = apiurl;
  dio.options.receiveTimeout = 0;
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

dynamic getdata(BuildContext context, String? responseData) {
  var js;
  if (!isnull(responseData)) {
    //请求无数据返回的时候不要报错
    return null;
  }
  try {
    js = jsonDecode(responseData!);
  } catch (e) {
    d(e);
    if (loghttpcn) {
      show(context, lang('请求错误：1'));
    } else {
      if (isdebug) {
        show(context, '404');
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
    show(context, lang('请登入'));
    gourl(context, new Index() as WidgetBuilder);
    return null;
  } else {
    if (loghttpcn) {
      show(context, js['msg']);
    } else {
      show(context, js['code']);
    }
    return null;
  }
}

Future<String> httpfile(String url,
    [Map<String, dynamic>? datas, Map<String, dynamic>? header]) async {
  Dio dio = Dio();
  //设置代理

  dio.options.baseUrl = apiurl;
  //设置连接超时时间
  dio.options.connectTimeout = 10000;
  //设置数据接收超时时间
  dio.options.receiveTimeout = 10000;
  // dio.options.headers[HttpHeaders.authorizationHeader] = '1233';
  // dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

  if (null != header) {
    d(header);
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
  } on DioError catch (e) {
    d("请求失败: $e");
  }

  return '';
}
