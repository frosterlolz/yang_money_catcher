import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

/// [int] -> id транзакции,
/// [TransactionDetailEntity] -> измененная/новая транзакция.
/// Если [TransactionDetailEntity] == Null- значит транзакция удалена
typedef TransactionChangeEntry = MapEntry<int, TransactionDetailEntity?>;

abstract interface class TransactionsLocalDataSource implements TransactionChangesSource {
  /// <--- Transaction categories storage --->
  Future<int> transactionCategoriesCount();
  Future<List<TransactionCategory>> fetchTransactionCategories();
  Future<List<TransactionCategory>> insertTransactionCategories(List<TransactionCategory> transactionCategories);

  /// <--- end of transaction categories storage --->
  Future<int> getTransactionsCount();
  Future<List<TransactionEntity>> fetchTransactions(int accountId);
  Future<List<TransactionDetailEntity>> syncTransactions({
    required List<TransactionDetailEntity> localTransactions,
    required List<TransactionDetailsDto> remoteTransactions,
  });
  Future<TransactionEntity> syncTransaction(TransactionEntity transaction);
  Future<TransactionDetailEntity> syncTransactionWithDetails(
    TransactionDetailsDto transaction, {
    required int? localId,
  });
  Future<List<TransactionDetailEntity>> fetchTransactionsDetailed(TransactionFilters filters);
  Future<TransactionDetailEntity?> fetchTransaction(int id);
  Future<void> insertTransactions(List<TransactionRequest$Create> requests);
  Future<TransactionEntity> updateTransaction(TransactionRequest transaction);

  /// Возвращает удаленную транзакцию, если было что удалять
  Future<TransactionEntity?> deleteTransaction(int id);
}

/// TransactionChangesSource is used to get the status of the authentication
abstract interface class TransactionChangesSource {
  /// Stream of [TransactionDetailEntity]
  Stream<TransactionDetailEntity?> transactionChanges(int id);

  /// Stream of [List<TransactionDetailEntity>]
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters);
}
