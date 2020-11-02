package com.ng.story;

import android.content.Context;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

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

  // private static PluginRegistry.Registrar registrar;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    MainActivity._Activity = MainActivity.this;
    MainActivity._context = getApplicationContext();
    
    GeneratedPluginRegistrant.registerWith(this);
    // 注册类，函数
    Bridge.channels = new MethodChannel(getFlutterView(), Bridge.CHANNEL);
    Bridge.channels.setMethodCallHandler(

        new MethodCallHandler() {
          public void onMethodCall(MethodCall call, Result result) {
            
            Bridge.init(call, result);
          }
        });

  }

}
