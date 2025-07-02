part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsState with _$TransactionsState {
  const TransactionsState._();

  const factory TransactionsState.idle(UnmodifiableListView<TransactionDetailEntity> transactions) =
      TransactionsState$Idle;
  const factory TransactionsState.processing(UnmodifiableListView<TransactionDetailEntity>? transactions) =
      TransactionsState$Processing;
  const factory TransactionsState.error(
    UnmodifiableListView<TransactionDetailEntity>? transactions, {
    required Object error,
  }) = TransactionsState$Error;

  num get totalAmount =>
      (transactions?.fold(0.0, (sum, transaction) => sum + transaction.amount.amountToNum()) ?? 0.0).smartTruncate();
}
