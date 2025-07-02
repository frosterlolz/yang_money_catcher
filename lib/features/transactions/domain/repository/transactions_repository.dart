import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

/// Репозиторий для работы с транзакциями пользователя.
abstract interface class TransactionsRepository implements TransactionChangesSource {
  /// Создать новую транзакцию.
  ///
  /// Parameters:
  ///   [request] — данные для создания транзакции.
  ///
  /// Returns:
  ///   [TransactionEntity] — созданная транзакция.
  Future<TransactionEntity> createTransaction(TransactionRequest$Create request);

  /// Получить полную информацию о конкретной транзакции.
  ///
  /// Parameters:
  ///   [id] — идентификатор транзакции.
  ///
  /// Returns:
  ///   [TransactionDetailEntity] — подробные данные транзакции.
  Future<TransactionDetailEntity?> getTransaction(int id);

  /// Обновить существующую транзакцию.
  ///
  /// Parameters:
  ///   [request] — обновленные данные транзакции.
  ///
  /// Returns:
  ///   [TransactionDetailEntity] — обновлённая транзакция.
  Future<TransactionDetailEntity> updateTransaction(TransactionRequest$Update request);

  /// Удалить транзакцию по ID.
  ///
  /// Parameters:
  ///   [id] — идентификатор транзакции.
  Future<void> deleteTransaction(int id);

  /// Получить список транзакций для указанного счёта в заданном диапазоне дат.
  ///
  /// Parameters:
  ///  [filters] — фильтры для выборки транзакций.
  /// Returns:
  ///   Iterable<TransactionDetailEntity> — список транзакций.
  Future<Iterable<TransactionDetailEntity>> getTransactions(TransactionFilters filters);

  /// Получить список категорий транзакций
  ///
  /// Returns:
  ///   Iterable<TransactionCategory> — список категорий
  Future<Iterable<TransactionCategory>> getTransactionCategories();
}
