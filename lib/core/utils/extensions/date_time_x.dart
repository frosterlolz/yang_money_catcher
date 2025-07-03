import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get ddMM => DateFormat('dd.MM').format(this);
  String get ddMMyyyy => DateFormat('dd.MM.yyyy').format(this);
  String get ddMMMMyyyy => DateFormat('dd MMMM yyyy').format(this);
  String get hhmm => DateFormat('HH:mm').format(this);

  DateTime get copyWithStartOfDayTme => copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime get copyWithEndOfDayTme => copyWith(hour: 23, minute: 59, second: 59, millisecond: 999, microsecond: 999);
  bool isSameDate(DateTime other) => year == other.year && month == other.month && day == other.day;
  bool isSameTime(DateTime other) => hour == other.hour && minute == other.minute;
  bool isSameDateTime(DateTime other) => isSameDate(other) && isSameTime(other);
  bool isFutureYear(DateTime other) => year > other.year;
  bool isFutureMonth(DateTime other) => year > other.year || month > other.month;
  bool isFutureDay(DateTime other) => isFutureYear(other) || isFutureMonth(other) || day > other.day;
}

extension TimeOfDayX on TimeOfDay {
  bool isSameTime(TimeOfDay other) => hour == other.hour && minute == other.minute;
}
