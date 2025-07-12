import 'package:database/src/features/accounts/accounts.dart';
import 'package:database/src/utils/table_mixin.dart';
import 'package:drift/drift.dart';

class AccountEventItems extends Table with TimestampedTable, SyncActionMixin {
  IntColumn get account => integer().references(AccountItems, #id)();
  IntColumn get accountRemoteId => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {account},
      ];
}
