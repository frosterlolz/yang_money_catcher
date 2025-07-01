part of 'transaction_categories_bloc.dart';

@freezed
sealed class TransactionCategoriesEvent with _$TransactionCategoriesEvent {
  const factory TransactionCategoriesEvent.load() = _Load;
}
