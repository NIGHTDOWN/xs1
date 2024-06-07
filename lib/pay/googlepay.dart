import 'AdBridge.dart';

class Googlepay {
  Future<void> init(
      {required ASuccessCallback func_success,
      required AFailureCallback func_fail,
      ACancelCallback? func_cancel}) async {
    AdBridge.callback(
      function_success: func_success,
      function_fail: func_fail,
      function_cancel: func_cancel!,
    );
    AdBridge.call("googlepay/initpays");
    // _platformVersion = data as String;
  }

  void buy(
      {required String sku,
      required String payload,
      required ASuccessCallback func_success,
      required AFailureCallback func_fail,
      required ACancelCallback func_cancel}) async {
// {packagename=com.ng.lovenovel, sku=payidls_1, token=ngfgloomgjnpfhjebilckdil.AO-J1Oyb2DPUUA182tZE-Y79VBFmSYOkCHqOXeyKcR5L0ROpUiT3DOBHn0dni6UzFZK5hDMBOhxW176hw3XWnGaQX8v7SMOsRXcY14H4RiY9cfSjXSqrKNg, purchasestate=1, fluttersku=payidls_1, purchasetime=1578033450708, flutterpayload=测试是不是加入payload, consumetoken=ngfgloomgjnpfhjebilckdil.AO-J1Oyb2DPUUA182tZE-Y79VBFmSYOkCHqOXeyKcR5L0ROpUiT3DOBHn0dni6UzFZK5hDMBOhxW176hw3XWnGaQX8v7SMOsRXcY14H4RiY9cfSjXSqrKNg, orderid=GPA.3315-9027-5593-93708}

    AdBridge.callback(
      function_success: func_success,
      function_fail: func_fail,
      function_cancel: func_cancel,
    );
    // ignore: unused_local_variable
    var data = await AdBridge.call(
        'googlepay/startgoogleBuy', {'sku': sku, 'payload': payload});

    return;
  }

  // void onSuccess([data]) {
  //   d("进入onSuccess" + data);
  //   // setState(() {
  //   //   _googlePayToken = data;
  //   // });
  // }

  // void onFailure([data]) {
  //   d("进入onFailure" + data);
  //   // setState(() {
  //   //   _googlePayToken = "Failure";
  //   // });
  // }

  // void onCancelled([data]) {
  //   d("进入onCancelled" + data);
  //   // setState(() {
  //   //   _googlePayToken = "Cancelled";
  //   // });
  // }
}
