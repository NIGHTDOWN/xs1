import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ng169/style/screen.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/http.dart';

import 'function.dart';
import 'lang.dart';

// ignore: must_be_immutable
class CutImage extends StatefulWidget {
  CutImage(this.image);

  File image; //原始图片路径

  @override
  _CropImageRouteState createState() => new _CropImageRouteState();
}

class _CropImageRouteState extends State<CutImage> {
  late double baseLeft; //图片左上角的x坐标
  late double baseTop; //图片左上角的y坐标
  late double imageWidth; //图片宽度，缩放后会变化
  late double imageScale = 1; //图片缩放比例
  late Image imageView;

  late Uint8List? img = null;
  final _controller = CropController();
  // final cropKey = GlobalKey<CropState>();
  @override
  void initState() {
    super.initState();
    loadimng();
  }

  Future<Uint8List> _load(String assetName) async {
    final image = File(assetName);
    final assetData = await image.readAsBytes();
    // final assetData = await rootBundle.load(assetName);
    return assetData.buffer.asUint8List();
  }

  loadimng() async {
    img = await _load(widget.image.path);
    reflash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SQColor.white,
      body: Container(
        child: Stack(children: [
          SingleChildScrollView(
              child: Column(children: [
            SizedBox(
              height: kToolbarHeight + Screen.topSafeHeight,
            ),
            Container(
              width: Screen.width,
              height: Screen.height - kToolbarHeight - Screen.topSafeHeight,
              // child: Crop.file(
              //   widget.image,
              //   key: cropKey,
              //   aspectRatio: 1.0,
              //   //aspectRatio: 0.3 / 0.3,
              //   alwaysShowGrid: true,
              // ),
              child: img != null
                  ? Crop(
                      image: img!,
                      controller: _controller,
                      onCropped: (image) {
                        d(image);
                        _saveToTempFile(image);
                        close(widget.image);
                        // do something with cropped image data
                      })
                  : Container(),
            ),
          ])),
          buildNavigationBar(),
        ]),
      ),
    );
  }

  Future<String> _saveToTempFile(_imageByteData) async {
    // final Directory tempDir = await getTemporaryDirectory();
    // final Directory tempDir = "../";
    // final String tempImagePath = '${tempDir.path}/temp_image.png';
    // final File tempFile = File(tempImagePath);

    // 将Uint8List数据写入到临时文件
    await widget.image.writeAsBytes(_imageByteData);

    return widget.image.path;
  }

  close([data]) {
    Navigator.pop(context, data);
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: SQColor.white,
            boxShadow: const [
              BoxShadow(color: Color(0xdddddddd), offset: Offset(1.0, 1.0)),
            ],
          ),
          padding: EdgeInsets.fromLTRB(0, Screen.topSafeHeight, 0, 0),
          height: Screen.navigationBarHeight,
          //color: SQColor.white,
          child: Row(
            children: <Widget>[
              //SizedBox(width: 103),
              GestureDetector(
                onTap: close,
                // ignore: sized_box_for_whitespace
                child: Container(
                    height: kToolbarHeight,
                    width: 44,
                    child: Icon(
                      Icons.arrow_back,
                      color: SQColor.darkGray,
                    )),
              ),

              Expanded(
                  child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: SQColor.darkGray),
                  textAlign: TextAlign.left,
                ),
              )),
              SizedBox(
                child: GestureDetector(
                  child: SizedBox(
                      // width: 80,
                      // height: 40,
                      child: Text(
                    lang('选取'),
                    style: TextStyle(
                      color: SQColor.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  )),
                  onTap: () {
                    // _crop(widget.image);
                    _controller.crop();
                  },
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _crop(File originalFile) async {
    // final crop = cropKey.currentState;
    // final scale = crop.scale;
    // final area = crop?.area;

    // if (area == null) {
    //   //裁剪结果为空
    //   d('裁剪不成功');
    // }
    // final permissionsGranted = await ImageCrop.requestPermissions();

    // if (permissionsGranted) {
    //   final croppedFile = await ImageCrop.cropImage(
    //     file: originalFile,
    //     area: crop!.area!,
    //     scale: 0.1,
    //   );

    //   close(croppedFile);
    // } else {
    //   close(originalFile);
    // }

    // await ImageCrop.requestPermissions().then((value) {
    //   if (value) {
    //     d(value);
    //     ImageCrop.cropImage(
    //       file: originalFile,
    //       area: crop.area,
    //     ).then((value) {
    //       pop(context, value);
    //       // upload(value);
    //     }).catchError(() {
    //       d('裁剪不成功');
    //     });
    //   } else {
    //     upload(originalFile);
    //   }
    // });
  }

  ///上传头像
  void upload(File file) {
    d(file);
    // httpfile(url);
    // print(file.path);
    // Dio dio = Dio();
    // dio
    //     .post("http://your ip:port/", data: FormData.from({'file': file}))
    //     .then((response) {
    //   if (!mounted) {
    //     return;
    //   }
    //   //处理上传结果
    //   UploadIconResult bean = UploadIconResult(response.data);
    //   print('上传头像结果 $bean');
    //   if (bean.code == '1') {
    //     Navigator.pop(context, bean.data.url); //这里的url在上一页调用的result可以拿到
    //   } else {
    //     Navigator.pop(context, '');
    //   }
    // });
  }
}
