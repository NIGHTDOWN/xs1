import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:ng169/model/cacheimg.dart';
import 'package:ng169/style/FrameAnimationImage.dart';

import 'dart:async' show Future;
import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ng169/tool/down.dart';

import 'function.dart';
import 'global.dart';

class NgImage extends StatelessWidget {
  final String imgUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget placeholder;
  bool localcache = false;

  NgImage(this.imgUrl,
      {this.width, this.height, this.fit = BoxFit.cover, this.placeholder});

//   @override
//   State<StatefulWidget> createState() => NgImageState();
// }

// class NgImageState extends State<NgImage> with SingleTickerProviderStateMixin {
  // bool isloclpic = false;
  // String getlocalname(String url) {
  //   return Cacheimg.getloclpicname(url);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   islocol(widget.imgUrl);
  // }

  //返回图片本地名
  // Widget getloclpic(String url) {
  //   try {
  //     var file =new File(getlocalname(url));
  //     d(url);
  //     d(file);
  //     if (isnull(file)) {
  //       return Image.file(
  //         File(getlocalname(url)),
  //         width: widget.width,
  //         height: widget.height,
  //       );
  //     }
  //   } catch (e) {
  //     return _cachednetworkimage();
  //   }
  //   return _cachednetworkimage();
  // }

  Widget _cachednetworkimage() {
    //匹配mock数据
    String ismock = imgUrl.substring(0, 5);

    if (ismock == 'mock:') {
      String mockpng = imgUrl.substring(5);
      return Image.asset(
        "assets/images/mock/" + mockpng,
        width: width,
        height: height,
      );
    }
    var errorWidget = Image.asset(
      'assets/images/bookbg.jpg',
      width: width,
      height: height,
    );
    var img = imgUrl;
    if (ismock == 'dsl:/') {
      String dsl = imgUrl.substring(5);
      // var domian=false;
      if (dslStatus && isnull(dslDomain)) {
        img = dslDomain + dsl;
      } else {
        return errorWidget;
      }
    }
    try {
      return CachedNetworkImage(
        imageUrl: img,
        fit: fit,
        // useOldImageOnUrlChange: true,
        width: width,
        height: height,
        //添加预加载视图
        // errorWidget: (context, url, error) => new Icon(
        //   Icons.error,
        //   size: width,
        // ),
        errorWidget: (context, url, error) => errorWidget,
        placeholder: (context, index) {
          if (isnull(placeholder)) {
            return placeholder;
          }
          return FrameAnimationImage(
            width: width,
            height: height,
            interval: 100,
          );
        },
        // decoration: BoxDecoration(border: Border.all(color: SQColor.paper)),
      );
    } catch (e) {
      //远程加载失败，直接返回错误图片
      return errorWidget;
    }
  }

  // islocol(String url) async {
  //   if (!await Down.isexits(getlocalname(url))) {
  //     //下载
  //     g('downthred').send(url);
  //     if (mounted) {
  //       setState(() {
  //         isloclpic = false;
  //       });
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {
  //       isloclpic = true;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return _cachednetworkimage();
  }
}

typedef void ErrorListener();

class CachedNetworkImageProvider
    extends ImageProvider<CachedNetworkImageProvider> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.
  const CachedNetworkImageProvider(this.url,
      {this.scale: 1.0, this.errorListener, this.headers, this.cacheManager})
      : assert(url != null),
        assert(scale != null);

  final BaseCacheManager cacheManager;

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

  @override
  ImageStreamCompleter load(CachedNetworkImageProvider key, decode) {
    return new MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
// TODO enable information collector on next stable release of flutter
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
//     // TODO: implement load
//     return null;
//   }
  Future<ui.Codec> _loadAsync(CachedNetworkImageProvider key) async {
    var mngr = cacheManager ?? DefaultCacheManager();
    var file = await mngr.getSingleFile(url, headers: headers);
    if (file == null) {
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
      if (errorListener != null) errorListener();
      throw new Exception("File was empty");
    }

    return await ui.instantiateImageCodec(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final CachedNetworkImageProvider typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
