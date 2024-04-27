
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/http.dart';


class Catemodel {
  static dynamic cachedata = 'category_data_';
  static dynamic cachedatatime = 'category_data_time';
  static String api = 'mark/getcategory';
  static getcate() async {
    if (isnull(getcache(cachedata))) {
      var cache = getcache(cachedata);
      // ignore: dead_code
      if (!isnull(getcache(cachedatatime))) {
        httpget();
      }
      return cache;
    } else {
      return await httpget();
    }
  }

  static httpget() async {
    var data = await http(api, {}, gethead(), 30);
    List tmp = getdata(g('context'), data!);
    if (isnull(tmp)) {
      setcache(cachedata, tmp, '-1');
      setcache(cachedatatime, 1, '7200');
      return tmp;
    }
    return [];
    // setState(() {});
  }
}
