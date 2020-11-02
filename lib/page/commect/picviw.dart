import 'package:flutter/material.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/image.dart';

import 'package:photo_view/photo_view.dart';

class PicView extends StatelessWidget {
  final String url;
  var primaryColor = Color(0xff203152);
  PicView({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'FULL PHOTO',
      //     style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      //   ),
      //   centerTitle: true,
      // ),
      body: FullPhotoScreen(url: url),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
    hidetitlebar();
  }

  @override
  void dispose() {
    showtitlebar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      //   pop(context);
      // },
      child: Container(
          child: PhotoView(
              onTapDown:
                  (BuildContext, TapDownDetails, PhotoViewControllerValue) {
                pop(context);
              },
              // imageProvider: NetworkImage(url)
              imageProvider: CachedNetworkImageProvider(url)
              
              )),
    );
  }
}
