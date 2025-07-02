import 'package:database/database.dart';

class TransactionDetailedValueObject {
  factory TransactionDetailedValueObject({
    required TransactionItem transaction,
    required TransactionCategoryItem? category,
    required AccountItem? account,
  }) {
    // TODO(frosterlolz): реализовать через кастомные ошибки
    if (category == null) {
      throw StateError('TransactionDetailedValueObject creation failed: category is missing');
    }
    if (account == null) {
      throw StateError('TransactionDetailedValueObject creation failed: account is missing');
    }
    return TransactionDetailedValueObject._(
      transaction: transaction,
      account: account,
      category: category,
    );
  }

  const TransactionDetailedValueObject._({
    required this.transaction,
    required this.category,
    required this.account,
  });

  final TransactionItem transaction;
  final TransactionCategoryItem category;
  final AccountItem account;
}
