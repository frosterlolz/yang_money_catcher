import 'dart:math';

import 'package:async/async.dart';
import 'package:yang_money_catcher/features/transaction_categories/data/source/mock_transaction_categories.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._transactionsLocalDataSource) : _transactionsLoaderCache = AsyncCache.ephemeral();

  final TransactionsLocalDataSource _transactionsLocalDataSource;
  final AsyncCache<List<TransactionDetailEntity>> _transactionsLoaderCache;

  @override
  Future<Iterable<TransactionDetailEntity>> getTransactions(TransactionFilters filters) async {
    final transactions = await _transactionsLoaderCache.fetch(
      () async {
        final transactions = await _transactionsLocalDataSource.fetchTransactionsDetailed(filters);
        return transactions.toList();
      },
    );
    return transactions;
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionRequest$Create request) async =>
      _transactionsLocalDataSource.updateTransaction(request);

  @override
  Future<TransactionDetailEntity> updateTransaction(TransactionRequest$Update request) async {
    final updatedTransaction = await _transactionsLocalDataSource.updateTransaction(request);
    final detailedTransaction = await getTransaction(updatedTransaction.id);

    return detailedTransaction ?? (throw StateError('Cannot fetch transaction after update'));
  }

  @override
  Future<void> deleteTransaction(int id) async => _transactionsLocalDataSource.deleteTransaction(id);

  @override
  Future<TransactionDetailEntity?> getTransaction(int id) async => _transactionsLocalDataSource.fetchTransaction(id);

  @override
  Future<Iterable<TransactionCategory>> getTransactionCategories() async => _transactionsLocalDataSource.fetchTransactionCategories();

  @override
  Stream<TransactionDetailEntity?> transactionChanges(int id) => _transactionsLocalDataSource.transactionChanges(id);

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) =>
      _transactionsLocalDataSource.transactionsListChanges(filters);

  Future<void> generateMockData() async {
    await _fillTransactionCategories();
    final transactionsCount = await _transactionsLocalDataSource.getTransactionsCount();
    if (transactionsCount > 0) return;
    final random = Random();
    final categories = await getTransactionCategories();
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

  Future<void> _fillTransactionCategories() async {
    final transactionCategories = await _transactionsLocalDataSource.transactionCategoriesCount();
    if (transactionCategories == 0) {
      final mockCategories = transactionCategoriesJson.map(TransactionCategory.fromJson);
      await _transactionsLocalDataSource.insertTransactionCategories(mockCategories.toList());
    }
  }
}
