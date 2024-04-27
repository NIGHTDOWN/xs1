//公共库

class DateFormats {
  static String full = 'yyyy-MM-dd HH:mm:ss';
  static String y_mo_d_h_m = 'yyyy-MM-dd HH:mm';
  static String y_mo_d = 'yyyy-MM-dd';
  static String y_mo = 'yyyy-MM';
  static String mo_d = 'MM-dd';
  static String mo_d_h_m = 'MM-dd HH:mm';
  static String h_m_s = 'HH:mm:ss';
  static String h_m = 'HH:mm';

  static String zh_full = 'yyyy年MM月dd日 HH时mm分ss秒';
  static String zh_y_mo_d_h_m = 'yyyy年MM月dd日 HH时mm分';
  static String zh_y_mo_d = 'yyyy年MM月dd日';
  static String zh_y_mo = 'yyyy年MM月';
  static String zh_mo_d = 'MM月dd日';
  static String zh_mo_d_h_m = 'MM月dd日 HH时mm分';
  static String zh_h_m_s = 'HH时mm分ss秒';
  static String zh_h_m = 'HH时mm分';
}

/// month->days.
Map<int, int> MONTH_DAY = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31,
};

/// Date Util.
class DateUtil {
  /// get DateTime By DateStr.
  static DateTime? getDateTime(String dateStr, {required bool isUtc}) {
    DateTime? dateTime = DateTime.tryParse(dateStr);
    // ignore: unnecessary_null_comparison
    if (isUtc != null) {
      if (isUtc) {
        dateTime = dateTime!.toUtc();
      } else {
        dateTime = dateTime!.toLocal();
      }
    }
    return dateTime;
  }

  /// get DateTime By Milliseconds.
  static DateTime? getDateTimeByMs(int ms, {bool isUtc = false}) {
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
  }

  /// get DateMilliseconds By DateStr.
  static int? getDateMsByTimeStr(String dateStr, {required bool isUtc}) {
    DateTime? dateTime = getDateTime(dateStr, isUtc: isUtc);
    return dateTime?.millisecondsSinceEpoch;
  }

  /// get Now Date Milliseconds.
  static int getNowDateMs() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// get Now Date Str.(yyyy-MM-dd HH:mm:ss)
  static String getNowDateStr() {
    return formatDate(DateTime.now(), format: '');
  }

  /// format date by milliseconds.
  /// milliseconds 日期毫秒
  static String formatDateMs(int ms, {bool isUtc = false, required String format}) {
    return formatDate(getDateTimeByMs(ms, isUtc: isUtc), format: format);
  }

  /// format date by date str.
  /// dateStr 日期字符串
  static String formatDateStr(String dateStr, {required bool isUtc, required String format}) {
    return formatDate(getDateTime(dateStr, isUtc: isUtc), format: format);
  }

  /// format date by DateTime.
  /// format 转换格式(已提供常用格式 DateFormats，可以自定义格式：'yyyy/MM/dd HH:mm:ss')
  /// 格式要求
  /// year -> yyyy/yy   month -> MM/M    day -> dd/d
  /// hour -> HH/H      minute -> mm/m   second -> ss/s
  static String formatDate(DateTime? dateTime, {required String format}) {
    // ignore: unnecessary_null_comparison
    if (dateTime == null) return '';
    format = format ?? DateFormats.full;
    if (format.contains('yy')) {
      String year = dateTime.year.toString();
      if (format.contains('yyyy')) {
        format = format.replaceAll('yyyy', year);
      } else {
        format = format.replaceAll(
            'yy', year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  /// com format.
  static String _comFormat(
      int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format =
            format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }

  /// get WeekDay.
  /// dateTime
  /// isUtc
  /// languageCode zh or en
  /// short
  static String? getWeekday(DateTime dateTime,
      {String languageCode = 'en', bool short = false}) {
    if (dateTime == null) return null;
    String weekday="";
    switch (dateTime.weekday) {
      case 1:
        weekday = languageCode == 'zh' ? '星期一' : 'Monday';
        break;
      case 2:
        weekday = languageCode == 'zh' ? '星期二' : 'Tuesday';
        break;
      case 3:
        weekday = languageCode == 'zh' ? '星期三' : 'Wednesday';
        break;
      case 4:
        weekday = languageCode == 'zh' ? '星期四' : 'Thursday';
        break;
      case 5:
        weekday = languageCode == 'zh' ? '星期五' : 'Friday';
        break;
      case 6:
        weekday = languageCode == 'zh' ? '星期六' : 'Saturday';
        break;
      case 7:
        weekday = languageCode == 'zh' ? '星期日' : 'Sunday';
        break;
      default:
        break;
    }
    return languageCode == 'zh'
        ? (short ? weekday.replaceAll('星期', '周') : weekday)
        : weekday.substring(0, short ? 3 : weekday.length);
  }

  /// get WeekDay By Milliseconds.
  static String? getWeekdayByMs(int milliseconds,
      {bool isUtc = false, required String languageCode, bool short = false}) {
    DateTime? dateTime = getDateTimeByMs(milliseconds, isUtc: isUtc);
    return getWeekday(dateTime!, languageCode: languageCode, short: short);
  }

  /// get day of year.
  /// 在今年的第几天.
  static int getDayOfYear(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int days = dateTime.day;
    for (int i = 1; i < month; i++) {
      days = days + MONTH_DAY[i]!;
    }
    if (isLeapYearByYear(year) && month > 2) {
      days = days + 1;
    }
    return days;
  }

  /// get day of year.
  /// 在今年的第几天.
  static int getDayOfYearByMs(int ms, {bool isUtc = false}) {
    return getDayOfYear(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc));
  }

  /// is today.
  /// 是否是当天.
  static bool isToday(int milliseconds, {bool isUtc = false, int? locMs}) {
     // ignore: unnecessary_null_comparison
    if (milliseconds == null || milliseconds == 0) return false;
    DateTime old =
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: isUtc);
    DateTime? now;
    // ignore: unnecessary_null_comparison
    if (locMs != null) {
      now = DateUtil.getDateTimeByMs(locMs);
    } else {
      now = isUtc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    }
    return old.year == now?.year && old.month == now?.month && old.day == now?.day;
  }

  /// is yesterday by dateTime.
  /// 是否是昨天.
  static bool isYesterday(DateTime dateTime, DateTime locDateTime) {
    if (yearIsEqual(dateTime, locDateTime)) {
      int spDay = getDayOfYear(locDateTime) - getDayOfYear(dateTime);
      return spDay == 1;
    } else {
      return ((locDateTime.year - dateTime.year == 1) &&
          dateTime.month == 12 &&
          locDateTime.month == 1 &&
          dateTime.day == 31 &&
          locDateTime.day == 1);
    }
  }

  /// is yesterday by millis.
  /// 是否是昨天.
  static bool isYesterdayByMs(int ms, int locMs) {
    return isYesterday(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  /// is Week.
  /// 是否是本周.
  static bool isWeek(int ms, {bool isUtc = false, required int locMs}) {
    if (ms == null || ms <= 0) {
      return false;
    }
    DateTime _old = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
    DateTime? _now;
    if (locMs != null) {
      _now = DateUtil.getDateTimeByMs(locMs, isUtc: isUtc);
    } else {
      _now = isUtc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    }

    DateTime old =
        _now!.millisecondsSinceEpoch > _old.millisecondsSinceEpoch ? _old : _now;
    DateTime now =
        _now.millisecondsSinceEpoch > _old.millisecondsSinceEpoch ? _now : _old;
    return (now.weekday >= old.weekday) &&
        (now.millisecondsSinceEpoch - old.millisecondsSinceEpoch <=
            7 * 24 * 60 * 60 * 1000);
  }

  /// year is equal.
  /// 是否同年.
  static bool yearIsEqual(DateTime dateTime, DateTime locDateTime) {
    return dateTime.year == locDateTime.year;
  }

  /// year is equal.
  /// 是否同年.
  static bool yearIsEqualByMs(int ms, int locMs) {
    return yearIsEqual(DateTime.fromMillisecondsSinceEpoch(ms),
        DateTime.fromMillisecondsSinceEpoch(locMs));
  }

  /// Return whether it is leap year.
  /// 是否是闰年
  static bool isLeapYear(DateTime dateTime) {
    return isLeapYearByYear(dateTime.year);
  }

  /// Return whether it is leap year.
  /// 是否是闰年
  static bool isLeapYearByYear(int year) {
    return year % 4 == 0 && year % 100 != 0 || year % 400 == 0;
  }
}

/// (xx)Configurable output.
/// (xx)为可配置输出.
enum DayFormat {
  /// (less than 10s->just now)、x minutes、x hours、(Yesterday)、x days.
  /// (小于10s->刚刚)、x分钟、x小时、(昨天)、x天.
  Simple,

  /// (less than 10s->just now)、x minutes、x hours、[This year:(Yesterday/a day ago)、(two days age)、MM-dd ]、[past years: yyyy-MM-dd]
  /// (小于10s->刚刚)、x分钟、x小时、[今年: (昨天/1天前)、(2天前)、MM-dd],[往年: yyyy-MM-dd].
  Common,

  /// 日期 + HH:mm
  /// (less than 10s->just now)、x minutes、x hours、[This year:(Yesterday HH:mm/a day ago)、(two days age)、MM-dd HH:mm]、[past years: yyyy-MM-dd HH:mm]
  /// 小于10s->刚刚)、x分钟、x小时、[今年: (昨天 HH:mm/1天前)、(2天前)、MM-dd HH:mm],[往年: yyyy-MM-dd HH:mm].
  Full,
}

/// Timeline information configuration.
/// Timeline信息配置.
abstract class TimelineInfo {
  String suffixAgo(); //suffix ago(后缀 后).

  String suffixAfter(); //suffix after(后缀 前).

  int maxJustNowSecond() => 30; // max just now second.

  String lessThanOneMinute() => ''; //just now(刚刚).

  String customYesterday() => ''; //Yesterday(昨天).优先级高于keepOneDay

  bool keepOneDay(); //保持1天,example: true -> 1天前, false -> MM-dd.

  bool keepTwoDays(); //保持2天,example: true -> 2天前, false -> MM-dd.

  String oneMinute(int minutes); //a minute(1分钟).

  String minutes(int minutes); //x minutes(x分钟).

  String anHour(int hours); //an hour(1小时).

  String hours(int hours); //x hours(x小时).

  String oneDay(int days); //a day(1天).

  String weeks(int week) => ''; //x week(星期x).

  String days(int days); //x days(x天).

}

class ZhInfo implements TimelineInfo {
  String suffixAgo() => '前';

  String suffixAfter() => '后';

  int maxJustNowSecond() => 30;

  String lessThanOneMinute() => '刚刚';

  String customYesterday() => '昨天';

  bool keepOneDay() => true;

  bool keepTwoDays() => true;

  String oneMinute(int minutes) => '$minutes分钟';

  String minutes(int minutes) => '$minutes分钟';

  String anHour(int hours) => '$hours小时';

  String hours(int hours) => '$hours小时';

  String oneDay(int days) => '$days天';

  String weeks(int week) => ''; //x week(星期x).

  String days(int days) => '$days天';
}

class EnInfo implements TimelineInfo {
  String suffixAgo() => ' ago';

  String suffixAfter() => ' after';

  int maxJustNowSecond() => 30;

  String lessThanOneMinute() => 'just now';

  String customYesterday() => 'Yesterday';

  bool keepOneDay() => true;

  bool keepTwoDays() => true;

  String oneMinute(int minutes) => 'a minute';

  String minutes(int minutes) => '$minutes minutes';

  String anHour(int hours) => 'an hour';

  String hours(int hours) => '$hours hours';

  String oneDay(int days) => 'a day';

  String weeks(int week) => ''; //x week(星期x).

  String days(int days) => '$days days';
}

class ZhNormalInfo implements TimelineInfo {
  String suffixAgo() => '前';

  String suffixAfter() => '后';

  int maxJustNowSecond() => 30;

  String lessThanOneMinute() => '刚刚';

  String customYesterday() => '昨天';

  bool keepOneDay() => true;

  bool keepTwoDays() => false;

  String oneMinute(int minutes) => '$minutes分钟';

  String minutes(int minutes) => '$minutes分钟';

  String anHour(int hours) => '$hours小时';

  String hours(int hours) => '$hours小时';

  String oneDay(int days) => '$days天';

  String weeks(int week) => ''; //x week(星期x).

  String days(int days) => '$days天';
}

class EnNormalInfo implements TimelineInfo {
  String suffixAgo() => ' ago';

  String suffixAfter() => ' after';

  int maxJustNowSecond() => 30;

  String lessThanOneMinute() => 'just now';

  String customYesterday() => 'Yesterday';

  bool keepOneDay() => true;

  bool keepTwoDays() => false;

  String oneMinute(int minutes) => 'a minute';

  String minutes(int minutes) => '$minutes minutes';

  String anHour(int hours) => 'an hour';

  String hours(int hours) => '$hours hours';

  String oneDay(int days) => 'a day';

  String weeks(int week) => ''; //x week(星期x).

  String days(int days) => '$days days';
}

Map<String, TimelineInfo> _timelineInfoMap = {
  'zh': ZhInfo(),
  'en': EnInfo(),
  'zh_normal': ZhNormalInfo(), //keepTwoDays() => false
  'en_normal': EnNormalInfo(), //keepTwoDays() => false
};

/// add custom configuration.
void setLocaleInfo(String locale, TimelineInfo timelineInfo) {
  assert(locale != null, '[locale] must not be null');
  assert(timelineInfo != null, '[timelineInfo] must not be null');
  _timelineInfoMap[locale] = timelineInfo;
}

/// TimelineUtil
class TimelineUtil {
  /// format time by DateTime.
  /// dateTime
  /// locDateTime: current time or schedule time.
  /// locale: output key.
  static String formatByDateTime(
    DateTime dateTime, {
    required DateTime locDateTime,
    required String locale,
    required DayFormat dayFormat,
  }) {
    return format(
      dateTime!.millisecondsSinceEpoch,
      locTimeMs: locDateTime!.millisecondsSinceEpoch,
      locale: locale,
      dayFormat: dayFormat,
    );
  }

  /// format time by millis.
  /// dateTime : millis.
  /// locDateTime: current time or schedule time. millis.
  /// locale: output key.
  static String format(
    int ms, {
    required int locTimeMs,
    required String locale,
    required DayFormat dayFormat,
  }) {
    int _locTimeMs = locTimeMs ?? DateTime.now().millisecondsSinceEpoch;
    String _locale = locale ?? 'en';
    TimelineInfo _info = _timelineInfoMap[_locale] ?? EnInfo();
    DayFormat _dayFormat = dayFormat ?? DayFormat.Common;

    int elapsed = _locTimeMs - ms;
    String suffix;
    if (elapsed < 0) {
      suffix = _info.suffixAfter();
      // suffix after is empty. user just now.
      if (suffix.isNotEmpty) {
        elapsed = elapsed.abs();
        _dayFormat = DayFormat.Simple;
      } else {
        return _info.lessThanOneMinute();
      }
    } else {
      suffix = _info.suffixAgo();
    }

    String timeline;
    if (_info.customYesterday().isNotEmpty &&
        DateUtil.isYesterdayByMs(ms, _locTimeMs)) {
      return _getYesterday(ms, _info, _dayFormat);
    }

    if (!DateUtil.yearIsEqualByMs(ms, _locTimeMs)) {
      timeline = _getYear(ms, _dayFormat);
      if (timeline.isNotEmpty) return timeline;
    }

    final num seconds = elapsed / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;

    if (seconds < 90) {
      timeline = _info.oneMinute(1);
      if (suffix != _info.suffixAfter() &&
          _info.lessThanOneMinute().isNotEmpty &&
          seconds < _info.maxJustNowSecond()) {
        timeline = _info.lessThanOneMinute();
        suffix = '';
      }
    } else if (minutes < 60) {
      timeline = _info.minutes(minutes.round());
    } else if (minutes < 90) {
      timeline = _info.anHour(1);
    } else if (hours < 24) {
      timeline = _info.hours(hours.round());
    } else {
      if ((days.round() == 1 && _info.keepOneDay() == true) ||
          (days.round() == 2 && _info.keepTwoDays() == true)) {
        _dayFormat = DayFormat.Simple;
      }
      timeline = _formatDays(ms, days.round(), _info, _dayFormat);
      suffix = (_dayFormat == DayFormat.Simple ? suffix : '');
    }
    return timeline + suffix;
  }

  /// Timeline like QQ.
  ///
  /// today (HH:mm)
  /// yesterday (昨天;Yesterday)
  /// this week (星期一,周一;Monday,Mon)
  /// others (yyyy-MM-dd)
  static String? formatA(
    int ms, {
    int? locMs,
    String formatToday = 'HH:mm',
    String format = 'yyyy-MM-dd',
    String languageCode = 'en',
    bool short = false,
  }) {
    int _locTimeMs = locMs ?? DateTime.now().millisecondsSinceEpoch;
    int elapsed = _locTimeMs - ms;
    if (elapsed < 0) {
      return DateUtil.formatDateMs(ms, format: formatToday);
    }

    if (DateUtil.isToday(ms, locMs: _locTimeMs)) {
      return DateUtil.formatDateMs(ms, format: formatToday);
    }

    if (DateUtil.isYesterdayByMs(ms, _locTimeMs)) {
      return languageCode == 'zh' ? '昨天' : 'Yesterday';
    }

    if (DateUtil.isWeek(ms, locMs: _locTimeMs)) {
      return DateUtil.getWeekdayByMs(ms,
          languageCode: languageCode, short: short);
    }

    return DateUtil.formatDateMs(ms, format: format);
  }

  /// get Yesterday.
  /// 获取昨天.
  static String _getYesterday(
    int ms,
    TimelineInfo info,
    DayFormat dayFormat,
  ) {
    return info.customYesterday() +
        (dayFormat == DayFormat.Full
            ? (' ' + DateUtil.formatDateMs(ms, format: 'HH:mm'))
            : '');
  }

  /// get is not year info.
  /// 获取非今年信息.
  static String _getYear(
    int ms,
    DayFormat dayFormat,
  ) {
    if (dayFormat != DayFormat.Simple) {
      return DateUtil.formatDateMs(ms,
          format: (dayFormat == DayFormat.Common
              ? 'yyyy-MM-dd'
              : 'yyyy-MM-dd HH:mm'));
    }
    return '';
  }

  /// format Days.
  static String _formatDays(
    int ms,
    num days,
    TimelineInfo info,
    DayFormat dayFormat,
  ) {
    String timeline;
    switch (dayFormat) {
      case DayFormat.Simple:
        timeline = (days == 1
            ? info.customYesterday().isEmpty
                ? info.oneDay(days.round())
                : info.days(2)
            : info.days(days.round()));
        break;
      case DayFormat.Common:
        timeline = DateUtil.formatDateMs(ms, format: 'MM-dd');
        break;
      case DayFormat.Full:
        timeline = DateUtil.formatDateMs(ms, format: 'MM-dd HH:mm');
        break;
    }
    return timeline;
  }
}

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
    throw UnimplementedError();
  }
  
  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    throw UnimplementedError();
  }
  
  @override
  String weeks(int week) {
    // TODO: implement weeks
    throw UnimplementedError();
  }

  // @override
  // String? lessThanOneMinute() {
  //   // TODO: implement lessThanOneMinute
  //   return null;
  // }

  // @override
  // int? maxJustNowSecond() {
  //   // TODO: implement maxJustNowSecond
  //   return null;
  // }

  // @override
  // String? weeks(int week) {
  //   // TODO: implement weeks
  //   return null;
  // }
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
    throw UnimplementedError();
  }
  
  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    throw UnimplementedError();
  }
  
  @override
  String weeks(int week) {
    // TODO: implement weeks
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
  
  @override
  int maxJustNowSecond() {
    // TODO: implement maxJustNowSecond
    throw UnimplementedError();
  }
  
  @override
  String weeks(int week) {
    // TODO: implement weeks
    throw UnimplementedError();
  }

  
}

String gettime(String time) {
//  setLocaleInfo('one', ZHTimelineInfo());
  setLocaleInfo('two', ENTimelineInfo());
  return TimelineUtil.format(int.parse(time + '000'), locale: ('one'), locTimeMs: 0, dayFormat: DayFormat.Simple);
}

String gettime2(String time) {
  //setLocaleInfo('three', ThreeimelineInfo());
  setLocaleInfo('two', ENTimelineInfo());
  return TimelineUtil.format(int.parse(time + '000'), locale: ('two'), locTimeMs: 0, dayFormat: DayFormat.Simple);
}
