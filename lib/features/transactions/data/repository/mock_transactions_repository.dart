import 'dart:math';

import 'package:async/async.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class MockTransactionsRepository implements TransactionsRepository {
  MockTransactionsRepository(this._transactionsLocalDataSource) : _transactionsLoaderCache = AsyncCache.ephemeral();

  final TransactionsLocalDataSource _transactionsLocalDataSource;
  final AsyncCache<List<TransactionDetailEntity>> _transactionsLoaderCache;

  @override
  Stream<TransactionChangeEntry> transactionChangesStream({int? id, TransactionFilters? filters}) {
    // фетчим только по id, игнорируя фильтры
    if (id != null) return _transactionsLocalDataSource.transactionChangesStream().where((entry) => entry.key == id);
    if (filters == null) return _transactionsLocalDataSource.transactionChangesStream();
    return _transactionsLocalDataSource.transactionChangesStream().where((entry) {
      final transaction = entry.value;
      // фильтры не распространяются на удаление транзакции
      if (transaction == null) return true;
      // фильтр по дате
      final startMatchesFilter = filters.startDate == null || !transaction.transactionDate.isBefore(filters.startDate!);
      final endMatchesFilter = filters.endDate == null || !transaction.transactionDate.isAfter(filters.endDate!);
      final isIncomeMatchesFilter = filters.isIncome == null || transaction.category.isIncome == filters.isIncome;
      return startMatchesFilter && endMatchesFilter && isIncomeMatchesFilter;
    });
  }

  @override
  Future<Iterable<TransactionDetailEntity>> getTransactions(TransactionFilters filters) async {
    final transactions = await _transactionsLoaderCache.fetch(
      () async {
        final transactions = await _transactionsLocalDataSource.getTransactions(filters);
        return transactions.toList();
      },
    );
    return transactions;
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionRequest$Create request) async {
    final categories = await _transactionsLocalDataSource.getTransactionCategories();
    final account = AccountBrief(id: request.accountId, name: 'Mock Account', balance: '12.12', currency: Currency.rub);
    final dtNow = DateTime.now();
    final newTransaction = TransactionDetailEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      account: account,
      category: categories.firstWhere((category) => category.id == request.categoryId),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: dtNow,
      updatedAt: dtNow,
    );

    return _transactionsLocalDataSource.saveTransaction(newTransaction);
  }

  @override
  Future<TransactionDetailEntity> updateTransaction(TransactionRequest$Update request) async {
    final existingTransaction = await _transactionsLocalDataSource.getTransaction(request.id);
    if (existingTransaction == null) throw Exception('Transaction not found');
    final updated = existingTransaction.copyWith(
      amount: request.amount,
      comment: request.comment ?? existingTransaction.comment,
      updatedAt: DateTime.now(),
      transactionDate: request.transactionDate,
    );

    return _transactionsLocalDataSource.updateTransaction(updated);
  }

  @override
  Future<void> deleteTransaction(int id) async => _transactionsLocalDataSource.deleteTransaction(id);

  @override
  Future<TransactionDetailEntity?> getTransaction(int id) async => _transactionsLocalDataSource.getTransaction(id);

  Future<void> generateMockData() async {
    final random = Random();
    final categories = await _transactionsLocalDataSource.getTransactionCategories();
    final requests = List.generate(
      20,
      (index) {
        final categoryIndex = random.nextInt(categories.length);
        final amountFractionalPart = random.nextInt(2) > 0 ? '00' : '50';
        final transactionHour = random.nextInt(24);
        final transactionMinute = random.nextInt(60);
        final transactionDate = DateTime.now()
            .copyWith(hour: transactionHour, minute: transactionMinute)
            .subtract(Duration(days: random.nextInt(2)));
        return TransactionRequest.create(
          accountId: 1,
          amount: '10000.$amountFractionalPart',
          categoryId: categories.elementAt(categoryIndex).id,
          comment: 'Comment at $index',
          transactionDate: transactionDate,
        );
      },
    ).cast<TransactionRequest$Create>();
    for (final request in requests) {
      await createTransaction(request);
    }
  }

  @override
  Future<Iterable<TransactionCategory>> getTransactionCategories() async =>
      _transactionsLocalDataSource.getTransactionCategories();
}
