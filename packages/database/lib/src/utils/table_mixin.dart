import 'package:drift/drift.dart';

mixin TimestampedTable on Table {
  late final id = integer().autoIncrement()();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
  late final updatedAt = dateTime().withDefault(currentDateAndTime)();
}
