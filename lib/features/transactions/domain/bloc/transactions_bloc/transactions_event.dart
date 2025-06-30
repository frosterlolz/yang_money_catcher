part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsEvent with _$TransactionsEvent {
  const TransactionsEvent._();

  const factory TransactionsEvent.load(TransactionFilters filters) = _Load;
}

final class _Update extends TransactionsEvent {
  _Update({
    required this.transactionId,
    required this.transaction,
  }) : super._();

  final int transactionId;
  final TransactionDetailEntity? transaction;
}
