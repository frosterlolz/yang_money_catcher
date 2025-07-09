import 'package:collection/collection.dart';
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
      final networkAccounts = await _accountsNetworkDataSource.getAccounts();
      if (!const ListEquality<AccountEntity>().equals(localAccounts, networkAccounts)) {
        _accountsLocalDataSource.syncAccounts(networkAccounts).ignore();
      }
      yield DataResult.online(data: networkAccounts);
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
          final restAccount = await _accountsNetworkDataSource.createAccount(request);
          _accountsLocalDataSource.syncAccount(restAccount).ignore();
          return restAccount;
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
          final restAccount = await _accountsNetworkDataSource.updateAccount(request);
          _accountsLocalDataSource.syncAccount(restAccount).ignore();

          return restAccount;
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
        method: () => _accountsNetworkDataSource.deleteAccount(accountId),
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
    final account = await _accountsLocalDataSource.fetchAccount(id);
    if (account != null) {
      final accountTransactions = await _transactionsLocalStorage.fetchTransactions(account.id);
      final categories = await _transactionsLocalStorage.fetchTransactionCategories();
      final incomeCategories = categories.where((category) => category.isIncome);
      final expenseCategories = categories.where((category) => !category.isIncome);
      final incomeStats = _calculateFromCategories(incomeCategories, accountTransactions);
      final expenseStats = _calculateFromCategories(expenseCategories, accountTransactions);
      final accountDetails$Local = AccountDetailEntity.fromLocalSource(
        account,
        incomeStats: incomeStats.toList(),
        expenseStats: expenseStats.toList(),
      );
      yield DataResult.offline(data: accountDetails$Local);
      try {
        final accountDetails$Rest = await _accountsNetworkDataSource.getAccount(id);
        yield DataResult.online(data: accountDetails$Rest);
      } on StructuredBackendException catch (e, s) {
        final appException = AppException$Simple.fromStructuredException(e.error);
        Error.throwWithStackTrace(appException, s);
      }
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
      final accountHistory$Rest = await _accountsNetworkDataSource.getAccountHistory(accountId);
      yield DataResult.online(data: accountHistory$Rest);
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
