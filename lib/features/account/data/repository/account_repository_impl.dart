import 'package:collection/collection.dart';
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
  final Map<int, AccountHistory> _accountHistories = {};

  @override
  Stream<Iterable<AccountEntity>> getAccounts() async* {
    final localAccounts = await _accountsLocalDataSource.fetchAccounts();
    yield localAccounts;
    final networkAccounts = await _accountsNetworkDataSource.getAccounts();
    if (!const ListEquality<AccountEntity>().equals(localAccounts, networkAccounts)) {
      _accountsLocalDataSource.syncAccounts(networkAccounts).ignore();
    }
    yield networkAccounts;
  }

  @override
  Stream<AccountEntity> createAccount(AccountRequest$Create request) async* {
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield localAccount;
    final restAccount = await _accountsNetworkDataSource.createAccount(request);
    if (localAccount != restAccount) {
      _accountsLocalDataSource.syncAccount(restAccount).ignore();
    }
    yield restAccount;
  }

  @override
  Stream<AccountEntity> updateAccount(AccountRequest$Update request) async* {
    final localAccount = await _accountsLocalDataSource.updateAccount(request);
    yield localAccount;
    final restAccount = await _accountsNetworkDataSource.updateAccount(request);
    if (localAccount != restAccount) {
      _accountsLocalDataSource.syncAccount(restAccount).ignore();
    }
    yield restAccount;
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    await _accountsLocalDataSource.deleteAccount(accountId);
    await _accountsNetworkDataSource.deleteAccount(accountId);
  }

  @override
  Future<AccountDetailEntity> getAccountDetail(int id) async {
    final account = await _accountsLocalDataSource.fetchAccount(id);
    if (account == null) {
      throw Exception('Account not found');
    }
    final accountTransactions = await _transactionsLocalStorage.fetchTransactions(account.id);
    final categories = await _transactionsLocalStorage.fetchTransactionCategories();
    final incomeCategories = categories.where((category) => category.isIncome);
    final expenseCategories = categories.where((category) => !category.isIncome);

    final incomeStats = _calculateFromCategories(incomeCategories, accountTransactions);
    final expenseStats = _calculateFromCategories(expenseCategories, accountTransactions);

    return AccountDetailEntity.fromLocalSource(
      account,
      incomeStats: incomeStats.toList(),
      expenseStats: expenseStats.toList(),
    );
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

  @override
  Future<AccountHistory> getAccountHistory(int accountId) async {
    final account = await _accountsLocalDataSource.fetchAccount(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }
    // TODO(frosterlolz): на данном этапе не актульные данные
    final history = _accountHistories[accountId];

    return AccountHistory.fromLocalSource(account, history: history == null ? [] : history.history);
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
}
