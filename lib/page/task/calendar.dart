import 'package:flutter/material.dart';

class Calendar {
  static const List<int> _daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  /*
      * 根据年月获取月的天数
      * */
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /*
      * 得到这个月的第一天是星期几（0 是 星期日 1 是 星期一...）
      * */
  static int computeFirstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  /*
      * 每个月前面空出来的天数
      * */
  static int numberOfHeadPlaceholderForMonth(
      int year, int month, MaterialLocalizations localizations) {
    return computeFirstDayOffset(year, month, localizations);
  }

  /*
      * 根据当前年月份计算当前月份显示几行
      * */
  static int getRowsForMonthYear(
      int year, int month, MaterialLocalizations localizations) {
    int currentMonthDays = getDaysInMonth(year, month);
    // 每个月前面空出来的天数
    int placeholderDays =
        numberOfHeadPlaceholderForMonth(year, month, localizations);
    int rows = (currentMonthDays + placeholderDays) ~/ 7; // 向下取整
    int remainder = (currentMonthDays + placeholderDays) % 7; // 取余（最后一行的天数）
    if (remainder > 0) {
      rows += 1;
    }
    return rows;
  }

  static int getLastRowDaysForMonthYear(
      int year, int month, MaterialLocalizations localizations) {
    int count = 0;
    // 当前月份的天数
    int currentMonthDays = getDaysInMonth(year, month);
    // 每个月前面空出来的天数
    int placeholderDays =
        numberOfHeadPlaceholderForMonth(year, month, localizations);
    int rows = (currentMonthDays + placeholderDays) ~/ 7; // 向下取整
    int remainder = (currentMonthDays + placeholderDays) % 7; // 取余（最后一行的天数）
    if (remainder > 0) {
      count = 7 - remainder;
    }
    return count;
  }

  static get(int year, int month, context) {
    var daynum = getDaysInMonth(year, month);
    var xqj =
        computeFirstDayOffset(year, month, MaterialLocalizations.of(context));
    return {'nums': daynum, 'offset': xqj};
  }

/**
 * num 月份天数
 * offset 当月第一天星期几
 */
  static getnow(context) {
    DateTime nowDay = new DateTime.now();
    var year = nowDay.year;
    var month = nowDay.month;
  return get(year,month,context);
  }
}
