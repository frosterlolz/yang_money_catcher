import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

/// Репозиторий для работы с транзакциями пользователя.
abstract interface class TransactionsRepository {
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
  ///   [accountId] — ID счёта.
  ///   [startDate] — начальная дата (включительно).
  ///   Если не указана, используется начало текущего месяца.
  ///   [endDate] — конечная дата (включительно).
  ///   Если не указана, используется конец текущего месяца.
  ///
  /// Returns:
  ///   Iterable<TransactionDetailEntity> — список транзакций.
  Future<Iterable<TransactionDetailEntity>> getTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Получить поток изменений транзакций.
  ///
  /// Parameters:
  ///   [id] — идентификатор транзакции. Если он указан- диапазон дат игнорируется.
  ///   [startDate] — начальная дата (включительно).
  ///   Если не указана, все считаются подходящими.
  ///   [endDate] — конечная дата (включительно).
  ///   Если не указана, все считаются подходящими.
  ///
  /// Returns:
  ///   Stream<TransactionChangeEntry> — поток изменений транзакций.
  Stream<TransactionChangeEntry> transactionChangesStream({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Получить список категорий транзакций
  ///
  /// Returns:
  ///   Iterable<TransactionCategory> — список категорий
  Future<Iterable<TransactionCategory>> getTransactionCategories();
}
