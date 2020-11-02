//图片缓存类
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:ng169/tool/down.dart';

class Cacheimg {
  static String path = '/mnt/sdcard/story/';
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return digest.toString();
    // return hex.encode(digest.bytes);
  }

  //下载图片到本地
  static downpic(String url) async {
    //需要放入下载队列线程
    // var name = generateMd5(url);
    // var file = path + name;
    var file = getloclpicname(url);
    await Down.getfile(url, file);
  }

  //返回图片本地名
  static String getloclpicname(String url) {

    var name = generateMd5(url);
    var file = path + name+'.png';
    return file;
  }

  static Future<bool> islocol(String url) async {
    var dir = path;
    if (!await Down.checkpath(dir)) {
      return false;
    }
    var file = getloclpicname(url);
    if (!await Down.isexits(file)) {
      await downpic(url);
    }
    return true;
  }
}
