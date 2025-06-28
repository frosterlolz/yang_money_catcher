part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsState with _$TransactionsState {
  const factory TransactionsState.idle(UnmodifiableListView<TransactionDetailEntity> transactions) =
      TransactionsState$Idle;
  const factory TransactionsState.processing(UnmodifiableListView<TransactionDetailEntity>? transactions) =
      TransactionsState$Processing;
  const factory TransactionsState.error(
    UnmodifiableListView<TransactionDetailEntity>? transactions, {
    required Object error,
  }) = TransactionsState$Error;
}
