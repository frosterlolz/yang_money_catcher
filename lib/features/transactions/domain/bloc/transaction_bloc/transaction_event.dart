part of 'transaction_bloc.dart';

@freezed
sealed class TransactionEvent with _$TransactionEvent {
  const TransactionEvent._();

  const factory TransactionEvent.load(int id) = _Load;
  const factory TransactionEvent.update(TransactionRequest request) = _Update;
  const factory TransactionEvent.delete(int id) = _Delete;
}

final class _InternalUpdate extends TransactionEvent {
  const _InternalUpdate({
    required this.transactionId,
    required this.transaction,
  }) : super._();

  final int transactionId;
  final TransactionDetailEntity? transaction;
}
