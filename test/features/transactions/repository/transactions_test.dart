import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/transactions_repository_impl.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/network/transactions_network_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

import '../../account/mock_entity_helper/account_entities.dart';
import '../../account/repository/account_repositry_test.mocks.dart';
import '../mock_entity_helper/transaction_entities.dart';
import 'transactions_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<TransactionsLocalDataSource>(),
  MockSpec<TransactionEventsSyncDataSource>(),
  MockSpec<TransactionsNetworkDataSource>(),
])
void main() {
  late MockTransactionsLocalDataSource transactionsLocalDataSource;
  late MockTransactionEventsSyncDataSource transactionEventsSyncDataSource;
  late MockTransactionsNetworkDataSource transactionsNetworkDataSource;
  late MockAccountsLocalDataSource accountsLocalDataSource;
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

  group('createTransaction', () {
    test('emits offline then online result on success', () async {
      final request = MockTransactionsEntitiesHelper.sampleCreateRequest();
      final transactionLocal = MockTransactionsEntitiesHelper.transaction(1, comment: 'Local');
      final detailedLocal = MockTransactionsEntitiesHelper.transactionDetails(1, comment: 'Local');
      final syncedTransaction = MockTransactionsEntitiesHelper.transactionDetails(1, comment: 'Remote');

      when(transactionsLocalDataSource.upsertTransaction(request)).thenAnswer((_) async => transactionLocal);

      int fetchTransactionCallCount = 0;
      when(transactionsLocalDataSource.fetchTransaction(transactionLocal.id)).thenAnswer((_) async {
        fetchTransactionCallCount++;
        if (fetchTransactionCallCount == 1) return detailedLocal;
        return syncedTransaction;
      });

      when(transactionEventsSyncDataSource.fetchActions(any)).thenAnswer(
        (_) async => [
          SyncAction.create(data: transactionLocal, dataRemoteId: null),
        ],
      );
      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => Future.value());
      when(transactionEventsSyncDataSource.addAction(any)).thenAnswer((_) async => Future.value());

      when(accountsLocalDataSource.fetchAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.account(remoteId: 42));

      when(transactionsNetworkDataSource.createTransaction(any))
          .thenAnswer((_) async => MockTransactionsEntitiesHelper.transactionDto(123));

      when(transactionsLocalDataSource.syncTransaction(any))
          .thenAnswer((_) async => MockTransactionsEntitiesHelper.transaction(transactionLocal.id, remoteId: 123));

      final results = await repository.createTransaction(request).toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data.id, detailedLocal.id);
      expect(results[0].data.comment, detailedLocal.comment);

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.id, syncedTransaction.id);
      expect(results[1].data.comment, syncedTransaction.comment);

      verify(transactionsLocalDataSource.upsertTransaction(request)).called(1);
      verify(transactionsLocalDataSource.fetchTransaction(transactionLocal.id)).called(greaterThan(1));
      verify(transactionEventsSyncDataSource.fetchActions(any)).called(1);
      verify(transactionEventsSyncDataSource.removeAction(any)).called(greaterThan(0));
    });

    test('throws AppException on RestClientException during sync', () async {
      final request = MockTransactionsEntitiesHelper.sampleCreateRequest();
      final transactionLocal = MockTransactionsEntitiesHelper.transaction(1, comment: 'Local');

      when(transactionsLocalDataSource.upsertTransaction(request)).thenAnswer((_) async => transactionLocal);

      when(transactionsLocalDataSource.fetchTransaction(transactionLocal.id))
          .thenAnswer((_) async => MockTransactionsEntitiesHelper.transactionDetails(1, comment: 'Local'));

      when(transactionEventsSyncDataSource.fetchActions(any)).thenAnswer(
        (_) async => [
          SyncAction.create(data: transactionLocal, dataRemoteId: null),
        ],
      );

      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => Future.value());

      when(transactionEventsSyncDataSource.addAction(any)).thenAnswer((_) async => Future.value());

      when(accountsLocalDataSource.fetchAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.account(remoteId: 42));

      when(transactionsNetworkDataSource.createTransaction(any))
          .thenThrow(const StructuredBackendException(error: {'message': 'Backend error'}));
      await expectLater(
        () async => repository.createTransaction(request).toList(),
        throwsA(isA<AppException>()),
      );

      verify(transactionsLocalDataSource.upsertTransaction(request)).called(1);
      verify(transactionEventsSyncDataSource.fetchActions(any)).called(1);
    });
  });

  group('getTransaction', () {
    test('emits offline then online result on success', () async {
      const transactionId = 1;
      final localTransaction = MockTransactionsEntitiesHelper.transactionDetails(transactionId, comment: 'Local');
      final remoteTransactionDto = MockTransactionsEntitiesHelper.transactionDetailsDto(42);
      final syncedTransaction = MockTransactionsEntitiesHelper.transactionDetails(transactionId, comment: 'Remote');

      when(transactionsLocalDataSource.fetchTransaction(transactionId)).thenAnswer((_) async => localTransaction);

      when(transactionsNetworkDataSource.getTransaction(localTransaction.remoteId))
          .thenAnswer((_) async => remoteTransactionDto);

      when(transactionsLocalDataSource.syncTransactionWithDetails(remoteTransactionDto, localId: transactionId))
          .thenAnswer((_) async => syncedTransaction);

      final results = await repository.getTransaction(transactionId).toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data, localTransaction);

      expect(results[1].isOffline, isFalse);
      expect(results[1].data, syncedTransaction);

      verify(transactionsLocalDataSource.fetchTransaction(transactionId)).called(1);
      verify(transactionsNetworkDataSource.getTransaction(localTransaction.remoteId)).called(1);
      verify(transactionsLocalDataSource.syncTransactionWithDetails(remoteTransactionDto, localId: transactionId))
          .called(1);
    });

    test('throws StateError if local transaction is null', () async {
      const transactionId = 1;

      when(transactionsLocalDataSource.fetchTransaction(transactionId)).thenAnswer((_) async => null);

      await expectLater(
        repository.getTransaction(transactionId).toList(),
        throwsA(isA<StateError>()),
      );

      verify(transactionsLocalDataSource.fetchTransaction(transactionId)).called(1);
      verifyNever(transactionsNetworkDataSource.getTransaction(any));
    });

    test('throws AppException on StructuredBackendException', () async {
      const transactionId = 1;
      final localTransaction = MockTransactionsEntitiesHelper.transactionDetails(transactionId, comment: 'Local');

      when(transactionsLocalDataSource.fetchTransaction(transactionId)).thenAnswer((_) async => localTransaction);

      when(transactionsNetworkDataSource.getTransaction(localTransaction.remoteId))
          .thenThrow(const StructuredBackendException(error: {'message': 'Backend error'}));

      await expectLater(
        repository.getTransaction(transactionId).toList(),
        throwsA(isA<AppException>()),
      );

      verify(transactionsLocalDataSource.fetchTransaction(transactionId)).called(1);
      verify(transactionsNetworkDataSource.getTransaction(localTransaction.remoteId)).called(1);
    });
  });

  group('updateTransaction', () {
    test('emits offline then online result on success', () async {
      final request = MockTransactionsEntitiesHelper.sampleUpdateRequest(comment: 'Remote');
      final transactionLocal = MockTransactionsEntitiesHelper.transaction(1, comment: 'Local');
      final detailedLocal = MockTransactionsEntitiesHelper.transactionDetails(1, comment: 'Local');
      when(transactionsLocalDataSource.upsertTransaction(request)).thenAnswer((_) async => transactionLocal);
      when(transactionsLocalDataSource.fetchTransaction(transactionLocal.id)).thenAnswer((_) async => detailedLocal);
      when(transactionEventsSyncDataSource.fetchActions(any)).thenAnswer(
        (_) async => [
          SyncAction.update(data: transactionLocal, dataRemoteId: transactionLocal.remoteId),
        ],
      );
      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => Future.value());
      when(transactionEventsSyncDataSource.addAction(any)).thenAnswer((_) async => Future.value());
      when(accountsLocalDataSource.fetchAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.account(remoteId: 42));
      when(transactionsNetworkDataSource.updateTransaction(any))
          .thenAnswer((_) async => MockTransactionsEntitiesHelper.transactionDetailsDto(123, comment: 'Remote'));
      when(
        transactionsLocalDataSource.syncTransactionWithDetails(
          any,
          localId: anyNamed('localId'),
        ),
      ).thenAnswer((invocation) async {
        final localId = invocation.namedArguments[#localId] as int? ?? 1;
        return MockTransactionsEntitiesHelper.transactionDetail(localId, remoteId: 123, comment: 'Remote');
      });

      final results = await repository.updateTransaction(request).toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data.comment, 'Local');

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.comment, 'Remote');

      verify(transactionsLocalDataSource.upsertTransaction(request)).called(1);
      verify(transactionsLocalDataSource.fetchTransaction(transactionLocal.id)).called(1);
      verify(transactionEventsSyncDataSource.fetchActions(any)).called(1);
      verify(transactionEventsSyncDataSource.removeAction(any)).called(greaterThan(0));
    });

    test('throws AppException on RestClientException during sync', () async {
      final request = MockTransactionsEntitiesHelper.sampleUpdateRequest(comment: 'Remote');
      final transactionLocal = MockTransactionsEntitiesHelper.transaction(1, comment: 'Local');

      when(transactionsLocalDataSource.upsertTransaction(request)).thenAnswer((_) async => transactionLocal);

      when(transactionsLocalDataSource.fetchTransaction(transactionLocal.id))
          .thenAnswer((_) async => MockTransactionsEntitiesHelper.transactionDetails(1, comment: 'Local'));

      when(transactionEventsSyncDataSource.fetchActions(any)).thenAnswer(
        (_) async => [
          SyncAction.update(data: transactionLocal, dataRemoteId: transactionLocal.remoteId),
        ],
      );

      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => Future.value());
      when(transactionEventsSyncDataSource.addAction(any)).thenAnswer((_) async => Future.value());

      when(accountsLocalDataSource.fetchAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.account(remoteId: 42));

      when(transactionsNetworkDataSource.updateTransaction(any))
          .thenThrow(const StructuredBackendException(error: {'message': 'Backend error'}));

      await expectLater(
        () async => repository.updateTransaction(request).toList(),
        throwsA(isA<AppException$Simple>()),
      );

      verify(transactionsLocalDataSource.upsertTransaction(request)).called(1);
      verify(transactionEventsSyncDataSource.fetchActions(any)).called(1);
    });
  });

  group('deleteTransaction', () {
    test('emits offline then online result when transaction exists', () async {
      final transaction = MockTransactionsEntitiesHelper.transaction(123);

      when(transactionsLocalDataSource.deleteTransaction(123)).thenAnswer((_) async => transaction);
      when(transactionEventsSyncDataSource.fetchActions(any))
          .thenAnswer((_) async => [SyncAction.delete(dataId: 123, dataRemoteId: transaction.remoteId)]);
      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async {});
      when(transactionsNetworkDataSource.deleteTransaction(any)).thenAnswer((_) async {});

      final result = await repository.deleteTransaction(123).toList();

      expect(result, [
        const DataResult<void>.offline(data: null),
        const DataResult<void>.online(data: null),
      ]);
    });

    test('does not emit online if deleted transaction is null', () async {
      when(transactionsLocalDataSource.deleteTransaction(123)).thenAnswer((_) async => null);

      final result = await repository.deleteTransaction(123).toList();

      expect(result, [
        const DataResult<void>.offline(data: null),
      ]);

      verifyNever(transactionEventsSyncDataSource.fetchActions(any));
      verifyNever(transactionsNetworkDataSource.deleteTransaction(any));
    });

    test('throws AppException on RestClientException during sync', () async {
      final transaction = MockTransactionsEntitiesHelper.transaction(123);

      when(transactionsLocalDataSource.deleteTransaction(123)).thenAnswer((_) async => transaction);

      when(transactionEventsSyncDataSource.fetchActions(any)).thenAnswer(
        (_) async => [SyncAction.delete(dataId: 123, dataRemoteId: transaction.remoteId)],
      );

      when(transactionEventsSyncDataSource.removeAction(any)).thenAnswer((_) async {});

      when(transactionsNetworkDataSource.deleteTransaction(any)).thenThrow(
        const StructuredBackendException(error: {'message': 'Backend error'}),
      );

      expect(
        () => repository.deleteTransaction(123).toList(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getTransactions', () {
    test('emits offline then online list on success', () async {
      const filters = TransactionFilters(accountRemoteId: 1, accountId: 1);
      final localDetailed = [
        MockTransactionsEntitiesHelper.transactionDetails(1),
        MockTransactionsEntitiesHelper.transactionDetails(2),
      ];
      final remote = [
        MockTransactionsEntitiesHelper.transactionDetailsDto(1),
        MockTransactionsEntitiesHelper.transactionDetailsDto(2),
      ];

      when(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).thenAnswer((_) async => localDetailed);
      when(transactionsNetworkDataSource.getTransactions(filters)).thenAnswer((_) async => remote);
      when(transactionsLocalDataSource.syncTransactions(localTransactions: localDetailed, remoteTransactions: remote))
          .thenAnswer((_) async => localDetailed);

      final result = await repository.getTransactions(filters).toList();

      expect(result[0].isOffline, isTrue);
      expect(result[0].data.length, equals(2));

      expect(result[1].isOffline, isFalse);
      expect(result[1].data.length, equals(2));

      verify(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).called(1);
      verify(transactionsNetworkDataSource.getTransactions(filters)).called(1);
    });

    test('throws AppException on StructuredBackendException', () async {
      const filters = TransactionFilters(accountRemoteId: 1, accountId: 1);
      final localDetailed = [
        MockTransactionsEntitiesHelper.transactionDetails(1),
        MockTransactionsEntitiesHelper.transactionDetails(2),
      ];

      when(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).thenAnswer((_) async => localDetailed);

      when(transactionsNetworkDataSource.getTransactions(filters)).thenThrow(
        const StructuredBackendException(error: {'message': 'Backend error'}),
      );

      final stream = repository.getTransactions(filters);

      await expectLater(
        () async {
          await for (final _ in stream) {}
        },
        throwsA(isA<AppException>()),
      );

      verify(transactionsLocalDataSource.fetchTransactionsDetailed(filters)).called(1);
      verify(transactionsNetworkDataSource.getTransactions(filters)).called(1);
    });
  });

  group('getTransactionCategories', () {
    test('emits offline then online categories on success with updated data', () async {
      final localCategories = [
        MockTransactionsEntitiesHelper.category(1, name: 'Local Food'),
        MockTransactionsEntitiesHelper.category(2, name: 'Local Transport'),
      ];

      final remoteCategories = [
        MockTransactionsEntitiesHelper.category(1, name: 'Remote Food'),
        MockTransactionsEntitiesHelper.category(2, name: 'Remote Transport'),
      ];

      when(transactionsLocalDataSource.fetchTransactionCategories()).thenAnswer((_) async => localCategories);

      when(transactionsNetworkDataSource.getTransactionCategories()).thenAnswer((_) async => remoteCategories);

      when(transactionsLocalDataSource.insertTransactionCategories(remoteCategories))
          .thenAnswer((_) async => remoteCategories);

      final result = await repository.getTransactionCategories().toList();

      expect(result[0].isOffline, isTrue);
      expect(result[0].data.map((c) => c.name), containsAll(['Local Food', 'Local Transport']));

      expect(result[1].isOffline, isFalse);
      expect(result[1].data.map((c) => c.name), containsAll(['Remote Food', 'Remote Transport']));

      verify(transactionsLocalDataSource.fetchTransactionCategories()).called(1);
      verify(transactionsNetworkDataSource.getTransactionCategories()).called(1);
      verify(transactionsLocalDataSource.insertTransactionCategories(remoteCategories)).called(1);
    });

    test('throws AppException on StructuredBackendException', () async {
      const structuredException = StructuredBackendException(
        error: {'message': 'Backend error'},
        statusCode: 500,
      );

      when(transactionsLocalDataSource.fetchTransactionCategories())
          .thenAnswer((_) async => <TransactionCategory>[]);

      when(transactionsNetworkDataSource.getTransactionCategories()).thenThrow(structuredException);

      await expectLater(
        () async => repository.getTransactionCategories().toList(),
        throwsA(isA<AppException$Simple>()),
      );

      verify(transactionsLocalDataSource.fetchTransactionCategories()).called(1);
      verify(transactionsNetworkDataSource.getTransactionCategories()).called(1);
    });
  });
}
