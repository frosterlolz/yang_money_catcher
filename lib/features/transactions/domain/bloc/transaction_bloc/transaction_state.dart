part of 'transaction_bloc.dart';

@freezed
sealed class TransactionState with _$TransactionState {
  const factory TransactionState.processing(TransactionDetailEntity? transaction) = TransactionState$Processing;
  const factory TransactionState.idle(TransactionDetailEntity? transaction) = TransactionState$Idle;
  const factory TransactionState.updated(TransactionDetailEntity? transaction) = TransactionState$Updated;
  const factory TransactionState.error(TransactionDetailEntity? transaction, {required Object error}) =
      TransactionState$Error;
}
