import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [AccountItems])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.attachedDatabase);

  Future<int> accountsRowCount() => accountItems.count().getSingle();

  Future<void> syncAccounts({
    required List<AccountItemsCompanion> companionsToUpsert,
    required List<int> idSToDelete,
  }) async {
    await batch((batch) {
      if (idSToDelete.isNotEmpty) {
        batch.deleteWhere(accountItems, (f) => f.id.isIn(idSToDelete));
      }
      if (companionsToUpsert.isNotEmpty) {
        batch.insertAllOnConflictUpdate(accountItems, companionsToUpsert);
      }
    });
  }

  Future<List<AccountItem>> fetchAccounts() => accountItems.select().get();

  Future<AccountItem?> fetchAccount(int id) =>
      (accountItems.select()..where((accountItem) => accountItem.id.equals(id))).getSingleOrNull();

  /// Возвращает remoteId удаленного аккаунта
  Future<int?> deleteAccount(int id) async => transaction(() async {
        final account = await (select(accountItems)..where((t) => t.id.equals(id))).getSingleOrNull();
        await (delete(accountItems)..where((t) => t.id.equals(id))).go();
        return account?.remoteId;
      });

  Future<AccountItem> upsertAccount(AccountItemsCompanion companion) async =>
      companion.id.present ? _updateAccount(companion) : _insertAccount(companion);

  Future<AccountItem> _insertAccount(AccountItemsCompanion companion) async =>
      into(accountItems).insertReturning(companion);

  Future<AccountItem> _updateAccount(AccountItemsCompanion companion) async => transaction(() async {
        final statement = update(accountItems)..where((tx) => tx.id.equals(companion.id.value));
        final updatedAccounts = await statement.writeReturning(companion);
        return updatedAccounts.first;
      });
}
