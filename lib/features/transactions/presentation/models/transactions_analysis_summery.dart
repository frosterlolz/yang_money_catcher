import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

@immutable
class TransactionsAnalysisSummery {
  const TransactionsAnalysisSummery(this.items);

  final List<TransactionAnalysisSummeryItem> items;

  double amountPercentage(TransactionCategory category) {
    final transactionSummeryItem = items.firstWhereOrNull((element) => element.transactionCategory == category);
    if (transactionSummeryItem == null) return 0.0;

    return transactionSummeryItem.totalAmount /
        items.fold(0.0, (previousValue, element) => previousValue + element.totalAmount) *
        100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionsAnalysisSummery &&
          runtimeType == other.runtimeType &&
          const ListEquality<TransactionAnalysisSummeryItem>().equals(items, other.items);

  @override
  int get hashCode => items.hashCode;
}

@immutable
class TransactionAnalysisSummeryItem {
  factory TransactionAnalysisSummeryItem({
    required TransactionCategory transactionCategory,
    required List<TransactionDetailEntity> transactions,
  }) {
    final amount = transactions.fold(0.0, (previousValue, element) => previousValue + element.amount.amountToNum());

    return TransactionAnalysisSummeryItem._(
      transactionCategory: transactionCategory,
      transactions: transactions,
      totalAmount: amount,
    );
  }

  const TransactionAnalysisSummeryItem._({
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
      other is TransactionAnalysisSummeryItem &&
          runtimeType == other.runtimeType &&
          transactionCategory == other.transactionCategory &&
          const ListEquality<TransactionDetailEntity>().equals(transactions, other.transactions) &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode => Object.hash(transactionCategory, transactions, totalAmount);
}
