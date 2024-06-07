package com.ng.lovenovel;

import io.flutter.embedding.android.FlutterActivity;
import android.content.Context;
import android.os.Bundle;
import io.flutter.embedding.engine.FlutterEngine;

import io.flutter.plugin.common.MethodCall;

import io.flutter.plugin.common.MethodChannel;

import io.flutter.plugins.GeneratedPluginRegistrant;


import java.lang.reflect.ParameterizedType;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.util.Log;

public class MainActivity extends FlutterActivity {

  public static FlutterActivity _Activity;
  public static Context _context;
  public void configureFlutterEngine(FlutterEngine flutterEngine){
    MainActivity._Activity = MainActivity.this;
    MainActivity._context = getApplicationContext();
    GeneratedPluginRegistrant.registerWith(flutterEngine);
      Bridge.channels = new MethodChannel(flutterEngine.getDartExecutor(), Bridge.CHANNEL);
      Bridge.channels.setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
//                if (call.method.equals("getLocationAddress")) {
//                  //do something
//                } else {
//                  //没有对应方法
//                  result.notImplemented();
//                }
                Bridge.init(call, result);
              }

            }

    );

  }

  // private static PluginRegistry.Registrar registrar;
//  @Override
//  protected void onCreate(Bundle savedInstanceState) {
//    super.onCreate(savedInstanceState);
//    MainActivity._Activity = MainActivity.this;
//    MainActivity._context = getApplicationContext();
//
//    GeneratedPluginRegistrant.registerWith(this);
//    // 注册类，函数
//    Bridge.channels = new MethodChannel(getFlutterView(), Bridge.CHANNEL);
//    Bridge.channels.setMethodCallHandler(
//
//        new MethodCallHandler() {
//          public void onMethodCall(MethodCall call, Result result) {
//
//            Bridge.init(call, result);
//          }
//        });
//
//  }

}
