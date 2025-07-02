import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_storage.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';

final class AccountsDriftStorage implements AccountsLocalStorage {
  const AccountsDriftStorage(this.database);

  final AppDatabase database;

  @override
  Future<int> fetchAccountsCount() async => database.accountItems.count().getSingle();

  @override
  Future<int> deleteAccount(int id) => (database.delete(database.accountItems)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<AccountItem>> fetchAccounts() => database.select(database.accountItems).get();

  @override
  Future<AccountItem?> fetchAccount(int id) =>
      (database.select(database.accountItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<int> updateAccount(AccountRequest request) {
    final now = DateTime.now();

    // Формируем Companion для вставки
    final companion = AccountItemsCompanion(
      id: switch (request) {
        AccountRequest$Create() => const Value.absent(),
        AccountRequest$Update(:final id) => Value(id),
      },
      name: Value(request.name),
      balance: Value(request.balance),
      currency: Value(request.currency.key),
      createdAt: Value.absentIfNull(now),
      updatedAt: Value(now),
      // TODO(frosterlolz): исправить на корректное значение, если будут пользователи
      userId: const Value(1),
    );
    return database.into(database.accountItems).insertOnConflictUpdate(companion);
  }
}
