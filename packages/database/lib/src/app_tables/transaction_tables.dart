import 'package:database/src/app_tables/account_tables.dart';
import 'package:database/src/utils/table_mixin.dart';
import 'package:drift/drift.dart';

class TransactionItems extends Table with TimestampedTable {
  late final account = integer().references(AccountItems, #id)();
  late final category = integer().references(TransactionCategoryItems, #id)();
  TextColumn get amount => text()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn? get comment => text().nullable()();
}

class TransactionCategoryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  BoolColumn get isIncome => boolean()();
}
