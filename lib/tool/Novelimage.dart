import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/obj/novel.dart';
import 'package:ng169/page/smallwidget/gifcartoon.dart';

import 'dart:async' show Future;
import 'dart:io' show File;

import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ng169/page/smallwidget/gifcartoon2.dart';
import 'package:ng169/tool/image.dart';
import 'package:ng169/tool/t.dart';

import 'function.dart';
import 'global.dart';

// ignore: must_be_immutable
class Novelimage extends LoginBase {
  final Novel novel;
  late Novelimage obj;
  late final double? width;
  late final double? height;
  final BoxFit fit;
  static Widget placeholder = GifCartoon2();
  bool localcache = false;

  bool needyzj;
  String dsl = "";
  String? imgUrl = "";
  Widget img = Container();
  bool isload = false;
  static Widget errorimage = Container();
  Novelimage(
    this.novel, {
    double? width,
    double? height,
    this.fit = BoxFit.cover,
    this.needyzj = false,
  }) {
    this.width = width;
    this.height = height;
    dsl = novel.imgUrldsl;
    imgUrl = novel.imgUrl;
    errorimage = getpathimg("assets/images/bookbg.jpg");
    this.obj = this;
  }
  static yjz(bool needyjz, Novel novel) {
    // if (needyjz) {
    //   d("预加载" + imgUrl);
    // }
    return true;
  }

  Widget getpathimg(String img) {
    if (isnull(height) && isnull(width))
      return Image.asset(
        img,
        width: width,
        height: height,
      );
    if (isnull(height))
      return Image.asset(
        img,
        height: height,
      );
    if (isnull(width))
      return Image.asset(
        img,
        width: width,
      );
    return Image.asset(
      img,
    );
  }

  getfromdb() async {
    var data = await T("dslimg").where({"simg": novel.imgUrl}).getone();

    if (isnull(data)) {
      if (data['flag'] == 1) {
        if (isnull(data['dslimg'])) {
          obj.trueimgurl = data['dslimg'];
          obj.isload = true;
          reflash();
          return true;
        }
      }
    }
    getfromremote();
    return false;
  }

  Future<bool> checkImageExists(String url) async {
    Dio dio = Dio();
    try {
      Response response = await dio.head(url);
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> getImageSizeFromBase64(String base64String) async {
    try {
      // 将Base64字符串解码为Uint8List
      Uint8List imageBytes = Uint8List.fromList(base64Decode(base64String));

      // 使用Uint8List创建Image对象
      Image image = Image.memory(imageBytes);

      // 获取图片尺寸信息
      image.image.resolve(ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool sync) {
          obj.sw = info.image.width + 0.0;
          obj.sh = info.image.height + 0.0;
          // 在这里，info.image就是Image对象，info.width和info.height是图片的尺寸
          // d('Image width: ${info.image.width}, height: ${info.image.height}');
        }),
      );
    } catch (e) {
      // 处理异常
      d('Error getting image size: $e');
    }
  }

  Future<String?> getImageBase64(String url) async {
    Dio dio = Dio();
    try {
      Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        List<int> bytes = response.data;
        String base64Image = base64Encode(bytes);
        //获取图片的宽度和高度
        await getImageSizeFromBase64(base64Image); //获取尺寸
        obj.b64 = base64Image;
        savedb();
        return base64Image;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String trueimgurl = "";
  bool flag = false;
  //从网络获取
  getfromremote() async {
    //判断远程图片是否存在
    obj.flag = await checkImageExists(imgUrl!);

    if (flag) {
      obj.trueimgurl = imgUrl!;
    } else {
      if (isnull(dsl)) {
        obj.trueimgurl = dsl;
        d(trueimgurl);
      } else {
        obj.trueimgurl = imgUrl!;
      }

      //如果不存在就保存到本地
    }

    getImageBase64(trueimgurl);
    obj.isload = true;

    reflash();
    //如果存在就保存到数据库
    //如果不存在就保存到本地
  }

  double sw = 0, sh = 0;
  String b64 = "";
  String getdslimg(String dslimgtmp) {
    if (!isnull(dslimgtmp)) return "";
    String dslimg = dslimgtmp.substring(5);
    if (dslStatus && isnull(dslDomain)) {
      dslimg = dslDomain + dslimg;
    }
    return dslimg;
  }

  savedb() async {
    //保存到数据库
    var whree = {"simg": novel.imgUrl};
    var dbdata = await T("dslimg").where(whree).getone();
    var data = {
      "simg": obj.novel.imgUrl,
      "flag": obj.flag ? 1 : 0,
      "dsl": obj.dsl,
      "dslimg": obj.getdslimg(dsl),
      "width": obj.sw,
      "height": obj.sh,
      "b64": obj.b64
    };
    // d(data);
    if (!isnull(dbdata)) {
      T("dslimg").insert(data);
    } else {
      T("dslimg").where(whree).update(data);
    }
  }

  @override
  void initState() {
    //先直接从数据库拿；
    //数据库没有在识别
    getfromdb();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isload) {
      //placeholder固定宽度高度
      if (!isnull(width)) {
        return placeholder;
      } else {
        img = Container(
          width: width,
          height: height,
          child: placeholder,
        );
        return img;
      }
    }
    return NgImage(obj.trueimgurl,
        width: width, height: height, fit: fit, placeholder: placeholder);
  }
}
