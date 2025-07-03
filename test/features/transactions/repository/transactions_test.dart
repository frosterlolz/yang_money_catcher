import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/transactions_repository_impl.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

import '../mock_entity_helper/transaction_entities.dart';
import 'transactions_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TransactionsLocalDataSource>()])
void main() {
  late TransactionsLocalDataSource transactionsLocalDataSource;
  late TransactionsRepository repository;

  setUp(() {
    transactionsLocalDataSource = MockTransactionsLocalDataSource();
    repository = TransactionsRepositoryImpl(transactionsLocalDataSource);
  });

  test('Создание новой транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.updateTransaction(txRequest)).thenAnswer((_) async => txItem);
    final tx = await repository.createTransaction(txRequest);

    expect(tx.categoryId, equals(txItem.id));
    expect(tx.amount, equals(txItem.amount));
  });

  test('Получение транзакции по ID', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    final txDetailedEntity = MockTransactionsEntitiesHelper.detailedEntityFromRequest(txRequest);
    when(transactionsLocalDataSource.updateTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest);
    when(transactionsLocalDataSource.fetchTransaction(created.id)).thenAnswer((_) async => txDetailedEntity);
    final detail = await repository.getTransaction(created.id);

    expect(detail?.id, equals(created.id));
  });

  test('Обновление транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.updateTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest);

    final txUpdateRequest = TransactionRequest$Update(
      id: created.id,
      accountId: created.accountId,
      categoryId: 2,
      amount: '123',
      transactionDate: DateTime.now().add(const Duration(days: 1)),
      comment: 'Updated comment',
    );
    final txUpdatedItem = MockTransactionsEntitiesHelper.entityFromRequest(txUpdateRequest);
    final txDetailedUpdatedItem = MockTransactionsEntitiesHelper.detailedEntityFromRequest(txUpdateRequest);
    when(transactionsLocalDataSource.updateTransaction(txUpdateRequest)).thenAnswer((_) async => txUpdatedItem);
    when(transactionsLocalDataSource.fetchTransaction(created.id)).thenAnswer((_) async => txDetailedUpdatedItem);
    final updated = await repository.updateTransaction(txUpdateRequest);

    expect(updated.amount, equals(txUpdatedItem.amount));
    expect(updated.comment, equals(txUpdatedItem.comment));
  });

  test('Удаление транзакции', () async {
    final txRequest = MockTransactionsEntitiesHelper.sampleCreateRequest();
    final txItem = MockTransactionsEntitiesHelper.entityFromRequest(txRequest);
    when(transactionsLocalDataSource.updateTransaction(txRequest)).thenAnswer((_) async => txItem);
    final created = await repository.createTransaction(txRequest);

    when(transactionsLocalDataSource.deleteTransaction(created.id)).thenAnswer((_) async => 1);
    await repository.deleteTransaction(created.id);

    final deleted = await repository.getTransaction(created.id);

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
    when(transactionsLocalDataSource.updateTransaction(firstRequest)).thenAnswer((_) async => firstEntity);
    when(transactionsLocalDataSource.updateTransaction(secondRequest)).thenAnswer((_) async => secondEntity);

    final filters = TransactionFilters(accountId: 1, startDate: now.subtract(const Duration(days: 1)));
    when(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).thenAnswer((_) async => [firstDetailedEntity]);
    final result = await repository.getTransactions(filters);

    expect(result.length, equals(1));
    final found = result.firstWhereOrNull((tx) => tx.comment == firstRequest.comment);
    expect(found, isNotNull);
    expect(found!.amount, equals(firstRequest.amount));
  });
}
