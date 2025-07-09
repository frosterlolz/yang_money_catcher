import 'package:collection/collection.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
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

final class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountsNetworkDataSource accountsNetworkDataSource,
    required AccountsLocalDataSource accountsLocalStorage,
    required TransactionsLocalDataSource transactionsLocalStorage,
  })  : _accountsNetworkDataSource = accountsNetworkDataSource,
        _accountsLocalDataSource = accountsLocalStorage,
        _transactionsLocalStorage = transactionsLocalStorage;

  final AccountsNetworkDataSource _accountsNetworkDataSource;
  final AccountsLocalDataSource _accountsLocalDataSource;
  final TransactionsLocalDataSource _transactionsLocalStorage;

  final List<SyncAction<TransactionEntity>> _actions = [];

  @override
  Stream<DataResult<Iterable<AccountEntity>>> getAccounts() async* {
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
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield DataResult.offline(data: localAccount);
    final restAccount = await _accountsNetworkDataSource.createAccount(request);
    if (localAccount != restAccount) {
      _accountsLocalDataSource.syncAccount(restAccount).ignore();
    }
    yield DataResult.online(data: restAccount);
  }

  @override
  Stream<DataResult<AccountEntity>> updateAccount(AccountRequest$Update request) async* {
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield DataResult.offline(data: localAccount);
    final restAccount = await _accountsNetworkDataSource.updateAccount(request);
    if (localAccount != restAccount) {
      _accountsLocalDataSource.syncAccount(restAccount).ignore();
    }
    yield DataResult.online(data: restAccount);
  }

  @override
  Stream<DataResult<void>> deleteAccount(int accountId) async* {
    await _accountsLocalDataSource.deleteAccount(accountId);
    yield const DataResult.offline(data: null);
    await _accountsNetworkDataSource.deleteAccount(accountId);
    yield const DataResult.online(data: null);
  }

  // TODO(frosterlolz): много грязи! нужно рефачить
  @override
  Stream<DataResult<AccountDetailEntity>> getAccountDetail(int id) async* {
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
    final account$Local = await _accountsLocalDataSource.fetchAccount(accountId);
    if (account$Local != null) {
      // TODO(frosterlolz): на данном этапе не актульные данные
      const AccountHistory? history = null;
      final accountHistory$Local =
          AccountHistory.fromLocalSource(account$Local, history: history == null ? [] : history.history);
      yield DataResult.offline(data: accountHistory$Local);
    }
    final accountHistory$Rest = await _accountsNetworkDataSource.getAccountHistory(accountId);
    yield DataResult.online(data: accountHistory$Rest);
  }

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

  void _addToSyncEvents(SyncAction<TransactionEntity> event) {
    final index = _actions.indexWhere((a) => a.id == event.id);
    if (index == -1) {
      _actions.add(event);
      return;
    }

    final existing = _actions[index];
    final merged = existing.merge(event);

    if (merged == null) {
      _actions.removeAt(index);
    } else {
      _actions[index] = merged;
    }
  }
}
