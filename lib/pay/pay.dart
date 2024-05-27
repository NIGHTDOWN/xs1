import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/lang.dart';

import 'AdBridge.dart';

//内购
class Pay {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late InAppPurchase _inAppPurchase;
  late List<ProductDetails> _products; //内购的商品对象集合
  late ASuccessCallback func_success;
  late AFailureCallback func_fail;
  late ACancelCallback func_cancel;
  late String payload;
  //初始化购买组件
  void initializeInAppPurchase(
      {required ASuccessCallback func_success,
      required AFailureCallback func_fail,
      ACancelCallback? func_cancel}) {
    // 初始化in_app_purchase插件
    _inAppPurchase = InAppPurchase.instance;
    func_success();
    //监听购买的事件
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      error.printError();
      print("购买失败了");
    });
  }

  void resumePurchase() {
    _inAppPurchase.restorePurchases();
  }

  /// 加载全部的商品
  void buyProduct(String productId,
      {required String payload,
      required Future Function([dynamic data]) func_success,
      required void Function([dynamic data]) func_fail,
      required void Function([dynamic data]) func_cancel}) async {
    d("请求商品id " + productId);
    this.payload = payload;
    this.func_success = func_success;
    this.func_fail = func_fail;
    this.func_cancel = func_cancel;
    List<String> _outProducts = [productId];

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // ToastUtil.showToast("无法连接到商店");
      d("无法连接到商店");
      func_fail(lang("无法连接到商店"));
      return;
    }

    //开始购买
    // ToastUtil.showToast("连接成功-开始查询全部商品");
    d("连接成功-开始查询全部商品");
    List<String> _kIds = _outProducts;

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds.toSet());
    d("商品获取结果  " + response.productDetails.toString());
    if (response.notFoundIDs.isNotEmpty) {
      // ToastUtil.showToast("无法找到指定的商品");
      d("无法找到指定的商品");
      func_fail(lang("无法找到指定的商品"));
      // ToastUtil.showToast("无法找到指定的商品 数量 " + response.productDetails.length.toString());

      return;
    }

    // 处理查询到的商品列表
    List<ProductDetails> products = response.productDetails;
    d("products ==== " + products.length.toString());
    if (products.isNotEmpty) {
      //赋值内购商品集合
      _products = products;
    }

    d("全部商品加载完成了，可以启动购买了,总共商品数量为：${products.length}");

    //先恢复可重复购买
    // await _inAppPurchase. ();

    startPurchase(productId);
  }

  // 调用此函数以启动购买过程
  void startPurchase(String productId) async {
    d("购买的商品id为" + productId);
    if (_products != null && _products.isNotEmpty) {
      // ToastUtil.showToast("准备开始启动购买流程");
      try {
        ProductDetails productDetails = _getProduct(productId);

        d("一切正常，开始购买,信息如下：title: ${productDetails.title}  desc:${productDetails.description} "
            "price:${productDetails.price}  currencyCode:${productDetails.currencyCode}  currencySymbol:${productDetails.currencySymbol}");
        _inAppPurchase.buyConsumable(
            purchaseParam: PurchaseParam(productDetails: productDetails));
      } catch (e) {
        // e.printError();
        d("购买失败了");
        func_fail(lang("购买失败了"));
      }
    } else {
      d("当前没有商品无法调用购买逻辑");
      func_fail(lang("当前没有商品无法调用购买逻辑"));
    }
  }

  // 根据产品ID获取产品信息
  ProductDetails _getProduct(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  /// 内购的购买更新监听
  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // 等待支付完成
        _handlePending();
      } else if (purchase.status == PurchaseStatus.canceled) {
        // 取消支付
        _handleCancel(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // 购买失败
        d(purchase.error);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // ToastUtil.showToast(DataConfig.getShowName("Pay_Success_Tip"));
        //完成购买, 到服务器验证
        if (Platform.isAndroid) {
          var googleDetail = purchase;
          checkAndroidPayInfo(googleDetail);
        } else if (Platform.isIOS) {
          var appstoreDetail = purchase;
          checkApplePayInfo(appstoreDetail);
        }
      }
    }
  }

  /// 购买失败
  void _handleError(IAPError iapError) {
    // ToastUtil.showToast("${DataConfig.getShowName("Purchase_Failed")}：${iapError?.code} message${iapError?.message}");
  }

  /// 等待支付
  void _handlePending() {
    d("等待支付");
  }

  /// 取消支付
  void _handleCancel(PurchaseDetails purchase) {
    _inAppPurchase.completePurchase(purchase);
  }

  /// Android支付成功的校验
  void checkAndroidPayInfo(PurchaseDetails googleDetail) async {
    _inAppPurchase.completePurchase(googleDetail);

    d("安卓支付交易ID为" + googleDetail.purchaseID!);
    d("安卓支付验证收据为" + googleDetail.verificationData.serverVerificationData);
  }

  /// Apple支付成功的校验
  void checkApplePayInfo(PurchaseDetails appstoreDetail) async {
    _inAppPurchase.completePurchase(appstoreDetail);

    d("Apple支付交易ID为" + appstoreDetail.purchaseID!);
    d("Apple支付验证收据为" + appstoreDetail.verificationData.serverVerificationData);
  }

  @override
  void onClose() {
    if (Platform.isIOS) {
      // final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      //     _inAppPurchase
      //         .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      // iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }
}
