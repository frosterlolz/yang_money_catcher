import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

final class AccountsLocalDataSource$Drift implements AccountsLocalDataSource {
  const AccountsLocalDataSource$Drift(this._accountsDao);

  final AccountsDao _accountsDao;

  @override
  Future<int> fetchAccountsCount() => _accountsDao.accountsRowCount();

  @override
  Future<List<AccountEntity>> syncAccounts(List<AccountEntity> accounts) async {
    final companions = accounts
        .map(
          (account) => AccountItemsCompanion.insert(
            id: Value(account.id),
            name: account.name,
            balance: account.balance,
            currency: account.currency.key,
            createdAt: Value(account.createdAt),
            updatedAt: Value(account.updatedAt),
            userId: account.userId,
          ),
        )
        .toList();
    await _accountsDao.syncAccounts(companions);
    return fetchAccounts();
  }

  @override
  Future<AccountEntity> syncAccount(AccountEntity account) async {
    final companion = AccountItemsCompanion.insert(
      id: Value(account.id),
      name: account.name,
      balance: account.balance,
      currency: account.currency.key,
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      userId: account.userId,
    );
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }

  @override
  Future<int> deleteAccount(int id) => _accountsDao.deleteAccount(id);

  @override
  Future<List<AccountEntity>> fetchAccounts() async {
    final accountItem = await _accountsDao.fetchAccounts();
    return accountItem.map(AccountEntity.fromTableItem).toList();
  }

  @override
  Future<AccountEntity?> fetchAccount(int id) async {
    final accountItem = await _accountsDao.fetchAccount(id);
    return accountItem == null ? null : AccountEntity.fromTableItem(accountItem);
  }

  @override
  Future<AccountEntity> updateAccount(AccountRequest request) async {
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
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }
}
