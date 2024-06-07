package com.ng.lovenovel;

import android.annotation.TargetApi;
import android.os.Build;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

import java.io.IOException;

import android.os.Build.VERSION_CODES;



// import com.android.billingclient.api.BillingClient;
// import com.android.billingclient.api.BillingResult;
// import com.android.billingclient.api.Purchase;
// import com.android.billingclient.api.SkuDetails;
// import com.android.billingclient.api.SkuDetailsResponseListener;


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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Formatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;
import java.util.StringTokenizer;

public class Bridge {
    public static final String CHANNEL = "com.ng.lovenovel/adbridge";
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
    public static void init(final MethodCall call, final Result result) {
        final String method = call.method;

        if (call.method.equals("googlepay/initpays")) {
            // 谷歌支付初始化
            // com.ng.lovenovel.GooglePay.initpay();
            // result.success("ret");

        } else if (call.method.equals("googlepay/startgoogleBuy")) {
            // 调用谷歌支付
            // final String sku = call.argument("sku");
            // final String payload = call.argument("payload");
            // GooglePay.startgoogleBuy(sku, payload);
            // result.success(sku);
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
        } else if (call.method.equals("getlang")) {
            result.success(Bridge.getlang());
        } else if (call.method.equals("getnet")) {
            result.success(Bridge.getnet()) ;
        } else {
            result.notImplemented();
        }
    }

    public static String getlang() {
        String language = Locale.getDefault().getLanguage();
        return language;

    }

    private static final int SLEEP_TIME = 2 * 1000;

    //获取网络上行下行速度
    public static Map<String, String> getNetworkDownUp() {
        Properties props = System.getProperties();
        String os = props.getProperty("os.name").toLowerCase();
        os = os.startsWith("win") ? "windows" : "linux";
        Map<String, String> result = new HashMap<>();
        Process pro = null;
        Runtime r = Runtime.getRuntime();
        BufferedReader input = null;
        String rxPercent = "";
        String txPercent = "";
        try {
            String command = "windows".equals(os) ? "netstat -e" : "ifconfig";
            pro = r.exec(command);
            input = new BufferedReader(new InputStreamReader(pro.getInputStream()));
            long result1[] = readInLine(input, os);
            Thread.sleep(SLEEP_TIME);
            pro.destroy();
            input.close();
            pro = r.exec(command);
            input = new BufferedReader(new InputStreamReader(pro.getInputStream()));
            long result2[] = readInLine(input, os);
            rxPercent = formatNumber((result2[0] - result1[0]) / (1024.0 * (SLEEP_TIME / 1000))); // 上行速率(kB/s)
            txPercent = formatNumber((result2[1] - result1[1]) / (1024.0 * (SLEEP_TIME / 1000))); // 下行速率(kB/s)
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            Optional.ofNullable(pro).ifPresent(p -> p.destroy());
        }
        result.put("rxPercent", rxPercent);// 下行速率
        result.put("txPercent", txPercent);// 上行速率
        return result;

    }

    private static long[] readInLine(BufferedReader input, String osType) {
        long arr[] = new long[2];
        StringTokenizer tokenStat = null;
        try {
            if (osType.equals("linux")) { // 获取linux环境下的网口上下行速率
                long rx = 0, tx = 0;
                String line = null;
                //RX packets:4171603 errors:0 dropped:0 overruns:0 frame:0
                //TX packets:4171603 errors:0 dropped:0 overruns:0 carrier:0
                while ((line = input.readLine()) != null) {
                    if (line.indexOf("RX packets") >= 0) {
                        rx += Long.parseLong(line.substring(line.indexOf("RX packets") + 11, line.indexOf(" ", line.indexOf("RX packets") + 11)));
                    } else if (line.indexOf("TX packets") >= 0) {
                        tx += Long.parseLong(line.substring(line.indexOf("TX packets") + 11, line.indexOf(" ", line.indexOf("TX packets") + 11)));
                    }
                }
                arr[0] = rx;
                arr[1] = tx;
            } else { // 获取windows环境下的网口上下行速率
                input.readLine();
                input.readLine();
                input.readLine();
                input.readLine();
                tokenStat = new StringTokenizer(input.readLine());
                tokenStat.nextToken();
                arr[0] = Long.parseLong(tokenStat.nextToken());
                arr[1] = Long.parseLong(tokenStat.nextToken());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return arr;
    }

    private static String formatNumber(double f) {
        return new Formatter().format("%.2f", f).toString();
    }

    public static String getnet() {
        Map<String, String> result = getNetworkDownUp();
        d(result.get("rxPercent"));
        d(result.get("txPercent"));
        String ret="下载"+result.get("rxPercent")+"mb|上传"+result.get("txPercent")+"mb";
        return ret;

    }
}