import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/http.dart';

class Upfile {
  static upload(String filepath) async {
    if (isnull(filepath)) {
      var tmp = await httpfile('upimg/run',
          {'file': await MultipartFile.fromFile(filepath)}, gethead());
      return tmp;
    }
    return "";
  }

  static Future<String?> toWebp(String filepath) async {
    final Directory tempDir = Directory.systemTemp; // 获取系统临时目录
    final String tempPath = tempDir.path; // 获取临时目录路径

    // 压缩图片并转换为WebP格式
    final compressedImage = await FlutterImageCompress.compressWithFile(
      filepath,
      quality: 100, // 0-100，100为无损
      format: CompressFormat.webp,
    );

    // 确保压缩后的图片数据不为空
    if (compressedImage == null) {
      return null;
    }

    // 创建一个新的文件路径用于保存WebP图片
    final String webpPath =
        '$tempPath/image_${DateTime.now().millisecondsSinceEpoch}.webp';

    // 将压缩后的图片数据写入文件
    await File(webpPath).writeAsBytes(compressedImage);

    // 返回转换后的WebP图片的文件路径
    return webpPath;
    //  compressedImages 是 Uint8List；现在要返回的是转换后的webp路径
  }

  static upimg(String filepath) async {
    if (isnull(filepath)) {
      //把各类图片格式全部转webp在上传
      var webppath = await toWebp(filepath);

      var tmp = await httpfile('upimg/run',
          {'file': await MultipartFile.fromFile(webppath!)}, gethead());
      return tmp;
    }
  }
}
