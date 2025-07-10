import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/data/sync_backup/utils/sync_handler_mixin.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/data/source/local/account_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category_stat.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

final class AccountRepositoryImpl with SyncHandlerMixin implements AccountRepository {
  AccountRepositoryImpl({
    required AccountsNetworkDataSource accountsNetworkDataSource,
    required AccountsLocalDataSource accountsLocalStorage,
    required TransactionsLocalDataSource transactionsLocalStorage,
    required AccountEventsSyncDataSource accountEventsSyncDataSource,
  })  : _accountsNetworkDataSource = accountsNetworkDataSource,
        _accountsLocalDataSource = accountsLocalStorage,
        _transactionsLocalStorage = transactionsLocalStorage,
        _accountEventsSyncDataSource = accountEventsSyncDataSource;

  final AccountsNetworkDataSource _accountsNetworkDataSource;
  final AccountsLocalDataSource _accountsLocalDataSource;
  final TransactionsLocalDataSource _transactionsLocalStorage;
  final AccountEventsSyncDataSource _accountEventsSyncDataSource;

  @override
  Stream<DataResult<Iterable<AccountEntity>>> getAccounts() async* {
    await _syncEvents();
    final localAccounts = await _accountsLocalDataSource.fetchAccounts();
    yield DataResult.offline(data: localAccounts);
    try {
      final networkAccounts$Dto = await _accountsNetworkDataSource.getAccounts();
      final syncedAccounts = await _accountsLocalDataSource.syncAccounts(
        localAccounts: localAccounts,
        remoteAccounts: networkAccounts$Dto,
      );
      yield DataResult.online(data: syncedAccounts);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @override
  Stream<DataResult<AccountEntity>> createAccount(AccountRequest$Create request) async* {
    await _syncEvents();
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield DataResult.offline(data: localAccount);
    final restAccount = await _createAccountWithSync(localAccount);
    yield DataResult.online(data: restAccount);
  }

  Future<AccountEntity> _createAccountWithSync(AccountEntity account) async {
    try {
      return await handleWithSync<AccountEntity>(
        method: () async {
          final request =
              AccountRequest$Create(name: account.name, balance: account.balance, currency: account.currency);
          final restAccount$Dto = await _accountsNetworkDataSource.createAccount(request);
          final restAccount = AccountEntity.merge(restAccount$Dto, account.id);
          final syncedAccount = await _accountsLocalDataSource.syncAccount(restAccount);
          return syncedAccount;
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction.create(
            createdAt: nowUtc,
            updatedAt: nowUtc,
            data: account,
          );
          await _accountEventsSyncDataSource.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  @override
  Stream<DataResult<AccountEntity>> updateAccount(AccountRequest$Update request) async* {
    await _syncEvents();
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield DataResult.offline(data: localAccount);
    final restAccount = await _updateAccountWithSync(localAccount);
    yield DataResult.online(data: restAccount);
  }

  Future<AccountEntity> _updateAccountWithSync(AccountEntity account) async {
    try {
      return handleWithSync<AccountEntity>(
        method: () async {
          final request = AccountRequest$Update(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
          );
          final restAccount$Dto = await _accountsNetworkDataSource.updateAccount(request);
          final restAccount = AccountEntity.merge(restAccount$Dto, account.id);
          final syncedAccount = await _accountsLocalDataSource.syncAccount(restAccount);
          return syncedAccount;
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction.update(
            createdAt: nowUtc,
            updatedAt: nowUtc,
            data: account,
          );
          await _accountEventsSyncDataSource.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  @override
  Stream<DataResult<void>> deleteAccount(int accountId) async* {
    await _syncEvents();
    await _deleteAccountWithSync(accountId);
    yield const DataResult.online(data: null);
    await _accountsLocalDataSource.deleteAccount(accountId);
    yield const DataResult.offline(data: null);
  }

  Future<void> _deleteAccountWithSync(int accountId) async {
    try {
      return await handleWithSync<void>(
        method: () async {
          final accountToDelete = await _accountsLocalDataSource.fetchAccount(accountId);
          final remoteId = accountToDelete?.remoteId;
          if (remoteId == null) return;
          return _accountsNetworkDataSource.deleteAccount(remoteId);
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction<AccountEntity>.delete(
            dataId: accountId,
            createdAt: nowUtc,
            updatedAt: nowUtc,
          );
          await _accountEventsSyncDataSource.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  // TODO(frosterlolz): много грязи! нужно рефачить
  @override
  Stream<DataResult<AccountDetailEntity>> getAccountDetail(int id) async* {
    await _syncEvents();
    final account$Local = await _accountsLocalDataSource.fetchAccount(id);
    final remoteId = account$Local?.remoteId;
    if (account$Local != null) {
      if (remoteId == null) {
        await _accountsLocalDataSource.deleteAccount(account$Local.id);
        throw StateError('Account has no remote id after sync');
      }
      final accountTransactions = await _transactionsLocalStorage.fetchTransactions(account$Local.id);
      final categories = await _transactionsLocalStorage.fetchTransactionCategories();
      final incomeCategories = categories.where((category) => category.isIncome);
      final expenseCategories = categories.where((category) => !category.isIncome);
      final incomeStats = _calculateFromCategories(incomeCategories, accountTransactions);
      final expenseStats = _calculateFromCategories(expenseCategories, accountTransactions);
      final accountDetails$Local = AccountDetailEntity.fromLocalSource(
        account$Local,
        incomeStats: incomeStats.toList(),
        expenseStats: expenseStats.toList(),
      );
      yield DataResult.offline(data: accountDetails$Local);
    } else {
      // TODO(frosterlolz): можно дописать возможность фетчить по remoteId
      throw StateError('Account not found');
    }
    try {
      final accountDetails$RestDto = await _accountsNetworkDataSource.getAccount(remoteId);
      final syncedAccount =
          await _accountsLocalDataSource.syncAccountDetails(accountDetails$RestDto, id: account$Local.id);
      final accountDetails$Synced = AccountDetailEntity.fromLocalSource(
        syncedAccount,
        incomeStats: accountDetails$RestDto.incomeStats,
        expenseStats: accountDetails$RestDto.expenseStats,
      );
      yield DataResult.online(data: accountDetails$Synced);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @override
  Stream<DataResult<AccountHistory>> getAccountHistory(int accountId) async* {
    await _syncEvents();
    final account$Local = await _accountsLocalDataSource.fetchAccount(accountId);
    if (account$Local != null) {
      // TODO(frosterlolz): на данном этапе не актульные данные
      const AccountHistory? history = null;
      final accountHistory$Local =
          AccountHistory.fromLocalSource(account$Local, history: history == null ? [] : history.history);
      yield DataResult.offline(data: accountHistory$Local);
    }
    try {
      final accountHistory$RestDto = await _accountsNetworkDataSource.getAccountHistory(accountId);
      final account =
          await _accountsLocalDataSource.syncAccountHistory(account$Local?.id, accountHistory: accountHistory$RestDto);
      final accountHistorySynced = AccountHistory.fromLocalSource(
        account,
        history: accountHistory$RestDto.history.map(AccountHistoryItem.fromDto).toList(),
      );
      yield DataResult.online(data: accountHistorySynced);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @Deprecated('For testing only, now REST API is used')
  Future<void> generateMockData() async {
    final accountsCount = await _accountsLocalDataSource.fetchAccountsCount();
    if (accountsCount > 0) return;
    final requests = List.generate(
      10,
      (index) => AccountRequest.create(
        name: 'Account $index',
        balance: '100$index.00',
        currency: Currency.rub,
      ),
    ).cast<AccountRequest$Create>();
    for (final request in requests) {
      await createAccount(request).first;
    }
  }

  Future<void> _syncEvents() async {
    final events = await _accountEventsSyncDataSource.fetchEvents();
    for (final event in events) {
      switch (event) {
        case SyncAction$Create(:final data):
          await _createAccountWithSync(data);
        case SyncAction$Update(:final data):
          await _updateAccountWithSync(data);
        case SyncAction$Delete(:final dataId):
          await _deleteAccountWithSync(dataId);
      }
    }
  }

  // TODO(frosterlolz): временный метод
  Iterable<TransactionCategoryStat> _calculateFromCategories(
    Iterable<TransactionCategory> categories,
    List<TransactionEntity> transactions,
  ) {
    final transactionStats = categories.map((category) {
      final amountNum = transactions.fold<num>(0.0, (previousValue, element) {
        final transactionAmountNum = category.id == element.categoryId ? element.amount.amountToNum() : 0.0;
        return previousValue + transactionAmountNum;
      });

      return TransactionCategoryStat.fromTableItem(category, amount: amountNum.toStringAsFixed(3));
    });

    return transactionStats;
  }
}
