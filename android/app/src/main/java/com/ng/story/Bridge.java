package com.ng.story;

import android.annotation.TargetApi;
import android.os.Build;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import java.io.IOException;

import android.os.Build.VERSION_CODES;



import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsResponseListener;


import java.util.Locale;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.android.play.core.tasks.OnCompleteListener;
import com.google.android.play.core.tasks.OnFailureListener;
import com.google.android.play.core.tasks.Task;

import androidx.annotation.NonNull;



public class Bridge {
    public static final String CHANNEL = "com.ng.story/adbridge";
    static Bridge _self;

    public static MethodChannel channels;

    // 所有java调用flutter出口
    public static void call(final String functions, final Object params) {
        channels.invokeMethod(functions, params);
    }

    public static void success(final Object params) {
        // d((new Throwable()).getStackTrace());
        call("success", params);
    }

    public static void fail(final Object params) {
        call("fail", params);
    }

    public static void cancel(final Object params) {
        call("cancel", params);

    }

    public static void d(final Object string) {
        System.out.println("java日志输出" + "=====" + string);
    }

    public static Bridge getInstance() {
        if (_self == null) {
            synchronized (Bridge.class) {
                if (_self == null) {
                    _self = new Bridge();
                }
            }
        }
        return _self;
    }

    // 初始化入口，所有flutter入口在此
    public static void init(final MethodCall call, final Result result)  {
        final String method = call.method;

        if (call.method.equals("googlepay/initpays")) {
            // 谷歌支付初始化
            com.ng.story.GooglePay.initpay();
            result.success("ret");

        } else if (call.method.equals("googlepay/startgoogleBuy")) {
            // 调用谷歌支付
            final String sku = call.argument("sku");
            final String payload = call.argument("payload");
            GooglePay.startgoogleBuy(sku, payload);
            result.success(sku);
        } else if (call.method.equals("googlopj")) {
            // 回倒桌面
            //评论弹不出来
            final ReviewManager manager = ReviewManagerFactory.create(MainActivity._context);

            final Task<ReviewInfo> request = manager.requestReviewFlow();

            request.addOnCompleteListener(new OnCompleteListener<ReviewInfo>() {
                @Override
                public void onComplete(@NonNull Task<ReviewInfo> task) {
                    d(task.isSuccessful());
                    if (task.isSuccessful()) {
                        // We can get the ReviewInfo object
                        ReviewInfo reviewInfo;
                        reviewInfo = task.getResult();
                        d(reviewInfo);
                        d("第二步");
                        Task<Void> flow = manager.launchReviewFlow(MainActivity._Activity, reviewInfo);

                        flow.addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> task) {
                                d("第三步");
                                d(task);
                                //   result.success(null);
                            }
                        });
                        //   result.success(true);
                    } else {
                        // The API isn't available
                        d(" 这里In-App Review API unavailable");
                        //   result.success(false);

                    }
                }
            });

        } else if (call.method.equals("backDesktop")) {
            //这里是调试
            // d("点击加入1");
            // try {
            //     Bridge.decryptFile();
            // } catch (Exception e) {
            //     e.printStackTrace();
            // }


            // d("点击加入2");
            // 回倒桌面
            result.success(true);
            FlutterActivity obj = MainActivity._Activity;
            obj.moveTaskToBack(false);
            // moveTaskToBack(false);
        } 
        else if (call.method.equals("getlang")) {
            result.success(Bridge.getlang());
        }
        
        else {
            result.notImplemented();
        }
    }

    public static String getlang() {
        String language = Locale.getDefault().getLanguage();
        return language;

    }
  
}
