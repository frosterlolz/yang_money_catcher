import 'package:database/src/utils/table_mixin.dart';
import 'package:drift/drift.dart';

class AccountItems extends Table with TimestampedTable {
  late final remoteId = integer().nullable().unique()();
  TextColumn get name => text()();
  TextColumn get balance => text()();
  TextColumn get currency => text()();
  // TODO(frosterlolz): нет юзеров, чтобы сделать это ссылкой
  IntColumn get userId => integer()();
}
