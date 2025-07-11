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
      (accountItems.select()..where((table) => table.id.equals(id))).getSingleOrNull();

  /// Возвращает аккаунт, который был удален
  Future<AccountItem?> deleteAccount(int id) async => transaction(() async {
        final account = await fetchAccount(id);
        await (delete(accountItems)..where((t) => t.id.equals(id))).go();
        return account;
      });

  Future<AccountItem> upsertAccount(AccountItemsCompanion companion) async =>
      companion.id.present ? _updateAccount(companion) : _insertOrUpdateByRemoteId(companion);

  Future<AccountItem> _insertOrUpdateByRemoteId(AccountItemsCompanion companion) async {
    final remoteId = companion.remoteId.value;

    if (remoteId != null) {
      // Пробуем обновить по remoteId
      final updatedRows =
          await (update(accountItems)..where((tbl) => tbl.remoteId.equals(remoteId))).writeReturning(companion);

      if (updatedRows.isNotEmpty) {
        return updatedRows.first;
      }
    }

    // Вставляем как новую
    return into(accountItems).insertReturning(companion);
  }

  Future<AccountItem> _updateAccount(AccountItemsCompanion companion) async =>
      (await accountItems.update().writeReturning(companion)).first;
}
