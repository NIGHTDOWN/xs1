import 'dart:convert';

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

//图片本地缓存
class NgImageLocl extends StatefulWidget {
  final String imgUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget placeholder;

  NgImageLocl(this.imgUrl,
      {this.width, this.height, this.fit, this.placeholder});

  @override
  State<StatefulWidget> createState() => NgImageLoclState();
}

class NgImageLoclState extends State<NgImageLocl>
    with SingleTickerProviderStateMixin {
  bool isloclpic = false;
  bool ischeck = false;
  String getlocalname(String url) {
    return Cacheimg.getloclpicname(url);
  }

  @override
  void initState() {
    super.initState();
    ischeck = false;
    islocol(widget.imgUrl);
  }

  Widget _placeholder() {
    if (isnull(widget.placeholder)) {
      return widget.placeholder;
    }
    return FrameAnimationImage(
      width: widget.width,
      height: widget.height,
      interval: 100,
    );
  }

  //返回图片本地名
  Widget getloclpic(String url) {
    // try {
    var file = new File(getlocalname(url));

    if (isnull(file)) {
      return Image.file(
        File(getlocalname(url)),
        width: widget.width,
        height: widget.height,
      );
    }
    return _placeholder();
  }

  Widget _cachednetworkimage() {
    return Image.network(
      widget.imgUrl,
      width: widget.width,
      height: widget.height,
    );
  }

  islocol(String url) async {
    if (!await Down.isexits(getlocalname(url))) {
      //下载
      g('downthred').send(url);
      if (mounted) {
        setState(() {
          ischeck = true;
          isloclpic = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          ischeck = true;
          isloclpic = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ischeck) {
      return _placeholder();
    }
    if (isloclpic) {
      return getloclpic(widget.imgUrl);
    }

    return _cachednetworkimage();
  }
}
