import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'dart:async';
import 'package:ng169/obj/chapter.dart';
import 'package:ng169/obj/novel.dart';

import 'package:ng169/style/styles.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSet extends StatefulWidget {
  final List<dynamic> chapters;
  final int articleIndex;
  final Novel novel;
  final VoidCallback onTap;
  final VoidCallback reflash;
  final VoidCallback reload;

  ReaderSet(
      {this.chapters,
      this.articleIndex,
      this.onTap,
      this.novel,
      this.reflash,
      this.reload});

  @override
  ReaderSetState createState() => ReaderSetState();
}

class ReaderSetState extends State<ReaderSet>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  double progressValue = 0.0;
  bool isTipVisible = false;

  // double brightness; //A??
  String title;
  //?????
  @override
  initState() {
    super.initState();

    // progressValue =
    //     this.widget.articleIndex / (this.widget.chapters.length - 1);
    getUserBrightnessConfig();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(animationController);

    animation.addListener(() {
      reflash();
    });
    animationController.forward();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  //????
  hide() {
    animationController.reverse();
    Timer(Duration(milliseconds: 200), () {
      this.widget.onTap();
    });
    setState(() {
      isTipVisible = false;
    });
  }

  //???
  buildTopView(BuildContext context) {
    return Positioned(
      bottom: -getScreenHeight(context) * .5 * (animation.value),
      left: 0,
      right: 0,
      child: Container(
          padding: EdgeInsets.only(
              left: getScreenWidth(context) * .06,
              right: getScreenWidth(context) * .06),
          decoration: BoxDecoration(
              color: Styles.getTheme()['barcolor'],
              boxShadow: Styles.bordercateShadow),
          width: getScreenWidth(context),
          child: Column(
            children: <Widget>[
              //??
              buildProgressView(),
              //??
              buildsizeView(),
              //??
              //??
              buildbgView(),
              //????
              buildpageView(),
            ],
          )),
    );
  }

  buildProgressView() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: setUserBrightnessjian,
            child: Container(
              // padding: EdgeInsets.all(20),
              child: Icon(
                Icons.brightness_low,
                color: Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: progressValue,
              onChanged: (double value) {
                setUserBrightnessConfig(value);
                setState(() {
                  isTipVisible = true;
                });
              },
              onChangeEnd: (double value) {
                setUserBrightnessConfig(value);
                setState(() {
                  isTipVisible = true;
                });
              },
              activeColor: Styles.getTheme()['activecolor'],
              inactiveColor: Styles.getTheme()['barfontcolor'],
            ),
          ),
          GestureDetector(
            onTap: setUserBrightnessadd,
            child: Container(
              // padding: EdgeInsets.all(20),
              child: Icon(
                Icons.brightness_high,
                // 'assets/images/read_icon_chapter_next.png',
                color: Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: setUserBrightnessauto,
            child: Container(
              // padding: EdgeInsets.all(20),
              child: Icon(
                Icons.brightness_auto,
                // 'assets/images/read_icon_chapter_next.png',
                color: isnull(getcache(autolight))
                    ? Styles.getTheme()['activecolor']
                    : Styles.getTheme()['barfontcolor'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  changesize(double newsize) {
    if (newsize > 30) {
      newsize = 30;
    }
    if (newsize < 10) {
      newsize = 10;
    }
    setcache(fontsizecache, newsize, '-1');
    widget.reflash();
    reflash();
  }

  Future<double> getUserBrightnessConfig() async {
    progressValue = await Screen.brightness;
    return progressValue;
  }

  void setUserBrightnessConfig(double data) async {
    Screen.setBrightness(data);
    progressValue = data;
    setcache(autolight, 0, '-1');
    reflash();
  }

  void setUserBrightnessadd() async {
    progressValue = progressValue + 0.05;
    if (progressValue > 1) {
      progressValue = 1.0;
    }
    setcache(autolight, 0, '-1');
    Screen.setBrightness(progressValue);
    reflash();
  }

  void setUserBrightnessauto() async {
    if (!isnull(getcache(autolight))) {
      setcache(autolight, 1, '-1');
      Screen.setBrightness(-1.0);
    } else {
      setcache(autolight, 0, '-1');
      Screen.setBrightness(progressValue);
    }

    reflash();
  }

  void setUserBrightnessjian() async {
    progressValue = progressValue - 0.05;
    if (progressValue <= 0) {
      progressValue = 0.0;
    }
    setcache(autolight, 0, '-1');
    Screen.setBrightness(progressValue);

    reflash();
  }

  buildsizeView() {
    double size = Styles.getTheme()['fontsize'];
    return Container(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              onPressed: () {
                size--;
                changesize(size);
              },
              child: Text(
                "A-",
                style: TextStyle(fontSize: 15),
              ),
              color: Styles.getTheme()['activecolor'],
              textColor: Styles.getTheme()['activefontcolor'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                size.toStringAsFixed(0),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Styles.getTheme()['barfontcolor']),
              ),
            ),
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                size++;
                changesize(size);
              },
              child: Text(
                "A+",
                style: TextStyle(fontSize: 21),
              ),
              color: Styles.getTheme()['activecolor'],
              textColor: Styles.getTheme()['activefontcolor'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  buildbgView() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th1', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th1.png'),
              )),
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th2', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th2.jpg'),
              )),
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th3', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th3.jpg'),
              )),
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th4', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th4.jpg'),
              )),
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th5', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th5.jpg'),
              )),
          GestureDetector(
              onTap: () {
                setcache(themecache, 'th6', '-1');
                widget.reflash();
                reflash();
              },
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/th6.jpg'),
              )),
        ],
      ),
    );
  }

  reflash() {
    if (mounted) {
      setState(() {});
    }
  }

  buildpageView() {
    var fx = isnull(getcache(readfx)) ? getcache(readfx).toString() : '1';

    return Container(
      padding: EdgeInsets.fromLTRB(2, 0, 2, 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              onPressed: () {
                if (fx == '1') {
                  return;
                }
                setcache(readfx, '1', '-1');
                widget.reload();
                // readfx
              },
              child: Text(lang('左右翻页')),
              color: fx == '1'
                  ? Styles.getTheme()['cateon']
                  : Styles.getTheme()['activecolor'],
              textColor: Styles.getTheme()['activefontcolor'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(
            width: 6,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () {
                if (fx == '2') {
                  return;
                }
                setcache(readfx, '2', '-1');
                widget.reload();
              },
              child: Text(lang('上下翻页')),
              color: fx == '2'
                  ? Styles.getTheme()['cateon']
                  : Styles.getTheme()['activecolor'],
              textColor: Styles.getTheme()['activefontcolor'],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  click(Chapter chapter) {
    hide();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTapDown: (_) {
              hide();
            },
            child: Container(color: Colors.transparent),
          ),
          buildTopView(context),
        ],
      ),
    );
  }
}