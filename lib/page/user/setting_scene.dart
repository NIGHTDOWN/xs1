import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ng169/conf/conf.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/app.dart';
import 'package:ng169/style/sq_color.dart';
import 'package:ng169/tool/bow.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';
import 'package:ng169/tool/lang.dart';
import 'package:ng169/tool/notify.dart';
import 'package:ng169/tool/url.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

import 'me_cell.dart';
import 'me_cellss.dart';

class SettingScene extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingState();
}

class SettingState extends State<SettingScene> {
// class SettingScene extends StatelessWidget {
  var _cacheSizeStr = '0.00B';
  bool _value = false;
  String _version = '';
  @override
  void initState() {
    loadCache();
    _value = isnull(getcache(autounlock));

    reflash();
  }

  Future<Null> loadCache() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    _version = version;

    Directory tempDir = await getTemporaryDirectory();
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/
    // print('临时目录大小: ' + value.toString());

    // _cacheSizeStr用来存储大小的值
    _cacheSizeStr = _renderSize(value);
    reflash();
  }

  reflash() {
    setState(() {});
  }

  lock() {
    _value = false;
    setcache(autounlock, _value, '0');
    reflash();
  }

  unlock() {
    _value = true;
    setcache(autounlock, _value, '0');
    reflash();
  }

  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await _getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  _renderSize(double value) {
    if (null == value) {
      return 0;
    }
    List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  clearCache() async {
    Directory tempDir = await getTemporaryDirectory();
    //删除缓存目录
    await delDir(tempDir);
    await loadCache();
    show(context, lang('清除缓存成功'));
    // FlutterToast.showToast(msg: '清除缓存成功');
  }

  ///递归方式删除目录
  Future<Null> delDir(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await delDir(child);
      }
    }
    await file.delete();
  }

  @override
  Widget build(BuildContext context) {
    Switch s = Switch(
      value: _value,
      onChanged: (val) {
        if (!val) {
          lock();
        } else {
          unlock();
        }
      },
      activeColor: Colors.red,
      activeTrackColor: Colors.grey,
      inactiveThumbColor: Colors.black,
      inactiveTrackColor: Colors.grey,
    );
    List<Widget> children = [
      MeCell(
        title: lang('自动解锁章节'),
        onPressed: () {},
        line_padding_left: 10,
        right_widget: s,
      ),
      MeCell(
        title: lang('清除缓存'),
        onPressed: () {
          msgbox(context, clearCache, Text(lang('提示')),
              Text(lang('确定清空缓存') + '?'));
        },
        line_padding_left: 10,
        right_widget: Row(
          children: <Widget>[
            Text(_cacheSizeStr),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      MeCell(
        title: lang('选择语言'),
        onPressed: () {
          msgbox(context, () {}, Text(lang('选择语言')), getlnagobj());
        },
        line_padding_left: 10,
        right_widget: Row(
          children: <Widget>[
            // Text(_cacheSizeStr),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
      MeCellss(
        title: lang('检测更新'),
        onPressed: () {
          update();
        },
        line_padding_left: 10,
        havemsg: checkversionnum(),
        right_widget: Row(
          children: <Widget>[
            Text(_version),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: SQColor.gray,
            )
          ],
        ),
      ),
      MeCell(
        title: lang('隐私策略'),
        onPressed: () {
          gourl(
              context,
              Bow(
                url: serverurl + '/index/privacy/index',
              ));
        },
        line_padding_left: 10,
      ),
      MeCell(
        title: lang('版权声明'),
        onPressed: () {
          gourl(
              context,
              Bow(
                url: serverurl + '/index/privacy/copyright',
              ));
        },
        line_padding_left: 10,
      ),
      MeCell(
        title: lang('关于我们'),
        //iconName: 'assets/images/me_record.png',
        onPressed: () {
          //   Notify.setcontext(context);
          // setcache('install_upapk', '', '0');
          // Notify.showNotification(
          //     lang('更新提示'), lang('安装包已下载完成，点击安装'), 'install_upapk');
          gourl(
              context,
              Bow(
                url: serverurl + '/index/privacy/announcement',
              ));
          //通知
          // Notify.setcontext(context);
          // Notify.showNotification();
        },
        line_padding_left: 10,
      ),
      isnull(User.get())
          ? Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(20),
              height: 80,
              // decoration: BoxDecoration(
              //     border: Border.all(color: Color(0xff5f6fff), width: 1),
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular((5.0))),
              child: RaisedButton(
                color: Colors.red,
                child: new Text(lang('注销'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        wordSpacing: 10,
                        letterSpacing: 5)),
                onPressed: () {
                  User.clear();
                  reflash();
                  pop(context);
                },
                // splashColor: Colors.pink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10) //设置圆角
                    ),
              )
              // MaterialButton(
              //   color: Colors.red,
              //   textColor: Colors.white,
              //   child: new Text(lang('注销')),
              //   onPressed: () {
              //     User.clear();
              //     reflash();
              //     pop(context);
              //   },
              // )
              )
          : Container()
    ];
    return Scaffold(
      appBar: AppBar(
          title: Text(lang('设置')),
          elevation: 0.5,
          backgroundColor: SQColor.gray),
      body: Center(
        child: Container(
          child: ListView(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget getlnagobj() {
    List searchword = [
      {'en': "English"},
      {'th': "ไทย"},
      // {'zh': "简体中文"},
      {'vi': "Tiếng Việt"},
      {'id': "bahasa Indonesia"},
      {'ko': "한국어"}
    ];
    return Wrap(
      children: searchword.map((str) => serword(str)).toList(),
      spacing: 10,
    );
  }

  Widget serword(Map<String, String> str) {
    var keys = str.keys.toString();

    var key = keys.substring(1, 3);

    var val = str[key];

    var b = Container(
      constraints: BoxConstraints(
          // maxWidth: getScreenWidth(context) * .2,
          // maxHeight: 50,
          ),
      child: RaisedButton(
        // child: Text('圆角按钮'),
        // color: Colors.blue,
        textColor: Colors.white,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.grey,
        child: Text(val),
        // Chip(
        //   label: Text(val),
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // ),
        onPressed: () {
          setglang(key);
        },
      ),
    );
    return b;
  }

  setglang(String lang) async {
    if (lang == getlang()) {
      return;
    }
    await setlang(lang);
    pop(g('context'));
    gourl(context, App());
  }

  void update() {
    // http('common/add_version', {}, new Map<String, dynamic>.from(gethead()))
    //     .then((onValue) {
    //   var data = getdata(context, onValue);
    //   //获取版本信息
    //   // d(data['version_code']);
    //   // d(g('version'));
    //   setcache(appupinfo, data, '3600');
    //   alertupinfo(context, true);
    // });
    checkversion(context);
  }
}
