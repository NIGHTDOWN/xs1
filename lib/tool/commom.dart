//公共库
import 'package:common_utils/common_utils.dart';

class ZHTimelineInfo implements TimelineInfo {
  String suffixAgo() => '前';
  String suffixAfter() => '后';
  String lessThanTenSecond() => '刚刚';
  String customYesterday() => '昨天';
  bool keepOneDay() => true;
  bool keepTwoDays() => false;
  String oneMinute(int minutes) => '$minutes分';
  String minutes(int minutes) => '$minutes分';
  String anHour(int hours) => '$hours小时';
  String hours(int hours) => '$hours小时';
  String oneDay(int days) => '$days天';
  String days(int days) => '$days天';

  @override
  String lessThanOneMinute() {
    // TODO: implement lessThanOneMinute
    return null;
  }

  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    return null;
  }

  @override
  String weeks(int week) {
    // TODO: implement weeks
    return null;
  }
}
class ThreeimelineInfo implements TimelineInfo {
  String suffixAgo() => '前';
  String suffixAfter() => '后';
  String lessThanTenSecond() => '刚刚';
  String customYesterday() => '昨天';
  bool keepOneDay() => false;
  bool keepTwoDays() => false;
  String oneMinute(int minutes) => '一分内';
  String minutes(int minutes) => '$minutes分';
  String anHour(int hours) => '$hours小时';
  String hours(int hours) => '$hours小时';
  String oneDay(int days) => '$days天';
  String days(int days) => '$days天';

  @override
  String lessThanOneMinute() {
    // TODO: implement lessThanOneMinute
    return null;
  }

  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    return null;
  }

  @override
  String weeks(int week) {
    // TODO: implement weeks
    return null;
  }
}
class ENTimelineInfo implements TimelineInfo {
  String suffixAgo() => ' ago';
  String suffixAfter() => ' after';
  String lessThanTenSecond() => 'just now';
  String customYesterday() => 'Yesterday';
  bool keepOneDay() => true;
  bool keepTwoDays() => false;
  String oneMinute(int minutes) => 'a minute';
  String minutes(int minutes) => '$minutes minutes';
  String anHour(int hours) => 'an hour';
  String hours(int hours) => '$hours hours';
  String oneDay(int days) => 'a day';
  String days(int days) => '$days days';

  @override
  String lessThanOneMinute() {
    // TODO: implement lessThanOneMinute
    return null;
  }

  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    return null;
  }

  @override
  String weeks(int week) {
    // TODO: implement weeks
    return null;
  }
}

String gettime(String time) {
//  setLocaleInfo('one', ZHTimelineInfo());
  setLocaleInfo('two', ENTimelineInfo());
  return TimelineUtil.format(int.parse(time + '000'), locale: ('one'));
}
String gettime2(String time) {
  //setLocaleInfo('three', ThreeimelineInfo());
 setLocaleInfo('two', ENTimelineInfo());
  return TimelineUtil.format(int.parse(time + '000'), locale: ('two'));
}