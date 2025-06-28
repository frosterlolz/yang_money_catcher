part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.load(int accountId, {DateTimeRange? range}) = _Load;
}
