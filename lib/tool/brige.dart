import 'package:flutter/material.dart';

//父子通信桥
class NgBrige extends InheritedWidget{
  final dynamic  data;
  final dynamic  fun;

  // final dynamic funs;
  @override
  bool updateShouldNotify(NgBrige oldWidget) {
    
     return  oldWidget.data != data;
  }
   NgBrige({
    @required this.data,//接收参数泛型
    @required this.fun,//接收方法泛型
    // @required this.funs,//接收方法泛型
    Widget child
  }) :super(child: child);

  static of(BuildContext context) {
     return context.inheritFromWidgetOfExactType(NgBrige);
  }
// static ShareDataWidget of(BuildContext context) {
   
//   }
  // static of(BuildContext context) {
  //   return super.of(BuildContext context);
  // }

}