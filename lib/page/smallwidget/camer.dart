import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/style/FrameAnimationImage.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class camer extends LoginBase {
  static late CameraDescription camera;
  static late CameraController? _controller = null;
  bool needlogin = false;
  int type = 1;
  camer({required this.type});
  initState() {
    d("拍照加载");
    load();
  }

  static bool loadflag = false;
  load() async {
    var list = await availableCameras();
    if (type == 1) {
      camera = list[0];
    } else {
      camera = list[1];
    }
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller?.initialize();
    await Duration(seconds: 5);
    tkpic();
  }

  tkpic() async {
    d("拍照");
    Directory cacheDir = await getTemporaryDirectory();
    String fileName = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';
    // 拼接文件路径
    var pname = '${cacheDir.path}/$fileName';

    XFile? picture = await _controller?.takePicture();
    if (picture == null) {
      throw Exception('Failed to take picture');
    }
    await picture.saveTo(pname);
    await _controller?.dispose();
    d("ssssssssssssstrue");
    loadflag = true;
    reflash();
  }

  @override
  Widget build(BuildContext context) {
    if (!loadflag) {
      return Container(
        child: Text("cesss"),
      ); // 或者显示一个加载指示器
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller!),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: IconButton(
                    onPressed: () {
                      tkpic();
                    },
                    icon: Icon(Icons.camera),
                  ),
                ),
                Container(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
