import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
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
  Future<void> insertTransactionCategories(List<TransactionCategory> transactionCategories);
  /// <--- end of transaction categories storage --->
  Future<int> getTransactionsCount();
  Future<List<TransactionEntity>> fetchTransactions(int accountId);
  Future<List<TransactionDetailEntity>> fetchTransactionsDetailed(TransactionFilters filters);
  Future<TransactionDetailEntity?> fetchTransaction(int id);
  Future<TransactionEntity> updateTransaction(TransactionRequest transaction);
  Future<int> deleteTransaction(int id);
}

/// TransactionChangesSource is used to get the status of the authentication
abstract interface class TransactionChangesSource {
  /// Stream of [TransactionDetailEntity]
  Stream<TransactionDetailEntity?> transactionChanges(int id);

  /// Stream of [List<TransactionDetailEntity>]
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters);
}
