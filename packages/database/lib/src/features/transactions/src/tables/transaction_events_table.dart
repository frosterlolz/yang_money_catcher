import 'package:database/database.dart';
import 'package:database/src/utils/table_mixin.dart';
import 'package:drift/drift.dart';

class TransactionEventItems extends Table with TimestampedTable, SyncActionMixin {
  IntColumn get transaction => integer().references(TransactionItems, #id)();
  IntColumn get transactionRemoteId => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {transaction},
  ];
}
