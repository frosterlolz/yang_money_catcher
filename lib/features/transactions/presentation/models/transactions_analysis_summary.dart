import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

@immutable
class TransactionsAnalysisSummary {
  const TransactionsAnalysisSummary(this.items);

  final List<TransactionAnalysisSummaryItem> items;

  double amountPercentage(TransactionCategory category) {
    final transactionSummaryItem = items.firstWhereOrNull((element) => element.transactionCategory == category);
    if (transactionSummaryItem == null) return 0.0;

    return transactionSummaryItem.totalAmount /
        items.fold(0.0, (previousValue, element) => previousValue + element.totalAmount) *
        100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionsAnalysisSummary &&
          runtimeType == other.runtimeType &&
          const ListEquality<TransactionAnalysisSummaryItem>().equals(items, other.items);

  @override
  int get hashCode => items.hashCode;
}

@immutable
class TransactionAnalysisSummaryItem {
  factory TransactionAnalysisSummaryItem({
    required TransactionCategory transactionCategory,
    required List<TransactionDetailEntity> transactions,
  }) {
    final amount = transactions.fold(0.0, (previousValue, element) => previousValue + element.amount.amountToNum());

    return TransactionAnalysisSummaryItem._(
      transactionCategory: transactionCategory,
      transactions: transactions,
      totalAmount: amount,
    );
  }

  const TransactionAnalysisSummaryItem._({
    required this.transactionCategory,
    required this.transactions,
    required this.totalAmount,
  });

  final TransactionCategory transactionCategory;
  final List<TransactionDetailEntity> transactions;
  final double totalAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAnalysisSummaryItem &&
          runtimeType == other.runtimeType &&
          transactionCategory == other.transactionCategory &&
          const ListEquality<TransactionDetailEntity>().equals(transactions, other.transactions) &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode => Object.hash(transactionCategory, transactions, totalAmount);
}
