import 'package:async/async.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/data/sync_backup/utils/sync_handler_mixin.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
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
    required AccountsLocalDataSource accountsLocalDataSource,
  })  : _transactionsNetworkDataSource = transactionsNetworkDataSource,
        _transactionsLocalDataSource = transactionsLocalDataSource,
        _transactionEventsSyncDS = transactionsSyncDataSource,
        _accountsLocalDataSource = accountsLocalDataSource,
        _transactionsLoaderCache$Local = AsyncCache.ephemeral(),
        _transactionsLoaderCache$Network = AsyncCache.ephemeral();

  final TransactionsNetworkDataSource _transactionsNetworkDataSource;
  final TransactionsLocalDataSource _transactionsLocalDataSource;
  final TransactionEventsSyncDataSource _transactionEventsSyncDS;
  final AccountsLocalDataSource _accountsLocalDataSource;
  final AsyncCache<List<TransactionDetailEntity>> _transactionsLoaderCache$Local;
  final AsyncCache<List<TransactionDetailsDto>> _transactionsLoaderCache$Network;

  @override
  Stream<DataResult<Iterable<TransactionCategory>>> getTransactionCategories() async* {
    await _syncActions();
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
  Stream<DataResult<Iterable<TransactionDetailEntity>>> getTransactions(TransactionFilters filters) async* {
    await _syncActions();
    final transactions$Local = await _transactionsLoaderCache$Local.fetch(
      () async {
        final transactions = await _transactionsLocalDataSource.fetchTransactionsDetailed(filters);
        return transactions.toList();
      },
    );
    yield DataResult.offline(data: transactions$Local);
    try {
      final transactions$Remote = await _transactionsLoaderCache$Network.fetch(
        () async {
          final transactions = await _transactionsNetworkDataSource.getTransactions(filters);
          return transactions.toList();
        },
      );
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
  Stream<DataResult<TransactionDetailEntity>> createTransaction(TransactionRequest$Create request) async* {
    final transaction$Local = await _transactionsLocalDataSource.upsertTransaction(request);
    final detailedTransaction$Local = await _transactionsLocalDataSource.fetchTransaction(transaction$Local.id);
    if (detailedTransaction$Local == null) throw StateError('Cannot fetch transaction after update');
    yield DataResult.offline(data: detailedTransaction$Local);
    final action = SyncAction.create(data: transaction$Local, dataRemoteId: null);
    final syncedTransaction = await _syncActions(action);
    yield DataResult.online(
      data: syncedTransaction ?? (throw StateError('_syncEvents must return transaction with create action')),
    );
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> updateTransaction(TransactionRequest$Update request) async* {
    final transaction$Local = await _transactionsLocalDataSource.upsertTransaction(request);
    final transactionDetailed$Local = await _transactionsLocalDataSource.fetchTransaction(transaction$Local.id);
    if (transactionDetailed$Local == null) throw StateError('Cannot fetch transaction after update');
    yield DataResult.offline(data: transactionDetailed$Local);
    final action = SyncAction.update(data: transaction$Local, dataRemoteId: null);
    final res = await _syncActions(action);
    yield DataResult.online(data: res ?? (throw StateError('_syncEvents must return transaction with update action')));
  }

  @override
  Stream<DataResult<void>> deleteTransaction(int id) async* {
    final transaction$Local = await _transactionsLocalDataSource.deleteTransaction(id);
    yield const DataResult.offline(data: null);
    if (transaction$Local == null) return;
    final action =
        SyncAction<TransactionEntity>.delete(dataId: transaction$Local.id, dataRemoteId: transaction$Local.remoteId);
    await _syncActions(action);
    yield const DataResult.online(data: null);
  }

  @override
  Stream<DataResult<TransactionDetailEntity>> getTransaction(int id) async* {
    await _syncActions();
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
  Stream<TransactionDetailEntity?> transactionChanges(int id) => _transactionsLocalDataSource.transactionChanges(id);

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) =>
      _transactionsLocalDataSource.transactionsListChanges(filters);

  Future<TransactionDetailEntity?> _syncActions([SyncAction<TransactionEntity>? transactionAction$Local]) async {
    final actions = await _transactionEventsSyncDS.fetchActions(transactionAction$Local);
    TransactionDetailEntity? result;
    for (final action in actions.toList()) {
      TransactionDetailEntity? bufferResult;
      switch (action) {
        case SyncAction$Create(:final data):
          final res = await _createTransactionWithSync(data);
          if (res.id == data.id) {
            bufferResult = res;
          }
        case SyncAction$Update(:final data):
          final res = await _updateTransactionWithSync(data);
          if (res.id == data.id) {
            bufferResult = res;
          }
        case SyncAction$Delete(:final dataId, :final dataRemoteId):
          await _deleteTransactionWithSync(transactionId: dataId, transactionId$Remote: dataRemoteId);
      }
      result = bufferResult;
      await _transactionEventsSyncDS.removeAction(action);
    }
    return result;
  }

  Future<TransactionDetailEntity> _createTransactionWithSync(TransactionEntity transaction$Local) async {
    final nowUtc = DateTime.now().toUtc();
    try {
      return await handleWithSync<TransactionDetailEntity, TransactionEntity>(
        action: SyncAction.create(
          data: transaction$Local,
          dataRemoteId: null,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
        trySync: () async {
          final account$Remote = await _accountsLocalDataSource.fetchAccount(transaction$Local.accountId);
          final accountId$Remote = account$Remote?.remoteId;
          if (accountId$Remote == null) {
            await _transactionEventsSyncDS.removeAction(SyncAction.create(data: transaction$Local, dataRemoteId: null));
            throw StateError('Account has no remote id (_createTransactionWithSync)');
          }
          final request = TransactionRequest$Create(
            accountId: accountId$Remote,
            categoryId: transaction$Local.categoryId,
            amount: transaction$Local.amount,
            transactionDate: transaction$Local.transactionDate,
            comment: transaction$Local.comment,
          );
          final transaction$Remote = await _transactionsNetworkDataSource.createTransaction(request);
          final transaction$RemoteEntity = TransactionEntity.merge(
            transaction$Remote,
            localId: transaction$Local.id,
            localAccountId: transaction$Local.accountId,
          );
          final syncedTransaction = await _transactionsLocalDataSource.syncTransaction(transaction$RemoteEntity);
          final transactionDetailed = await _transactionsLocalDataSource.fetchTransaction(syncedTransaction.id);
          if (transactionDetailed == null) throw StateError('Cannot fetch transaction after update');
          return transactionDetailed;
        },
        saveAction: _transactionEventsSyncDS.addAction,
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  Future<TransactionDetailEntity> _updateTransactionWithSync(TransactionEntity transaction$Local) async {
    final nowUtc = DateTime.now().toUtc();
    try {
      return await handleWithSync<TransactionDetailEntity, TransactionEntity>(
        action: SyncAction.update(
          data: transaction$Local,
          dataRemoteId: null,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
        trySync: () async {
          final account$Remote = await _accountsLocalDataSource.fetchAccount(transaction$Local.accountId);
          final accountId$Remote = account$Remote?.remoteId;
          if (accountId$Remote == null) throw StateError('Account has no remote id (_createTransactionWithSync)');
          final request = TransactionRequest$Update(
            id: transaction$Local.remoteId ?? (throw StateError('Transaction has no remote id')),
            accountId: accountId$Remote,
            categoryId: transaction$Local.categoryId,
            amount: transaction$Local.amount,
            transactionDate: transaction$Local.transactionDate,
            comment: transaction$Local.comment,
          );
          final transaction$Remote = await _transactionsNetworkDataSource.updateTransaction(request);
          final syncedTransaction = await _transactionsLocalDataSource.syncTransactionWithDetails(
            transaction$Remote,
            localId: transaction$Local.id,
          );
          return syncedTransaction;
        },
        saveAction: _transactionEventsSyncDS.addAction,
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }

  Future<void> _deleteTransactionWithSync({required int transactionId, required int? transactionId$Remote}) async {
    final nowUtc = DateTime.now().toUtc();
    try {
      return await handleWithSync<void, TransactionEntity>(
        action: SyncAction<TransactionEntity>.delete(
          dataId: transactionId,
          dataRemoteId: null,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
        trySync: () async {
          if (transactionId$Remote == null) return;
          await _transactionsNetworkDataSource.deleteTransaction(transactionId$Remote);
        },
        saveAction: _transactionEventsSyncDS.addAction,
      );
    } on RestClientException catch (e, s) {
      final resException = switch (e) {
        StructuredBackendException(:final error) => AppException$Simple.fromStructuredException(error),
        _ => e,
      };
      Error.throwWithStackTrace(resException, s);
    }
  }
}
