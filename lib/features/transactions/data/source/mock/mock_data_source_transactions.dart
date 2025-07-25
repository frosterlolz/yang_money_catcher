import 'dart:async';

import 'package:collection/collection.dart';
import 'package:yang_money_catcher/features/transaction_categories/data/source/mock_transaction_categories.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/entity.dart';

mixin MockDataSource$Transactions {
  final List<TransactionCategory> _transactionCategories =
      transactionCategoriesJson.map(TransactionCategory.fromJson).toList();
  final List<TransactionEntity> _transactions = List.empty(growable: true);

  final StreamController<List<TransactionEntity>> _transactionsListController = StreamController.broadcast();
  final StreamController<(TransactionEntity transaction, bool isDeleted)> _transactionChangesController =
      StreamController.broadcast();

  void dispose$Transactions() {
    _transactionsListController.close();
    _transactionChangesController.close();
  }

  // <----- Transaction Categories ----->

  void insertTransactionCategories(List<TransactionCategory> transactionCategories) {
    _transactionCategories
      ..clear()
      ..addAll(transactionCategories);
  }

  List<TransactionCategory> get transactionCategories => List.from(_transactionCategories, growable: false);

  TransactionCategory? findCategory(int id) => transactionCategories.firstWhereOrNull((e) => e.id == id);

  // <----- Transactions ----->

  List<TransactionEntity> get transactions => List.from(_transactions, growable: false);

  void insertTransactions(List<TransactionEntity> transactions) {
    final oldTransactions = this.transactions;
    _transactions
      ..clear()
      ..addAll(transactions);
    final newTransactions = this.transactions;
    _transactionsListController.add(newTransactions);
    for (final oldTransaction in oldTransactions) {
      final updatedTransaction = newTransactions
          .firstWhereOrNull((newTx) => newTx.id == oldTransaction.id || newTx.remoteId == oldTransaction.remoteId);
      if (updatedTransaction == null) {
        _transactionChangesController.add((oldTransaction, true));
      } else {
        if (oldTransaction == updatedTransaction) continue;
        _transactionChangesController.add((updatedTransaction, false));
      }
    }
  }

  TransactionEntity? findTransaction(int id) => transactions.firstWhereOrNull((e) => e.id == id);

  List<TransactionEntity> fetchTransactionsWithFilters(TransactionFilters filters) =>
      transactions.where((transaction) => filterTransaction(transaction, filters)).toList(growable: false);

  int upsertTransaction(TransactionRequest request) {
    final dtNow = DateTime.now();
    switch (request) {
      case TransactionRequest$Create():
        final newId = DateTime.now().millisecondsSinceEpoch;
        final tx = TransactionEntity(
          id: newId,
          remoteId: null,
          accountId: request.accountId,
          categoryId: request.categoryId,
          amount: request.amount,
          transactionDate: request.transactionDate,
          comment: request.comment,
          createdAt: dtNow,
          updatedAt: dtNow,
        );
        _transactions.add(tx);
        _transactionsListController.add(transactions);
        _transactionChangesController.add((tx, false));
        return newId;
      case TransactionRequest$Update():
        final foundIndex = transactions.indexWhere((e) => e.remoteId == request.id);
        if (foundIndex == -1) throw StateError('Transaction not found');
        _transactions[foundIndex] = transactions[foundIndex].copyWith(
          accountId: request.accountId,
          categoryId: request.categoryId,
          amount: request.amount,
          transactionDate: request.transactionDate,
          comment: request.comment,
          updatedAt: dtNow,
        );

        final updatedTx = _transactions[foundIndex];
        _transactionsListController.add(transactions);
        _transactionChangesController.add((updatedTx, false));
        return updatedTx.id;
    }
  }

  void deleteTransaction(int id) {
    final transaction = findTransaction(id);
    if (transaction == null) return;
    _transactions.remove(transaction);
    _transactionsListController.add(transactions);
    _transactionChangesController.add((transaction, true));
  }

  bool filterTransaction(TransactionEntity transaction, TransactionFilters filters) {
    if (transaction.accountId != filters.accountId) return false;
    if (filters.startDate case final DateTime startDate when transaction.transactionDate.isBefore(startDate)) {
      return false;
    }
    if (filters.endDate case final DateTime endDate when transaction.transactionDate.isAfter(endDate)) {
      return false;
    }
    return true;
  }

  Stream<List<TransactionEntity>> transactionsListChanges(TransactionFilters filters) =>
      _transactionsListController.stream.map(
        (txList) => txList.where((tx) => filterTransaction(tx, filters)).toList(),
      );

  Stream<(TransactionEntity transaction, bool isDeleted)> transactionChanges(int id) =>
      _transactionChangesController.stream;
}
