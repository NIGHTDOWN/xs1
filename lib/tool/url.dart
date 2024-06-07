import 'package:flutter/material.dart';
import 'package:ng169/model/base.dart';
import 'package:ng169/model/user.dart';
import 'package:ng169/page/login/index.dart';
import 'package:ng169/page/recharge/recharge.dart';
import 'package:ng169/tool/function.dart';

/*
context 为上下文
classObject 为页面实列对象
 */
List loginobject = [Recharge()];
Future gourl(BuildContext context, Object classObject) async {
  if (!mustlogin(classObject)) {
    return await Navigator.push(
        context, new MaterialPageRoute(builder: (context) => Index()));
  }
  final widget = classObject is Widget ? classObject : Container();
  return await Navigator.push(
      context, new MaterialPageRoute(builder: (context) => widget));
}

// Future gourl(BuildContext context, WidgetBuilder builder) async {
//   if (!mustlogin(context)) {
//     return await Navigator.push(
//         context, MaterialPageRoute(builder: (context) => Index()));
//   }
//   return await Navigator.push(context, MaterialPageRoute(builder: builder));
// }
bool mustlogin(classObject) {
  if (User.islogin()) {
    return true;
  }

  if (classObject is LoginBase) {
    if (classObject.needlogin) {
      return false;
    }
    return true;
  }
  return true;
  // d(loginobject);
  // d(loginobject.indexOf(classObject));
  // if (loginobject.indexOf(classObject) == -1) {
  //   return true;
  // }
  // return false;
}

/*
context 为上下文
classObject 为页面实列对象
带动画的页面切换
 */
void gourl_animation(context, Object? classObject, [int? type, int? time]) {
  var tween;
  switch (type) {
    case 1:
      //right
      tween = Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
      break;
    case 2:
      //left
      tween = Tween(begin: Offset(-1.0, 0.0), end: Offset.zero);
      break;
    case 3:
      //bottom
      tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
      break;
    case 4:
      //top
      tween = Tween(begin: Offset(0.0, -1.0), end: Offset.zero);
      break;

    default:
      //默认右侧划入 0.5秒
      tween = Tween(begin: Offset(1.0, 0.0), end: Offset.zero);
  }
  // 确保 classObject 是一个 Widget
  final widget = classObject is Widget ? classObject : Container();
  Navigator.push(
      context,
      new PageRouteBuilder(
          pageBuilder: (context, _, __) {
            return widget;
          },
          transitionsBuilder:
              (context, Animation<double> animation, _, Widget child) {
            //旋转效果
            // return FadeTransition(
            //     opacity: animation,
            //     child: new RotationTransition(
            //       turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            //       child: child,
            //     ));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: time ?? 500)));
}

formar_url(String url) {
  RegExp reg = new RegExp(r'^lovenovel://com\.ng\.lovenovel/(.+)\?(.+)');
  RegExp regdata = new RegExp(r'(([a-zA-Z0-9-_]+)\=([a-zA-Z0-9-_]+))&?');

  String? action, params;
  var param = {};

  if (reg.hasMatch(url)) {
    Iterable<Match> matches = reg.allMatches(url);

    for (Match m in matches) {
      action = m.group(1)!;
      params = m.group(2)!;
      if (isnull(params)) {
        if (regdata.hasMatch(params)) {
          Iterable<Match> matchess = regdata.allMatches(params);
          for (Match m2 in matchess) {
            // d(m2.group(0));
            // d(m2.group(1));
            // d(m2.group(2));
            if (isnull(m2.group(2))) {
              param.addAll({m2.group(2): m2.group(3)});
            }
          }
        }
      }
    }
    return {'action': action, 'data': param};
  }
}
