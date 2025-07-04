import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [AccountItems])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.attachedDatabase);

  Future<int> accountsRowCount() => accountItems.count().getSingle();
  Future<List<AccountItem>> fetchAccounts() => accountItems.select().get();
  Future<AccountItem?> fetchAccount(int id) =>
      (accountItems.select()..where((accountItem) => accountItem.id.equals(id))).getSingleOrNull();
  Future<int> deleteAccount(int id) => (delete(accountItems)..where((t) => t.id.equals(id))).go();
  Future<AccountItem> upsertAccount(AccountItemsCompanion companion) async =>
      companion.id.present ? _updateAccount(companion) : _insertAccount(companion);

  Future<AccountItem> _insertAccount(AccountItemsCompanion companion) async =>
      into(accountItems).insertReturning(companion);

  Future<AccountItem> _updateAccount(AccountItemsCompanion companion) async => transaction(() async {
        final statement = update(accountItems)..where((tx) => tx.id.equals(companion.id.value));
        final updatedRowId = await statement.write(companion);
        final updatedAccount = select(accountItems)..where((tx) => tx.rowId.equals(updatedRowId));
        return updatedAccount.getSingle();
      });
}
