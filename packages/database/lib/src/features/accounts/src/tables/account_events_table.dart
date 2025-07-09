import 'package:database/src/features/accounts/accounts.dart';
import 'package:database/src/utils/table_mixin.dart';
import 'package:drift/drift.dart';

class AccountEventItems extends Table with TimestampedTable, SyncActionMixin {
  late final account = integer().references(AccountItems, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {account},
      ];
}
