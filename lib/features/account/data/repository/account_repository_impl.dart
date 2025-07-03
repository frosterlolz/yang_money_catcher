import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_storage.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category_stat.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_drift_storage.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

final class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required AccountsLocalStorage accountsLocalStorage,
    required TransactionsDriftStorage transactionsLocalStorage,
  })  : _accountsLocalStorage = accountsLocalStorage,
        _transactionsLocalStorage = transactionsLocalStorage;

  final AccountsLocalStorage _accountsLocalStorage;
  final TransactionsDriftStorage _transactionsLocalStorage;
  final Map<int, AccountHistory> _accountHistories = {};

  @override
  Future<AccountEntity> createAccount(AccountRequest$Create request) async {
    final createdId = await _accountsLocalStorage.updateAccount(request);
    final createdAccountItem = await _accountsLocalStorage.fetchAccount(createdId);
    if (createdAccountItem == null) {
      throw Exception('Error while fetching fresh created account');
    }
    return AccountEntity.fromTableItem(createdAccountItem);
  }

  @override
  Future<AccountEntity> updateAccount(AccountRequest$Update request) async {
    await _accountsLocalStorage.updateAccount(request);
    final updated = await _accountsLocalStorage.fetchAccount(request.id);
    if (updated == null) {
      throw Exception('Error while fetching fresh updated account');
    }

    return AccountEntity.fromTableItem(updated);
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    await _accountsLocalStorage.deleteAccount(accountId);
  }

  @override
  Future<Iterable<AccountEntity>> getAccounts() async {
    final accounts = await _accountsLocalStorage.fetchAccounts();
    return accounts.map(AccountEntity.fromTableItem);
  }

  @override
  Future<AccountDetailEntity> getAccountDetail(int id) async {
    final account = await _accountsLocalStorage.fetchAccount(id);
    if (account == null) {
      throw Exception('Account not found');
    }
    final accountTransactions = await _transactionsLocalStorage.fetchTransactions(account.id);
    final categories = await _transactionsLocalStorage.fetchTransactionCategories();
    final incomeCategories = categories.where((category) => category.isIncome);
    final expenseCategories = categories.where((category) => !category.isIncome);

    final incomeStats = _calculateFromCategories(incomeCategories, accountTransactions);
    final expenseStats = _calculateFromCategories(expenseCategories, accountTransactions);

    return AccountDetailEntity.fromTableItem(
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
    // TODO(frosterlolz): на данном этапе не актульные данные
    final history = _accountHistories[accountId];
    if (history == null) {
      throw Exception('Account history not found');
    }
    return history;
  }

  Future<void> generateMockData() async {
    final accountsCount = await _accountsLocalStorage.fetchAccountsCount();
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
      await createAccount(request);
    }
  }
}
