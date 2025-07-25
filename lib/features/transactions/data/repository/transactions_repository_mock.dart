import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/features/common/data/mock_data_store.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class TransactionsRepository$Mock implements TransactionsRepository {
  const TransactionsRepository$Mock(this._mockDataStore);

  final MockDataStore _mockDataStore;

  @override
  Stream<DataResult<TransactionDetailEntity>> createTransaction(TransactionRequest$Create request) async* {
    final upsertedId = _mockDataStore.upsertTransaction(request);
    final detailed = await _mockDataStore.fetchTransaction(upsertedId);
    if (detailed == null) throw StateError('Cannot fetch transaction after insert/update');
    yield DataResult.offline(data: detailed);
    await Future<void>.delayed(const Duration(seconds: 3));
    yield DataResult.online(data: detailed);
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> updateTransaction(TransactionRequest$Update request) async* {
    final upsertedId = _mockDataStore.upsertTransaction(request);
    final detailed = await _mockDataStore.fetchTransaction(upsertedId);
    if (detailed == null) throw StateError('Cannot fetch transaction after update');
    yield DataResult.offline(data: detailed);
    await Future<void>.delayed(const Duration(seconds: 1));
    yield DataResult.online(data: detailed);
  }

  @override
  Stream<DataResult<void>> deleteTransaction(int id) async* {
    _mockDataStore.deleteTransaction(id);
    yield const DataResult.offline(data: null);
    await Future<void>.delayed(const Duration(seconds: 1));
    yield const DataResult.online(data: null);
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> getTransaction(int id) async* {
    final res = await _mockDataStore.fetchTransaction(id);
    if (res == null) throw StateError('Cannot fetch transaction');
    yield DataResult.offline(data: res);
    await Future<void>.delayed(const Duration(seconds: 1));
    yield DataResult.online(data: res);
  }

  @override
  Stream<DataResult<Iterable<TransactionCategory>>> getTransactionCategories() async* {
    final res = _mockDataStore.transactionCategories;
    yield DataResult.offline(data: res);
    await Future<void>.delayed(const Duration(seconds: 1));
    yield DataResult.online(data: res);
  }

  @override
  Stream<DataResult<Iterable<TransactionDetailEntity>>> getTransactions(TransactionFilters filters) async* {
    final res = await _mockDataStore.fetchTransactionsDetailed(filters);
    yield DataResult.offline(data: res);
    await Future<void>.delayed(const Duration(seconds: 1));
    yield DataResult.online(data: res);
  }

  @override
  Stream<TransactionDetailEntity?> transactionChanges(int id) => _mockDataStore.transactionDetailedChanges(id);

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) =>
      _mockDataStore.transactionDetailedListChanges(filters);
}
