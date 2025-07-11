import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/account/data/dto/dto.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

final class AccountsLocalDataSource$Drift implements AccountsLocalDataSource {
  const AccountsLocalDataSource$Drift(this._accountsDao);

  final AccountsDao _accountsDao;

  @override
  Future<int> fetchAccountsCount() => _accountsDao.accountsRowCount();

  @override
  Future<List<AccountEntity>> syncAccounts({
    required List<AccountEntity> localAccounts,
    required List<AccountDto> remoteAccounts,
  }) async {
    final companionsToUpsert = remoteAccounts.map((remoteAccount) {
      final overlap = localAccounts.firstWhereOrNull((localAccount) => localAccount.remoteId == remoteAccount.id);
      return AccountItemsCompanion(
        id: overlap == null ? const Value.absent() : Value(overlap.id),
        remoteId: Value(remoteAccount.id),
        name: Value(remoteAccount.name),
        balance: Value(remoteAccount.balance),
        currency: Value(remoteAccount.currency.key),
        createdAt: Value(remoteAccount.createdAt),
        updatedAt: Value(remoteAccount.updatedAt),
        userId: Value(remoteAccount.userId),
      );
    }).toList(growable: false);
    final idSToDelete = localAccounts
        .where((local) => local.remoteId != null && !remoteAccounts.any((remote) => remote.id == local.remoteId))
        .map((local) => local.id)
        .toList(growable: false);
    await _accountsDao.syncAccounts(companionsToUpsert: companionsToUpsert, idSToDelete: idSToDelete);
    return fetchAccounts();
  }

  @override
  Future<AccountEntity> syncAccount(AccountEntity account) async {
    final companion = AccountItemsCompanion(
      id: Value(account.id),
      remoteId: Value(account.remoteId),
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency.key),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      userId: Value(account.userId),
    );
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }

  @override
  Future<AccountEntity> syncAccountDetails(AccountDetailsDto account, {int? id}) async {
    final companion = AccountItemsCompanion(
      id: id == null ? const Value.absent() : Value(id),
      remoteId: Value(account.id),
      name: Value(account.name),
      balance: Value(account.balance),
      currency: Value(account.currency.key),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
    );
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }

  @override
  Future<AccountEntity> syncAccountHistory(int? id, {required AccountHistoryDto accountHistory}) async {
    final companion = AccountItemsCompanion(
      id: id == null ? const Value.absent() : Value(id),
      remoteId: Value(accountHistory.accountId),
      name: Value(accountHistory.accountName),
      currency: Value(accountHistory.currency.key),
    );
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }

  @override
  Future<AccountEntity?> deleteAccount(int id) async {
    final accountItem = await _accountsDao.deleteAccount(id);

    return accountItem == null ? null : AccountEntity.fromTableItem(accountItem);
  }

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
      updatedAt: Value(now),
      // TODO(frosterlolz): исправить на корректное значение, если будут пользователи
      userId: const Value(1),
    );
    final accountItem = await _accountsDao.upsertAccount(companion);
    return AccountEntity.fromTableItem(accountItem);
  }
}
