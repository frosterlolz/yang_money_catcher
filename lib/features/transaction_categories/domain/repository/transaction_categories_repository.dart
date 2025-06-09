import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

/// Репозиторий для работы с категориями транзакций (расходы/доходы).
abstract interface class TransactionCategoriesRepository {
  /// Получить список всех категорий транзакций.
  ///
  /// Returns:
  ///   Iterable<TransactionCategory> — список всех категорий.
  Future<Iterable<TransactionCategory>> getTransactionCategories();

  /// Получить категории транзакций по типу:
  /// [isIncome] == true — только доходы,
  /// [isIncome] == false — только расходы.
  ///
  /// Parameters:
  ///   [isIncome] — фильтр для типа транзакций.
  ///
  /// Returns:
  ///   Iterable<TransactionCategory> — список отфильтрованных категорий.
  Future<Iterable<TransactionCategory>> getTransactionCategoriesByType(bool isIncome);
}
