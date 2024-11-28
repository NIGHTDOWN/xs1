//公共库

import 'package:get_time_ago/get_time_ago.dart';
import 'package:ng169/tool/function.dart';
import 'package:ng169/tool/global.dart';
import 'package:ng169/tool/lang.dart';

class CustomMessages implements Messages {
  @override
  String prefixAgo() => '';

  @override
  String suffixAgo() => lang('ago');

  @override
  String secsAgo(int seconds) => '$seconds ' + lang("seconds");

  @override
  String minAgo(int minutes) => '' + lang("a minute");

  @override
  String minsAgo(int minutes) => '$minutes ' + lang("minutes");

  @override
  String hourAgo(int minutes) => lang("an hour");

  @override
  String hoursAgo(int hours) => '$hours ' + lang("hours");

  @override
  String dayAgo(int hours) => '' + lang("a day");

  @override
  String daysAgo(int days) => '$days ' + lang("days");

  @override
  String wordSeparator() => ' ';

  @override
  String justNow(int seconds) {
    return "";
  }
}

/// TimelineUtil
class TimelineUtil {
  static String format(String timestampInSeconds) {
    // var langs = getlang();
    // // d(langs);
    // String languageCode = langs.substring(0, 2);
    GetTimeAgo.setCustomLocaleMessages("en", CustomMessages());
    // BigInt timestampInSecondbig = BigInt.parse(timestampInSeconds);
    int timestampInSecondbig = int.parse(timestampInSeconds);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        timestampInSecondbig * 1000, // 将秒转换为毫秒
        isUtc: true // 指定时间戳是UTC时间
        );
    return GetTimeAgo.parse(dateTime);
  }
}

String gettime(String time) {
  return TimelineUtil.format(time);
}

String gettime2(String time) {
  return TimelineUtil.format(time);
}
