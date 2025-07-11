import 'package:drift/drift.dart';

mixin SyncActionMixin on Table {
  late final actionType = text()();
  late final attempts = integer().withDefault(const Constant(0))();
}

mixin TimestampedTable on Table {
  late final id = integer().autoIncrement()();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
  late final updatedAt = dateTime().withDefault(currentDateAndTime)();
}
