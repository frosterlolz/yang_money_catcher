part of 'transaction_categories_bloc.dart';

@freezed
sealed class TransactionCategoriesState with _$TransactionCategoriesState {
  const TransactionCategoriesState._();

  const factory TransactionCategoriesState.idle(UnmodifiableListView<TransactionCategory> categories) =
      TransactionCategoriesState$Idle;
  const factory TransactionCategoriesState.processing(UnmodifiableListView<TransactionCategory>? categories) =
      TransactionCategoriesState$Processing;
  const factory TransactionCategoriesState.error(
    UnmodifiableListView<TransactionCategory>? categories, {
    required Object error,
  }) = TransactionCategoriesState$Error;

  TransactionCategory? findCategory(int id) => categories?.firstWhereOrNull((category) => category.id == id);
}
