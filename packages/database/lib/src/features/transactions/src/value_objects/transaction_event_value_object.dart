import 'package:database/database.dart';

class TransactionEventValueObject {
  factory TransactionEventValueObject({
    required TransactionEventItem event,
    required TransactionItem? transaction,
  }) =>
      TransactionEventValueObject._(
        event: event,
        transaction: transaction,
      );

  const TransactionEventValueObject._({
    required this.event,
    required this.transaction,
  });

  final TransactionEventItem event;
  final TransactionItem? transaction;
}
