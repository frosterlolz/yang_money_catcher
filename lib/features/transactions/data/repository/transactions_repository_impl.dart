import 'dart:math';

import 'package:async/async.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/data/sync_backup/utils/sync_handler_mixin.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/features/transaction_categories/data/source/mock_transaction_categories.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/network/transactions_network_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class TransactionsRepositoryImpl with SyncHandlerMixin implements TransactionsRepository {
  TransactionsRepositoryImpl({
    required TransactionsNetworkDataSource transactionsNetworkDataSource,
    required TransactionsLocalDataSource transactionsLocalDataSource,
    required TransactionEventsSyncDataSource transactionsSyncDataSource,
  })  : _transactionsNetworkDataSource = transactionsNetworkDataSource,
        _transactionsLocalDataSource = transactionsLocalDataSource,
        _transactionEventsSyncDS = transactionsSyncDataSource,
        _transactionsLoaderCache = AsyncCache.ephemeral();

  final TransactionsNetworkDataSource _transactionsNetworkDataSource;
  final TransactionsLocalDataSource _transactionsLocalDataSource;
  final TransactionEventsSyncDataSource _transactionEventsSyncDS;
  final AsyncCache<List<TransactionDetailEntity>> _transactionsLoaderCache;

  @override
  Stream<DataResult<Iterable<TransactionDetailEntity>>> getTransactions(TransactionFilters filters) async* {
    // TODO(frosterlolz): add sync method
    // 1 - получаю локальные транзакции
    final transactions$Local = await _transactionsLoaderCache.fetch(
      () async {
        final transactions = await _transactionsLocalDataSource.fetchTransactionsDetailed(filters);
        return transactions.toList();
      },
    );
    yield DataResult.offline(data: transactions$Local);
    try {
      final transactions$Remote = await _transactionsNetworkDataSource.getTransactions(filters);
      final syncedTransactions = await _transactionsLocalDataSource.syncTransactions(
        localTransactions: transactions$Local,
        remoteTransactions: transactions$Remote,
      );
      yield DataResult.online(data: syncedTransactions);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @override
  Stream<DataResult<TransactionEntity>> createTransaction(TransactionRequest$Create request) async* {
    // TODO(frosterlolz): add sync method
    final transaction$Local = await _transactionsLocalDataSource.updateTransaction(request);
    yield DataResult.offline(data: transaction$Local);
    final syncedTransaction = await _createTransactionWithSync(transaction$Local);
    yield DataResult.online(data: syncedTransaction);
  }

  Future<TransactionEntity> _createTransactionWithSync(TransactionEntity transaction$Local) async {
    try {
      return await handleWithSync<TransactionEntity>(
        method: () async {
          final request = TransactionRequest$Create(
            accountId: transaction$Local.accountId,
            categoryId: transaction$Local.categoryId,
            amount: transaction$Local.amount,
            transactionDate: transaction$Local.transactionDate,
            comment: transaction$Local.comment,
          );
          final transaction$Remote = await _transactionsNetworkDataSource.createTransaction(request);
          final transaction$RemoteEntity = TransactionEntity.merge(transaction$Remote, transaction$Local.id);
          final syncedTransaction = await _transactionsLocalDataSource.syncTransaction(transaction$RemoteEntity);
          return syncedTransaction;
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction.create(
            createdAt: nowUtc,
            updatedAt: nowUtc,
            data: transaction$Local,
          );
          await _transactionEventsSyncDS.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> updateTransaction(TransactionRequest$Update request) async* {
    // TODO(frosterlolz): add sync method
    final transaction$Local = await _transactionsLocalDataSource.updateTransaction(request);
    final detailedTransaction = await _transactionsLocalDataSource.fetchTransaction(transaction$Local.id);
    if (detailedTransaction == null) throw StateError('Cannot fetch transaction after update');
    yield DataResult.offline(data: detailedTransaction);
    final syncedTransaction = await _updateTransactionWithSync(transaction$Local);
    yield DataResult.online(data: syncedTransaction);
  }

  Future<TransactionDetailEntity> _updateTransactionWithSync(TransactionEntity transaction$Local) async {
    try {
      return handleWithSync<TransactionDetailEntity>(
        method: () async {
          final request = TransactionRequest$Update(
            id: transaction$Local.remoteId ?? (throw StateError('Transaction has no remote id')),
            accountId: transaction$Local.accountId,
            categoryId: transaction$Local.categoryId,
            amount: transaction$Local.amount,
            transactionDate: transaction$Local.transactionDate,
            comment: transaction$Local.comment,
          );
          final transaction$Remote = await _transactionsNetworkDataSource.updateTransaction(request);
          final syncedAccount = await _transactionsLocalDataSource.syncTransactionWithDetails(transaction$Remote,
              localId: transaction$Local.id);
          return syncedAccount;
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction.update(
            createdAt: nowUtc,
            updatedAt: nowUtc,
            data: transaction$Local,
          );
          await _transactionEventsSyncDS.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  @override
  Stream<DataResult<void>> deleteTransaction(int id) async* {
    // TODO(frosterlolz): add sync method
    final transactionId$Remote = await _transactionsLocalDataSource.deleteTransaction(id);
    yield const DataResult.offline(data: null);
    if (transactionId$Remote == null) return;
    await _deleteTransactionWithSync(transactionId$Remote);
    yield const DataResult.online(data: null);
  }

  Future<void> _deleteTransactionWithSync(int transactionId$Remote) async {
    try {
      return await handleWithSync<void>(
        method: () async {
          await _transactionsNetworkDataSource.deleteTransaction(transactionId$Remote);
        },
        addEventMethod: () async {
          final nowUtc = DateTime.now().toUtc();
          final event = SyncAction<TransactionEntity>.delete(
            dataId: transactionId$Remote,
            createdAt: nowUtc,
            updatedAt: nowUtc,
          );
          await _transactionEventsSyncDS.addEvent(event);
        },
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> getTransaction(int id) async* {
    // TODO(frosterlolz): add sync method
    final transaction$Local = await _transactionsLocalDataSource.fetchTransaction(id);
    if (transaction$Local != null) {
      yield DataResult.offline(data: transaction$Local);
    }
    final transactionId$Remote = transaction$Local?.remoteId;
    if (transactionId$Remote == null) throw StateError('Transaction has no remote id');
    try {
      final transaction$Remote = await _transactionsNetworkDataSource.getTransaction(transactionId$Remote);
      final syncedTransactions =
          await _transactionsLocalDataSource.syncTransactionWithDetails(transaction$Remote, localId: id);
      yield DataResult.online(data: syncedTransactions);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @override
  Stream<DataResult<Iterable<TransactionCategory>>> getTransactionCategories() async* {
    // TODO(frosterlolz): add sync method
    final categories$Local = await _transactionsLocalDataSource.fetchTransactionCategories();
    yield DataResult.offline(data: categories$Local);
    try {
      final categories$Remote = await _transactionsNetworkDataSource.getTransactionCategories();
      final syncedCategories = await _transactionsLocalDataSource.insertTransactionCategories(categories$Remote);
      yield DataResult.online(data: syncedCategories);
    } on StructuredBackendException catch (e, s) {
      final appException = AppException$Simple.fromStructuredException(e.error);
      Error.throwWithStackTrace(appException, s);
    }
  }

  @override
  Stream<TransactionDetailEntity?> transactionChanges(int id) => _transactionsLocalDataSource.transactionChanges(id);

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) =>
      _transactionsLocalDataSource.transactionsListChanges(filters);

  @Deprecated('For testing only, now REST API is used')
  Future<void> generateMockData() async {
    await fillTransactionCategories();
    final transactionsCount = await _transactionsLocalDataSource.getTransactionsCount();
    if (transactionsCount > 0) return;
    final random = Random();
    final categories = await _transactionsLocalDataSource.fetchTransactionCategories();
    final requests = List.generate(
      1000,
      (index) {
        final categoryIndex = random.nextInt(categories.length);
        final amountFractionalPart = random.nextInt(2) > 0 ? '00' : '50';
        final transactionHour = random.nextInt(24);
        final transactionMinute = random.nextInt(60);
        final transactionDate = DateTime.now()
            .copyWith(hour: transactionHour, minute: transactionMinute)
            .subtract(Duration(days: random.nextInt(100)));
        return TransactionRequest.create(
          accountId: 1,
          amount: '10000.$amountFractionalPart',
          categoryId: categories.elementAt(categoryIndex).id,
          comment: 'Comment at $index',
          transactionDate: transactionDate,
        );
      },
    ).cast<TransactionRequest$Create>();
    await _transactionsLocalDataSource.insertTransactions(requests);
  }

  @Deprecated('For testing only, now REST API is used')
  Future<void> fillTransactionCategories() async {
    final transactionCategories = await _transactionsLocalDataSource.transactionCategoriesCount();
    if (transactionCategories == 0) {
      final mockCategories = transactionCategoriesJson.map(TransactionCategory.fromJson);
      await _transactionsLocalDataSource.insertTransactionCategories(mockCategories.toList());
    }
  }
}
