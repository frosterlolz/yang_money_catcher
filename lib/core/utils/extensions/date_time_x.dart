import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get ddMMyyyy => DateFormat('dd.MM.yyyy').format(this);
  String get hhmm => DateFormat('HH:mm').format(this);

  bool isSameDate(DateTime other) => year == other.year && month == other.month && day == other.day;
  bool isSameTime(DateTime other) => hour == other.hour && minute == other.minute;
}

extension TimeOfDayX on TimeOfDay {
  bool isSameTime(TimeOfDay other) => hour == other.hour && minute == other.minute;
}
