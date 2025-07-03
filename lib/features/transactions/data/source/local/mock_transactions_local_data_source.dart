import 'dart:async';

import 'package:collection/collection.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

/// [int] -> id транзакции, [TransactionDetailEntity] -> измененная/новая транзакция. Если Null- значит транзакция удалена
typedef TransactionChangeEntry = MapEntry<int, TransactionDetailEntity?>;

base class MockTransactionsLocalDataSource {
  @Deprecated('Use [TransactionsDriftStorage] instead.')
  MockTransactionsLocalDataSource()
      : _transactions = List.empty(growable: true),
        _transactionChangesController = StreamController.broadcast();

  final List<TransactionDetailEntity> _transactions;
  final StreamController<TransactionChangeEntry> _transactionChangesController;
  Future<void> _lastOp = Future.value();

  Stream<TransactionChangeEntry> transactionChangesStream() => _transactionChangesController.stream;

  Future<List<TransactionDetailEntity>> getTransactions(TransactionFilters filters) async {
    final result = _transactions.where((tx) {
      final matchesAccount = tx.account.id == filters.accountId;
      final matchesStart = filters.startDate == null || !tx.transactionDate.isBefore(filters.startDate!);
      final matchesEnd = filters.endDate == null || !tx.transactionDate.isAfter(filters.endDate!);
      final matchesIncomeFlag = filters.isIncome == null || tx.category.isIncome == filters.isIncome;
      return matchesAccount && matchesStart && matchesEnd && matchesIncomeFlag;
    });
    return result.toList();
  }

  Future<TransactionDetailEntity?> getTransaction(int id) async => _queueOp(() async {
        // Имитация микро-задержки
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _transactions.firstWhereOrNull((tx) => tx.id == id);
      });

  Future<TransactionEntity> saveTransaction(TransactionDetailEntity transaction) async {
    final updated = await updateTransaction(transaction, true);

    return TransactionEntity(
      id: updated.id,
      accountId: updated.account.id,
      categoryId: updated.category.id,
      amount: updated.amount,
      transactionDate: updated.transactionDate,
      comment: updated.comment,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    );
  }

  Future<TransactionDetailEntity> updateTransaction(
    TransactionDetailEntity transaction, [
    bool ignoreUniqueId = false,
  ]) async =>
      _queueOp(() async {
        final overlapIndex = _transactions.indexWhere((e) => e.id == transaction.id);
        // Имитация микро-задержки
        await Future<void>.delayed(const Duration(milliseconds: 10));
        if (overlapIndex != -1) {
          _transactions[overlapIndex] = transaction;
        } else {
          // Попытка обновить несуществующую транзакцию
          if (!ignoreUniqueId) throw Exception('Transaction not found');
          _transactions.add(transaction);
        }
        _transactionChangesController.add(MapEntry(transaction.id, transaction));

        return transaction;
      });

  Future<bool> deleteTransaction(int id) async => _queueOp(() async {
        final overlapIndex = _transactions.indexWhere((e) => e.id == id);
        if (overlapIndex == -1) return false;
        // Имитация микро-задержки
        await Future<void>.delayed(const Duration(milliseconds: 10));
        _transactions.removeAt(overlapIndex);
        _transactionChangesController.add(MapEntry(id, null));
        return true;
      });

  Future<void> dispose() => _transactionChangesController.close();

  Future<T> _queueOp<T>(Future<T> Function() op) {
    final current = _lastOp;
    final completer = Completer<T>();

    _lastOp = current.then((_) => op().then(completer.complete).catchError(completer.completeError));

    return completer.future;
  }

  Future<Iterable<TransactionCategory>> getTransactionCategories() async =>
      throw UnimplementedError('Not actual data source for now, check constructor deprecation comment');
}
