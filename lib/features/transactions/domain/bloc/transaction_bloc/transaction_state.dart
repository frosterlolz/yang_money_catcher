part of 'transaction_bloc.dart';

@freezed
sealed class TransactionState with _$TransactionState {
  const factory TransactionState.processing(TransactionDetailEntity? transaction, {required bool isOffline}) =
      TransactionState$Processing;
  const factory TransactionState.idle(TransactionDetailEntity? transaction, {required bool isOffline}) =
      TransactionState$Idle;
  const factory TransactionState.updated(TransactionDetailEntity? transaction, {required bool isOffline}) =
      TransactionState$Updated;
  const factory TransactionState.error(
    TransactionDetailEntity? transaction, {
    required bool isOffline,
    required Object error,
  }) = TransactionState$Error;
}
