import 'dart:math';

import 'package:async/async.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class MockTransactionsRepository implements TransactionsRepository {
  MockTransactionsRepository(this._transactionsLocalDataSource) : _transactionsLoaderCache = AsyncCache.ephemeral() {
    _generateMockData();
  }
  final TransactionsLocalDataSource _transactionsLocalDataSource;
  final AsyncCache<Iterable<TransactionDetailEntity>> _transactionsLoaderCache;

  @override
  Stream<TransactionChangeEntry> transactionChangesStream({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _transactionsLocalDataSource.transactionChangesStream().where((entry) {
        final transaction = entry.value;
        // фетчим только по id
        if (id != null && entry.key == id) return true;
        // фильтр по дате не распространяется на удаление транзакции
        if (transaction == null) return true;
        // фильтр по дате
        final startIsCorrect = startDate == null || !transaction.transactionDate.isBefore(startDate);
        final endIsCorrect = endDate == null || !transaction.transactionDate.isAfter(endDate);
        return startIsCorrect && endIsCorrect;
      });

  @override
  Future<Iterable<TransactionDetailEntity>> getTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      _transactionsLoaderCache.fetch(
        () async =>
            _transactionsLocalDataSource.getTransactions(accountId: accountId, endDate: endDate, startDate: startDate),
      );

  @override
  Future<TransactionEntity> createTransaction(TransactionRequest$Create request) async {
    final newTransaction = TransactionDetailEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      account: AccountBrief(id: request.accountId, name: 'Mock Account', balance: '12.12', currency: Currency.rub),
      category: TransactionCategory(
        id: request.categoryId,
        name: 'Mock Category',
        emoji: '📝',
        isIncome: request.categoryId.isEven,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

  Future<void> _generateMockData() async {
    final random = Random();
    final requests = List.generate(
      50,
      (index) => TransactionRequest.create(
        accountId: 1,
        amount: '10000.${index.isOdd ? 00 : 50}',
        categoryId: index.isOdd ? 1 : 2,
        comment: 'Comment at $index',
        transactionDate: DateTime.now().subtract(Duration(days: random.nextInt(2))),
      ),
    ).cast<TransactionRequest$Create>();
    for (final request in requests) {
      await createTransaction(request);
    }
  }
}
