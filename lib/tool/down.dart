import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:install_apk_plugin/install_apk_plugin.dart';
import 'package:ng169/conf/conf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'function.dart';
import 'global.dart';
import 'lang.dart';
import 'notify.dart';
class Down {
  static StateSetter reflash; //进度条刷新入口
  static var progress = 0.0;
  static Future<bool> checkpath(String path) async {
    var directory = await new Directory(path).create(recursive: true);

    return await directory.exists();
  }

  static getfile(String urlPath,
      [String savePath, Function success, Function fail, Function load]) async {
    if (!isnull(savePath)) {
      savePath = await Down.getFilePath(urlPath);
    }

    String cachename = 'apk' + urlPath.hashCode.toString();
    var tmp = getcache(cachename);

    if (isnull(tmp)) {
      success.call(tmp);
      return tmp;
    }
    Response response;
    Dio dio = Dio();
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        if (isnull(load)) {
          load.call(count, total);
        }
        //print("$count $total");
      });
      if (isnull(success)) {
        success.call(savePath);
        setcache(cachename, savePath, '-1');
      } else {
        d('downloadFile success---------${response.data}');
      }
    } on DioError catch (e) {
      if (isnull(fail)) {
        fail.call(e);
      } else {
        d('downloadFile error---------$e');
      }
    }
    //return response.data;
  }

  static Future<dynamic> open(String apkrealpath) async {
    // d(apkrealpath);
    // Map<PermissionGroup, PermissionStatus> permissions =
    //     await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    // if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
    //   apkrealpath = 'app_flutter/install5.2.0.apk';
    //   InstallPlugin.installApk(apkrealpath, 'com.ng.story').then((result) {
    //     d('install apk $result');
    //   }).catchError((error) {c
    //     d('install apk error: $error');
    //   });
    // } else {
    //   d('Permission request fail!');
    // }

    // return InstallPlugin.installApk(apkrealpath, 'com.ng.story');
    //release环境报错需要在 AndroidManifest 加入
    // <provider
    //             android:name="androidx.core.content.FileProvider"
    //             android:authorities="${applicationId}.fileProvider"
    //             android:exported="false"
    //             android:grantUriPermissions="true"
    //             tools:replace="android:authorities">
    //         <meta-data
    //                 android:name="android.support.FILE_PROVIDER_PATHS"
    //                 android:resource="@xml/filepaths"
    //                 tools:replace="android:resource" />
    //     </provider>

    return await OpenFile.open(apkrealpath);
  }

  static Future<bool> isexits(String path) async {
    var file = File(path);
    bool exist = await file.exists();
    return exist;
  }

  static Future<String> getFilePath(String filename) async {
    // 获取文档目录的路径
    String dir;
    if (isnull(getcache(downdocment))) {
      dir = getcache(downdocment);
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      // Directory appDocDir = await getTemporaryDirectory();
      dir = appDocDir.path;
      // d(dir);
      setcache(downdocment, dir, '0');
    }
    var tmpname = filename.split('/');
    var name = tmpname[tmpname.length - 1];
    var file = '$dir/$name';
    return file;
  }

  static autodown(BuildContext context, String upurl) {
    if (!isnull(upurl)) {
      show(context, lang('获取升级包错误'));
      return false;
    }
    //Down.loadbox(context);
    //return false;
    //d(1);
    Down.getfile(upurl, null, (file) {
      // pop(context);
      Notify.setcontext(context);
      setcache('install_upapk', file, '0');
      Notify.showNotification(
          lang('更新提示'), lang('安装包已下载完成，点击安装'), 'install_upapk');
    }, (e) {
      //pop(context);
      show(context, lang('下载失败'));
    }, (count, total) {
      //d(Down.reflash);
      // Down.progress = count / total;
      // Down.reflash(() {});
      //msgbox(context, () {});
    });
  }

  static downandinstall(BuildContext context, String upurl) {
    if (!isnull(upurl)) {
      show(context, lang('获取升级包错误'));
      return false;
    }
    Down.loadbox(context);
    //return false;
    //d(1);
    Down.getfile(upurl, null, (file) {
      pop(context);
      // d('1111');
      // d(getcache(appstatus));
      // d(g('gstat'));

      if (g('gstat') != AppLifecycleState.paused) {
        Down.open(file);
      } else {
        Notify.setcontext(context);
        setcache('install_upapk', file, '0');
        Notify.showNotification(
            lang('更新提示'), lang('安装包已下载完成，点击安装'), 'install_upapk');
      }
    }, (e) {
      //pop(context);
      show(context, lang('下载失败'));
    }, (count, total) {
      //d(Down.reflash);
      Down.progress = count / total;
      Down.reflash(() {});
      //msgbox(context, () {});
    });
  }

  static Future loadbox(BuildContext context, [Widget body]) async {
    var boxw = getScreenWidth(context);
    var boxh = getScreenHeight(context);
    var boxsize = boxw > boxh ? boxh : boxw;
    boxsize /= 2.5;
    var fontstyle = new TextStyle(
        color: Colors.white,
        fontSize: 15.0,
        fontWeight: FontWeight.w100,
        letterSpacing: 0,
        height: 1,
        wordSpacing: 0,
        //fontStyle: FontStyle.italic,
        //textBaseline: TextBaseline.ideographic,
        decoration: TextDecoration.none);
    var body = StatefulBuilder(
      builder: (ctx, state) {
        Down.reflash = state;
        var point = Down.progress * 100;
        var theam = Container(
          height: boxsize,
          width: boxsize,
          decoration: new BoxDecoration(
            //背景
            color: Colors.blue,
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            //设置四周边框
            //border: new Border.all(width: 1, color: Colors.red),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: boxsize / 5,
                    ),
                    CircularProgressIndicator(
                      //strokeWidth: 4.0,
                      backgroundColor: Colors.blue,
                      value: Down.progress,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox()
                  ],
                ),
              ),
              Expanded(
                  child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: boxsize / 8,
                    ),
                    Container(
                      //margin: const EdgeInsets.all(5.0),
                      //padding: const EdgeInsets.all(5.0),
                      child: Text(
                        lang('Loading') + '...',
                        style: fontstyle,
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(1.0),
                        child: Text(
                          lang('done') + ' ' + point.toStringAsFixed(1) + '%',
                          style: fontstyle,
                        ))
                  ],
                ),
              )),
            ],
          ),
        );
        return WillPopScope(
            child: Center(child: theam),
            onWillPop: () {
              var serverinfo = getcache(appupinfo);
              if (isnull(serverinfo, 'types')) {
                if (toint(serverinfo['types']) != 2) {
                  pop(g('context'));
                }
              }
            });
      },
    );
    final action = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => body,
    );
    return await action;
  }
}