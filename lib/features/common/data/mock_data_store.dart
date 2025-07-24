import 'dart:async';

import 'package:collection/collection.dart';
import 'package:yang_money_catcher/features/account/data/source/mock/mock_data_source_accounts.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transactions/data/source/mock/mock_data_source_transactions.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/entity.dart';

/// Mock Storage implementation. Used for testing
final class MockDataStore with MockDataSource$Accounts, MockDataSource$Transactions {
  MockDataStore();

  void dispose() {
    dispose$Transactions();
    dispose$Accounts();
  }

  Future<TransactionDetailEntity?> fetchTransaction(int id) async {
    final foundTransaction = findTransaction(id);
    if (foundTransaction == null) return null;

    return _createTransactionDetailsFromEntity(foundTransaction);
  }

  Future<List<TransactionDetailEntity>> fetchTransactionsDetailed(TransactionFilters filters) async {
    final nullableTransactions = await fetchTransactionsWithFilters(filters)
        .map(_createTransactionDetailsFromEntity)
        .toList(growable: false)
        .wait;

    return nullableTransactions.nonNulls.where((transaction) {
      if (filters.isIncome != null && transaction.category.isIncome != filters.isIncome) return false;
      return true;
    }).toList(growable: false);
  }

  Stream<TransactionDetailEntity?> transactionDetailedChanges(int id) =>
      transactionChanges(id).where((e) => e.$1.id == id).asyncMap((e) async {
        final isDeleted = e.$2;
        return isDeleted ? null : await _createTransactionDetailsFromEntity(e.$1);
      });

  Stream<List<TransactionDetailEntity>> transactionDetailedListChanges(TransactionFilters filters) =>
      transactionsListChanges(filters).asyncMap((txList) async {
        final detailedList = await txList.map(_createTransactionDetailsFromEntity).wait;
        return detailedList
            .where((tx) => filters.isIncome == null ? true : tx?.category.isIncome == filters.isIncome)
            .nonNulls
            .toList();
      });

  Future<TransactionDetailEntity?> _createTransactionDetailsFromEntity(TransactionEntity transaction) async {
    final category = transactionCategories.firstWhereOrNull((e) => e.id == transaction.categoryId);
    if (category == null) return null;

    final account = findAccount(transaction.accountId);
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
}
