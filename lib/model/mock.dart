import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:ng169/tool/function.dart';

class Mock {
  //初始化mock数据
  static Map<String, dynamic> mockjson = {};
  static init(String city) async {
    // d('加载mock' + city);
    if (!isnull(city)) {
      return false;
    }
    mockjson = {};
    try {
      var tmp = await rootBundle.loadString('assets/mock/$city.mock'); //加载语言文件
      mockjson = json.decode(tmp);
      // d('加载完成');
      // d(mockjson);
    } catch (e) {
      dt(e);
    }
  }

  static get(name) {
    if (isnull(mockjson, name)) {
      var val = mockjson[name];
      if (isnull(val)) {
        return val;
      }
    }
    return [];
  }
}
