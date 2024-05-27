// package com.ng.story;

// import android.os.Bundle;
// import io.flutter.app.FlutterActivity;
// import io.flutter.plugins.GeneratedPluginRegistrant;
// import io.flutter.plugin.common.MethodCall;
// import io.flutter.plugin.common.MethodChannel;
// import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
// import io.flutter.plugin.common.MethodChannel.Result;

// import java.lang.reflect.ParameterizedType;

// import android.content.ContextWrapper;
// import android.content.Intent;
// import android.content.IntentFilter;
// import android.os.BatteryManager;
// import android.os.Build.VERSION;
// import android.os.Build.VERSION_CODES;
// import android.util.Log;
// import com.alibaba.fastjson.JSON;
// import com.alibaba.fastjson.JSONArray;
// import com.alibaba.fastjson.JSONObject;

// // import com.google.gson.Gson;
// // import com.google.gson.reflect.TypeToken;

// import android.app.Activity;
// import android.os.Bundle;
// import android.util.Log;
// import android.view.View;

// import com.android.billingclient.api.BillingClient;
// import com.android.billingclient.api.BillingResult;
// import com.android.billingclient.api.Purchase;
// import com.android.billingclient.api.ProductDetails;
// import com.android.billingclient.api.ProductDetailsResponseListener;
// import org.json.JSONException;
// import java.util.ArrayList;
// import java.util.List;
// import java.util.Map;
// import java.util.HashMap;
// import com.android.billingclient.api.ConsumeParams;

// public class GooglePay {

//     static boolean isConnect = false;
//     static long calltime = 0;
//     // static List backdata=new List<E>() {
//     // };
//     static HashMap backdata = new HashMap();

//     // 防止重复点击
//     private static boolean noDuplication() {
//         long nowtime = (System.currentTimeMillis()) / 1000;
//         // backdata = new ArrayList<>();
//         backdata.clear();
//         // 3秒内只能点一次
//         if (nowtime - calltime > 3) {
//             calltime = nowtime;
//             return true;
//         } else {
//             return false;
//         }

//     }

//     // 初始化支付
//     public static void initpay() {

//         // 这里设置时间，避免一次执行多次
//         // System.currentTimeMillis()
//         BillingUtil.getInstance().clientConnection(MainActivity._Activity, new BillingUtil.BillingUpdatesListener() {
//             @Override
//             public void onBillingClientSetupFinished() {
//                 Bridge.call("success", "google连接成功");
//                 isConnect = true;
//                 Bridge.success(isConnect);
//             }

//             @Override
//             public void onBillingClientSetupFinishedFailed() {
//                 // Bridge.d("google连接失败");
//                 Bridge.call("fail", "google连接失败");
//                 isConnect = false;
//             }

//             @Override
//             public void onConsumeFinished(String token, int result) {
//                 if (result == BillingClient.BillingResponseCode.OK) {
//                     // Bridge.d(token);
//                     Bridge.d("消费成功，开始dart回调");
//                     adddate("consumetoken", token);
//                     Bridge.success(get());
//                 } else {
//                     Bridge.d("消费失败，状态码为：" + result);
//                     Bridge.call("fail", "消费失败，状态码为：" + result);
//                 }
//             }

//             @Override
//             public void onPurchasesUpdated(List<Purchase> purchases) {
//                 Bridge.d(purchases);
//                 // 列：
//                 // [Purchase. Json:
//                 // {"orderId":"GPA.3353-9204-0619-27843","packageName":"com.ng.story","productId":"payidls_1","purchaseTime":1577973397212,"purchaseState":0,"purchaseToken":"jfigenpboipdgmebgbkjkbhe.AO-J1OyOIh0PeyYAVvNJ3kIw_QqCRTtIDG0subYQ5jNq8ZUKkZG5KVebNzA_5ooI5kvlldWCG3psm94CegODBkKh8cQLtA33fJpl4GLM5S6IiZIaTcDuV0g","acknowledged":false}]

//                 if (purchases != null && purchases.size() > 0) {
//                     Bridge.d("用户拥有商品，开始消费。");
//                     for (Purchase purchase : purchases) {
//                         // 商品id(purchase.getSku());
//                         // token(purchase.getPurchaseToken());
//                         // 谷歌订单号(purchase.getOrderId());
//                         String ssku = getdate("fluttersku");
//                         String issku = getdate("sku");
//                         String rsku = purchase.getSku();

//                         if (ssku.equals(rsku) && (issku == null || "".equals(issku) || "null".equals(issku))) {
//                             // 为空的时候压入hashmap
//                             GooglePay.adddate("sku", purchase.getSku());
//                             GooglePay.adddate("token", purchase.getPurchaseToken());
//                             GooglePay.adddate("orderid", purchase.getOrderId());
//                             GooglePay.adddate("packagename", purchase.getPackageName());
//                             GooglePay.adddate("purchasestate", "" + purchase.getPurchaseState());
//                             GooglePay.adddate("purchasetime", "" + purchase.getPurchaseTime());
//                         } else {
//                             // 多余的压入更多里面
//                             String tmps = getdate("more_purchases");
//                             if (tmps == null || "".equals(tmps) || "null".equals(tmps)) {
//                                 GooglePay.adddate("more_purchases", purchase.toString());
//                             } else {
//                                 GooglePay.adddate("more_purchases",
//                                         getdate("more_purchases") + "|" + purchase.toString());
//                             }

//                         }
//                         ConsumeParams consumeParams;
//                         String payload = getdate("flutterpayload");
                       
                        
//                         if (payload != "") {
//                             Bridge.d("加载payload"+payload);
//                             consumeParams = ConsumeParams.newBuilder().setPurchaseToken(purchase.getPurchaseToken())
//                              .build();
//                                     // .setDeveloperPayload(payload)
                                   
//                         } else {
//                             consumeParams = ConsumeParams.newBuilder().setPurchaseToken(purchase.getPurchaseToken())
//                                     .build();
//                         }

//                         BillingUtil.getInstance().consumeAsync(consumeParams);
//                         // 这里是vip
                       

//                     }
//                 } else {
//                     Bridge.d("用户无已购买商品。");
//                 }
//             }

//             @Override
//             public void onPurchasesCancelled(int responseCode) {

//                 if (responseCode == BillingClient.BillingResponseCode.USER_CANCELED) {
//                     Bridge.d("用户主动取消购买。");
//                     Bridge.cancel("用户主动取消购买。");

//                 } else {
//                     Bridge.d("购买中断，状态码为：" + responseCode);
//                     Bridge.fail("购买中断，状态码为：" + responseCode);

//                 }
//             }

//             @Override
//             public void onVersionNotSupport() {
//                 Bridge.fail("用户谷歌版本不支持支付。");
//                 isConnect = false;
//             }
//         });

//     }

//     private static void adddate(String key, String data) {
//         backdata.put(key, data);
//     }

//     private static String getdate(String key) {
//         String value = backdata.get(key) + "";
//         return value;
//         // backdata.put(key, data);
//     }

//     public static String get() {
       
//         JSONObject json = new JSONObject();
//         json.putAll(backdata);
//         String jsonstr = json.toString();
//         System.out.println("全部信息=" + jsonstr);
//         return jsonstr;
//     }

//     public static void startgoogleBuy(String sku, String payload) {
//         if (!noDuplication()) {
//             Bridge.d("点击频繁");
//             return;
//         }
//         adddate("fluttersku", sku);
//         adddate("flutterpayload", payload);
//         List<String> skuList = new ArrayList<>();
//         skuList.add(sku);
//         @BillingClient.productType
//         String type = BillingClient.ProductType.INAPP;
//         BillingUtil.getInstance().queryProductDetailsAsync(type, skuList, (billingResult, skuDetailsList) -> {

//             if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK && skuDetailsList != null
//                     && skuDetailsList.size() > 0) {
//                 for (productDetails skuDetails : skuDetailsList) {
//                     //结算库3传自定义参数
//                     BillingUtil.getInstance().setpayload(payload);
//                     BillingUtil.getInstance().setproduct(sku);
//                     BillingUtil.getInstance().initiatePurchaseFlow(skuDetails, type);
//                     break;
//                 }
//             } else {

//                 Bridge.d("商品查询失败，请检查是否拥有此商品：" + sku);
//                 Bridge.call("fail", "商品查询失败，请检查是否拥有此商品：" + sku);

//             }
//         });
//     }

// }
