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

  Iterable<TransactionDetailEntity> filtered(
    Iterable<TransactionDetailEntity> transactions, {
    required bool isIncome,
  }) =>
      isIncome ? incomeFiltered(transactions) : expensesFiltered(transactions);
  Iterable<TransactionDetailEntity> expensesFiltered(Iterable<TransactionDetailEntity> transactions) =>
      transactions.where((transaction) => !transaction.category.isIncome);
  Iterable<TransactionDetailEntity> incomeFiltered(Iterable<TransactionDetailEntity> transactions) =>
      transactions.where((transaction) => transaction.category.isIncome);
}
