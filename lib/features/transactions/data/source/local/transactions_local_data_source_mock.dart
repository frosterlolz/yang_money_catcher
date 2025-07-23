import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source_mock.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

final class TransactionsLocalDataSource$Mock implements TransactionsLocalDataSource {
  TransactionsLocalDataSource$Mock(this._accountsLocalDataSource)
      : _categories = const [],
        _transactions = const [],
        _transactionsListController = StreamController.broadcast(),
        _transactionChangesController = StreamController.broadcast();

  final List<TransactionCategory> _categories;
  final List<TransactionEntity> _transactions;
  final StreamController<List<TransactionDetailEntity>> _transactionsListController;
  final StreamController<(TransactionDetailEntity transaction, bool isDeleted)> _transactionChangesController;

  final AccountsLocalDataSource$Mock _accountsLocalDataSource;

  @override
  Future<TransactionEntity?> deleteTransaction(int id) async {
    final foundTransaction = _transactions.firstWhereOrNull((e) => e.id == id);
    if (foundTransaction == null) return null;
    _transactions.remove(foundTransaction);
    unawaited(_notifyListChanges());
    unawaited(_notifyTransactionChange(foundTransaction, isDeleted: true));

    return foundTransaction;
  }

  @override
  Future<TransactionDetailEntity?> fetchTransaction(int id) async {
    final foundTransaction = _transactions.firstWhereOrNull((e) => e.id == id);
    if (foundTransaction == null) return null;

    return _createFromEntity(foundTransaction);
  }

  @override
  Future<List<TransactionCategory>> fetchTransactionCategories() async => List.from(_categories);

  @override
  Future<List<TransactionEntity>> fetchTransactions(int accountId) async =>
      _transactions.where((e) => e.accountId == accountId).toList(growable: false);

  @override
  Future<List<TransactionDetailEntity>> fetchTransactionsDetailed(TransactionFilters filters) async {
    final nullableTransactions = await _transactions
        .where((transaction) {
          if (transaction.accountId != filters.accountId) return false;
          if (filters.startDate case final DateTime startDate when transaction.transactionDate.isBefore(startDate)) {
            return false;
          }
          if (filters.endDate case final DateTime endDate when transaction.transactionDate.isAfter(endDate)) {
            return false;
          }
          return true;
        })
        .toList(growable: false)
        .map(_createFromEntity)
        .toList(growable: false)
        .wait;

    return nullableTransactions.nonNulls.where((transaction) {
      if (filters.isIncome != null && transaction.category.isIncome != filters.isIncome) return false;
      return true;
    }).toList(growable: false);
  }

  @override
  Future<int> getTransactionsCount() async => _transactions.length;

  @override
  Future<List<TransactionCategory>> insertTransactionCategories(List<TransactionCategory> transactionCategories) async {
    _categories
      ..clear()
      ..addAll(transactionCategories);

    unawaited(_notifyListChanges());
    return _categories.toList(growable: false);
  }

  @override
  Future<TransactionEntity> syncTransaction(TransactionEntity transaction) async {
    final foundIndex = _transactions.indexWhere((e) => e.id == transaction.id);
    if (foundIndex == -1) {
      _transactions.add(transaction);
    } else {
      _transactions[foundIndex] = transaction;
    }
    unawaited(_notifyListChanges());
    unawaited(_notifyTransactionChange(transaction, isDeleted: false));
    return transaction;
  }

  @override
  Future<TransactionDetailEntity> syncTransactionWithDetails(
    TransactionDetailsDto transactionDto, {
    required int? localId,
  }) async {
    final foundIndex = _transactions.indexWhere((e) => e.remoteId == transactionDto.id || e.id == localId);
    final newId = foundIndex == -1 ? _transactions.length : foundIndex;
    final transactionEntity = TransactionEntity(
      id: newId,
      remoteId: transactionDto.id,
      accountId: transactionDto.account.id,
      categoryId: transactionDto.category.id,
      amount: transactionDto.amount,
      transactionDate: transactionDto.transactionDate,
      comment: transactionDto.comment,
      createdAt: transactionDto.createdAt,
      updatedAt: transactionDto.updatedAt,
    );
    await syncTransaction(transactionEntity);
    _accountsLocalDataSource.syncWithBriefDto(transactionDto.account);
    final syncedTransactionDetails = await _createFromEntity(transactionEntity);

    return syncedTransactionDetails ?? (throw StateError('Error while syncTransactionWithDetails'));
  }

  @override
  Future<List<TransactionDetailEntity>> syncTransactions({
    required List<TransactionDetailEntity> localTransactions,
    required List<TransactionDetailsDto> remoteTransactions,
  }) async {
    // TODO(frosterlolz): добавить обработку уведомления аккаунта по id, если он был удален
    _transactions.clear();
    for (final transaction in remoteTransactions) {
      final synced = await syncTransactionWithDetails(transaction, localId: null);
      _transactions.add(TransactionEntity.fromDetails(synced));
    }
    final detailedTransactions = await _transactions.map(_createFromEntity).wait;
    unawaited(_notifyListChanges());
    return detailedTransactions.nonNulls.toList(growable: false);
  }

  @override
  Future<int> transactionCategoriesCount() async => _categories.length;

  @override
  Stream<TransactionDetailEntity?> transactionChanges(int id) =>
      _transactionChangesController.stream.where((e) => e.$1.id == id).map((e) => e.$2 ? null : e.$1);

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) =>
      _transactionsListController.stream;

  @override
  Future<TransactionEntity> upsertTransaction(TransactionRequest request) async {
    final dtNow = DateTime.now();
    switch (request) {
      case TransactionRequest$Create():
        final account = await _accountsLocalDataSource.fetchAccount(request.accountId);
        if (account == null) throw StateError('Account not found');
        return TransactionEntity(
          id: _transactions.length,
          remoteId: null,
          accountId: request.accountId,
          categoryId: request.categoryId,
          amount: request.amount,
          transactionDate: request.transactionDate,
          comment: request.comment,
          createdAt: dtNow,
          updatedAt: dtNow,
        );
      case TransactionRequest$Update():
        final foundIndex = _transactions.indexWhere((e) => e.remoteId == request.id);
        if (foundIndex == -1) throw StateError('Transaction not found');
        _transactions[foundIndex] = _transactions[foundIndex].copyWith(
          remoteId: request.id,
          accountId: request.accountId,
          categoryId: request.categoryId,
          amount: request.amount,
          transactionDate: request.transactionDate,
          comment: request.comment,
          updatedAt: dtNow,
        );

        unawaited(_notifyListChanges());

        return _transactions[foundIndex];
    }
  }

  Future<TransactionDetailEntity?> _createFromEntity(TransactionEntity transaction) async {
    final category = _categories.firstWhereOrNull((e) => e.id == transaction.categoryId);
    if (category == null) return null;

    final account = await _accountsLocalDataSource.fetchAccount(transaction.accountId);
    if (account == null) return null;
    final accountBrief = AccountBrief.fromEntity(account);

    return TransactionDetailEntity(
      id: transaction.id,
      remoteId: transaction.remoteId,
      account: accountBrief,
      category: category,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: transaction.comment,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  Future<void> _notifyListChanges() async {
    try {
      final detailedList = await _transactions.map(_createFromEntity).wait;
      _transactionsListController.add(detailedList.nonNulls.toList(growable: false));
    } on Object catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  Future<void> _notifyTransactionChange(TransactionEntity transaction, {required bool isDeleted}) async {
    try {
      final detailedTransaction = await _createFromEntity(transaction);
      if (detailedTransaction == null) return;
      _transactionChangesController.add((detailedTransaction, isDeleted));
    } on Object catch (e, s) {
      debugPrint('$e\n$s');
    }
  }
}
