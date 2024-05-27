import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ng169/page/smallwidget/gifcartoon.dart';

import 'dart:async' show Future;
import 'dart:io' show File;

import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ng169/page/smallwidget/gifcartoon2.dart';

import 'function.dart';
import 'global.dart';

// ignore: must_be_immutable
class NgImage extends StatelessWidget {
  final String imgUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  bool localcache = false;
  String dsl;
  NgImage(this.imgUrl,
      {double? width,
      double? height,
      this.fit = BoxFit.cover,
      this.dsl = "",
      required this.placeholder})
      : this.width = width ?? 0,
        this.height = height ?? 0;

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

  Widget _cachednetworkimage() {
    //匹配mock数据
    String ismock = imgUrl.substring(0, 5);
    String imgp;
    if (ismock == 'mock:') {
      String mockpng = imgUrl.substring(5);
      imgp = "assets/images/mock/" + mockpng;
      return getpathimg(imgp);
    }
    var errorWidget = getpathimg(
      'assets/images/bookbg.jpg',
    );
    var img = imgUrl;

    if (ismock == 'dsl:/') {
      String dslimg = imgUrl.substring(5);
      if (dslStatus && isnull(dslDomain)) {
        img = dsl + dslimg;
      } else {
        return errorWidget;
      }
    }
    try {
      return CachedNetworkImage(
        imageUrl: img,
        fit: fit,
        // useOldImageOnUrlChange: true,
        width: isnull(width) ? width : null,
        height: isnull(height) ? height : null,
        //添加预加载视图

        errorWidget: (context, url, error) => errorWidget,
        placeholder: (context, index) {
          if (isnull(placeholder)) {
            return placeholder;
          }
          return GifCartoon2();
        },
        // decoration: BoxDecoration(border: Border.all(color: SQColor.paper)),
      );
    } catch (e) {
      //远程加载失败，直接返回错误图片
      dt(e);
      return errorWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isnull(dsl)) {
      dsl = dslDomain;
    }
    return _cachednetworkimage();
  }
}

typedef void ErrorListener();

class CachedNetworkImageProvider
    extends ImageProvider<CachedNetworkImageProvider> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.
  const CachedNetworkImageProvider(
    this.url,
    this.cacheManager,
    this.errorListener,
    this.headers, {
    this.scale = 1.0,
  });

  final BaseCacheManager? cacheManager;

  /// Web url of the image to load
  final String url;

  /// Scale of the image
  final double scale;

  /// Listener to be called when images fails to load.
  final ErrorListener errorListener;

  // Set headers for the image provider, for example for authentication
  final Map<String, String> headers;

  @override
  Future<CachedNetworkImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return new SynchronousFuture<CachedNetworkImageProvider>(this);
  }

  ImageStreamCompleter load(CachedNetworkImageProvider key, decode) {
    return new MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,

//      informationCollector: () sync* {
//        yield DiagnosticsProperty<ImageProvider>(
//          'Image provider: $this \n Image key: $key',
//          this,
//          style: DiagnosticsTreeStyle.errorProperty,
//        );
//      },
    );
  }

// @override
//   ImageStreamCompleter load(CachedNetworkImageProvider key, decode) {

//     return null;
//   }
  Future<ui.Codec> _loadAsync(CachedNetworkImageProvider key) async {
    var mngr = cacheManager ?? DefaultCacheManager();
    var file = await mngr.getSingleFile(url, headers: headers);
    // ignore: unnecessary_null_comparison
    if (file == null) {
      // ignore: unnecessary_null_comparison
      if (errorListener != null) errorListener();
      return Future<ui.Codec>.error("Couldn't download or retrieve file.");
    }
    return await _loadAsyncFromFile(key, file);
  }

  Future<ui.Codec> _loadAsyncFromFile(
      CachedNetworkImageProvider key, File file) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      // ignore: unnecessary_null_comparison
      if (errorListener != null) errorListener();
      throw new Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final CachedNetworkImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  // ignore: deprecated_member_use
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
