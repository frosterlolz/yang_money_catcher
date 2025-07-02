part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsEvent with _$TransactionsEvent {
  const TransactionsEvent._();

  const factory TransactionsEvent.load(TransactionFilters filters) = _Load;
}

final class _Update extends TransactionsEvent {
  _Update(this.transactions) : super._();

  final List<TransactionDetailEntity> transactions;
}
