import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/transactions_repository_impl.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/network/transactions_network_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

import '../../account/repository/account_repositry_test.mocks.dart';
import '../mock_entity_helper/transaction_entities.dart';
import 'transactions_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TransactionsLocalDataSource>(),
  MockSpec<TransactionEventsSyncDataSource>(),
  MockSpec<TransactionsNetworkDataSource>(),
])
void main() {
  late TransactionsLocalDataSource transactionsLocalDataSource;
  late TransactionEventsSyncDataSource transactionEventsSyncDataSource;
  late TransactionsNetworkDataSource transactionsNetworkDataSource;
  late AccountsLocalDataSource accountsLocalDataSource;
  late TransactionsRepository repository;

  setUp(() {
    transactionsLocalDataSource = MockTransactionsLocalDataSource();
    transactionEventsSyncDataSource = MockTransactionEventsSyncDataSource();
    transactionsNetworkDataSource = MockTransactionsNetworkDataSource();
    accountsLocalDataSource = MockAccountsLocalDataSource();
    repository = TransactionsRepositoryImpl(
      transactionsSyncDataSource: transactionEventsSyncDataSource,
      transactionsNetworkDataSource: transactionsNetworkDataSource,
      transactionsLocalDataSource: transactionsLocalDataSource,
      accountsLocalDataSource: accountsLocalDataSource,
    );
  });

  test('Создание новой транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.upsertTransaction(txRequest)).thenAnswer((_) async => txItem);
    final tx = await repository.createTransaction(txRequest).first;

    expect(tx.data.category.id, equals(txItem.id));
    expect(tx.data.amount, equals(txItem.amount));
  });

  test('Получение транзакции по ID', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    final txDetailedEntity = MockTransactionsEntitiesHelper.detailedEntityFromRequest(txRequest);
    when(transactionsLocalDataSource.upsertTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest).first;
    when(transactionsLocalDataSource.fetchTransaction(created.data.id)).thenAnswer((_) async => txDetailedEntity);
    final detail = await repository.getTransaction(created.data.id).first;

    expect(detail.data.id, equals(created.data.id));
  });

  test('Обновление транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.upsertTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest).first;

    final txUpdateRequest = TransactionRequest$Update(
      id: created.data.id,
      accountId: created.data.account.id,
      categoryId: 2,
      amount: '123',
      transactionDate: DateTime.now().add(const Duration(days: 1)),
      comment: 'Updated comment',
    );
    final txUpdatedItem = MockTransactionsEntitiesHelper.entityFromRequest(txUpdateRequest);
    final txDetailedUpdatedItem = MockTransactionsEntitiesHelper.detailedEntityFromRequest(txUpdateRequest);
    when(transactionsLocalDataSource.upsertTransaction(txUpdateRequest)).thenAnswer((_) async => txUpdatedItem);
    when(transactionsLocalDataSource.fetchTransaction(created.data.id)).thenAnswer((_) async => txDetailedUpdatedItem);
    final updated = await repository.updateTransaction(txUpdateRequest).first;

    expect(updated.data.amount, equals(txUpdatedItem.amount));
    expect(updated.data.comment, equals(txUpdatedItem.comment));
  });

  test('Удаление транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.upsertTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest).first;

    when(transactionsLocalDataSource.deleteTransaction(created.data.id)).thenAnswer((_) async => null);
    await repository.deleteTransaction(created.data.id).first;

    final deleted = await repository.getTransaction(created.data.id).first;

    expect(deleted, isNull);
  });

  test('Получение транзакций по accountId и дате', () async {
    final now = DateTime.now();
    final firstRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final secondRequest = MockTransactionsEntitiesHelper.sampleCreateRequest()
        .copyWith(transactionDate: now.subtract(const Duration(days: 5)));
    final firstEntity = MockTransactionsEntitiesHelper.entityFromRequest(firstRequest);
    final secondEntity = MockTransactionsEntitiesHelper.entityFromRequest(secondRequest, id: 2);
    final firstDetailedEntity = MockTransactionsEntitiesHelper.detailedEntityFromRequest(firstRequest);
    when(transactionsLocalDataSource.upsertTransaction(firstRequest)).thenAnswer((_) async => firstEntity);
    when(transactionsLocalDataSource.upsertTransaction(secondRequest)).thenAnswer((_) async => secondEntity);

    final filters =
        TransactionFilters(accountId: 1, accountRemoteId: 1, startDate: now.subtract(const Duration(days: 1)));
    when(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).thenAnswer((_) async => [firstDetailedEntity]);
    final result = await repository.getTransactions(filters).first;

    expect(result.data.length, equals(1));
    final found = result.data.firstWhereOrNull((tx) => tx.comment == firstRequest.comment);
    expect(found, isNotNull);
    expect(found!.amount, equals(firstRequest.amount));
  });
}
