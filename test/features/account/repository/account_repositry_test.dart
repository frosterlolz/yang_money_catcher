import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/core/domain/entity/data_result.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/features/account/data/repository/account_repository_impl.dart';
import 'package:yang_money_catcher/features/account/data/source/local/account_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

import '../../transactions/repository/transactions_test.mocks.dart';
import '../mock_entity_helper/account_entities.dart';
import 'account_repositry_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AccountsLocalDataSource>(),
  MockSpec<AccountsNetworkDataSource>(),
  MockSpec<AccountEventsSyncDataSource>(),
])
void main() {
  late AccountRepository repository;
  late MockAccountsLocalDataSource mockAccountsDataSource$Local;
  late MockTransactionsLocalDataSource mockTransactionsLocalDataSource;
  late MockAccountEventsSyncDataSource mockAccountEventsSyncDataSource;
  late MockAccountsNetworkDataSource mockAccountsDataSource$Network;

  setUp(() {
    mockAccountsDataSource$Local = MockAccountsLocalDataSource();
    mockTransactionsLocalDataSource = MockTransactionsLocalDataSource();
    mockAccountEventsSyncDataSource = MockAccountEventsSyncDataSource();
    mockAccountsDataSource$Network = MockAccountsNetworkDataSource();
    repository = AccountRepositoryImpl(
      accountsNetworkDataSource: mockAccountsDataSource$Network,
      accountsLocalStorage: mockAccountsDataSource$Local,
      transactionsLocalStorage: mockTransactionsLocalDataSource,
      accountEventsSyncDataSource: mockAccountEventsSyncDataSource,
    );
  });

  group('getAccounts', () {
    final localAccounts = [MockAccountEntitiesHelper.account(id: 1, name: 'Local', balance: '100.0')];
    final remoteAccountsDto = [MockAccountEntitiesHelper.accountDto(id: 1, name: 'Remote', balance: '200.0')];
    final syncedAccounts = [MockAccountEntitiesHelper.account(id: 1, name: 'Remote', balance: '200.0')];

    test('emits offline then online result on success', () async {
      when(mockAccountsDataSource$Local.fetchAccounts()).thenAnswer((_) async => localAccounts);
      when(mockAccountsDataSource$Network.getAccounts()).thenAnswer((_) async => remoteAccountsDto);
      when(mockAccountsDataSource$Local.syncAccounts(localAccounts: localAccounts, remoteAccounts: remoteAccountsDto))
          .thenAnswer((_) async => syncedAccounts);

      final results = await repository.getAccounts().toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data.first.name, 'Local');

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.first.name, 'Remote');
    });

    test('throws AppException on StructuredBackendException', () async {
      when(mockAccountsDataSource$Local.fetchAccounts()).thenAnswer((_) async => localAccounts);

      when(mockAccountsDataSource$Network.getAccounts()).thenThrow(
        const StructuredBackendException(
          error: {
            'message': 'Something went wrong',
          },
        ),
      );

      final stream = repository.getAccounts();

      await expectLater(
        stream,
        emitsInOrder([
          predicate<DataResult<Iterable<AccountEntity>>>(
            (result) => result.isOffline && result.data.first.name == 'Local',
            'emits offline result with local data',
          ),
          emitsError(
            predicate<Object>((error) {
              if (error is! AppException$Simple) return false;
              return error.message == 'Something went wrong';
            }),
          ),
        ]),
      );
    });
  });

  group('createAccount', () {
    test('emits offline then online result on success', () async {
      final request = MockAccountEntitiesHelper.createRequest();
      final localAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Local');
      final syncedAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Remote');

      when(mockAccountsDataSource$Local.updateAccount(request)).thenAnswer((_) async => localAccount);
      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [SyncAction.create(data: localAccount, dataRemoteId: null)]);
      when(mockAccountsDataSource$Network.createAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.accountDto(id: 10, name: 'Remote'));
      when(mockAccountsDataSource$Local.syncAccount(any)).thenAnswer((_) async => syncedAccount);
      when(mockAccountEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => {});

      final results = await repository.createAccount(request).toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data.name, 'Local');

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.name, 'Remote');
    });

    test('throws StateError if _syncActions returns null', () async {
      final request = MockAccountEntitiesHelper.createRequest();
      final localAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Local');

      when(mockAccountsDataSource$Local.updateAccount(request)).thenAnswer((_) async => localAccount);
      when(mockAccountEventsSyncDataSource.fetchEvents(any)).thenAnswer((_) async => []);

      final stream = repository.createAccount(request);

      await expectLater(
        stream,
        emitsInOrder([
          isA<DataResult<AccountEntity>>().having((r) => r.isOffline, 'isOffline', isTrue),
          emitsError(isA<StateError>()),
        ]),
      );
    });

    test('throws AppException on RestClientException during sync', () async {
      final request = MockAccountEntitiesHelper.createRequest();
      final localAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Local');

      when(mockAccountsDataSource$Local.updateAccount(request)).thenAnswer((_) async => localAccount);
      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [SyncAction.create(data: localAccount, dataRemoteId: null)]);
      when(mockAccountsDataSource$Network.createAccount(any)).thenThrow(
        const StructuredBackendException(
          error: {
            'message': 'Server error',
          },
        ),
      );

      final stream = repository.createAccount(request);

      await expectLater(
        stream,
        emitsInOrder([
          isA<DataResult<AccountEntity>>().having((r) => r.isOffline, 'isOffline', isTrue),
          emitsError(
            predicate<Object>((e) => e is AppException$Simple && e.message == 'Server error'),
          ),
        ]),
      );
    });
  });

  group('updateAccount', () {
    test('emits offline then online result on success', () async {
      final request = MockAccountEntitiesHelper.updateRequest();
      final localAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Local Updated');
      final syncedAccount = MockAccountEntitiesHelper.account(id: 1, name: 'Remote Updated');

      when(mockAccountsDataSource$Local.updateAccount(request)).thenAnswer((_) async => localAccount);

      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [SyncAction.update(data: localAccount, dataRemoteId: null)]);

      when(mockAccountsDataSource$Network.updateAccount(any))
          .thenAnswer((_) async => MockAccountEntitiesHelper.accountDto(id: 1, name: 'Remote Updated'));

      when(mockAccountsDataSource$Local.syncAccount(any)).thenAnswer((_) async => syncedAccount);

      when(mockAccountEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => {});

      final results = await repository.updateAccount(request).toList();

      expect(results[0].isOffline, isTrue);
      expect(results[0].data.name, 'Local Updated');

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.name, 'Remote Updated');
    });

    test('throws StateError if _syncActions returns null', () async {
      final request = MockAccountEntitiesHelper.updateRequest();

      when(mockAccountsDataSource$Local.updateAccount(request))
          .thenAnswer((_) async => MockAccountEntitiesHelper.account());

      when(mockAccountEventsSyncDataSource.fetchEvents(any)).thenAnswer((_) async => []);

      expect(
        () async => repository.updateAccount(request).toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('throws AppException on RestClientException during sync', () async {
      final request = MockAccountEntitiesHelper.updateRequest();
      final localAccount = MockAccountEntitiesHelper.account();

      when(mockAccountsDataSource$Local.updateAccount(request)).thenAnswer((_) async => localAccount);

      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [SyncAction.update(data: localAccount, dataRemoteId: null)]);

      when(mockAccountsDataSource$Network.updateAccount(any))
          .thenThrow(const ClientException(message: 'Network error'));

      expect(
        () async => repository.updateAccount(request).toList(),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('deleteAccount', () {
    test('emits offline then online result when account exists', () async {
      const accountId = 1;
      final localAccount = MockAccountEntitiesHelper.account(id: accountId);

      when(mockAccountsDataSource$Local.deleteAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [const SyncAction.delete(dataId: accountId, dataRemoteId: accountId)]);

      when(mockAccountsDataSource$Network.deleteAccount(any)).thenAnswer((_) async => {});
      when(mockAccountsDataSource$Local.syncAccount(any)).thenAnswer((_) async => localAccount);
      when(mockAccountEventsSyncDataSource.removeAction(any)).thenAnswer((_) async => {});

      final results = await repository.deleteAccount(accountId).toList();

      expect(results.length, 2);
      expect(results[0].isOffline, isTrue);
      expect(results[1].isOffline, isFalse);
    });

    test('does not emit online if deleted account is null', () async {
      const accountId = 1;

      when(mockAccountsDataSource$Local.deleteAccount(accountId)).thenAnswer((_) async => null);

      final results = await repository.deleteAccount(accountId).toList();

      expect(results.length, 1);
      expect(results[0].isOffline, isTrue);
    });

    test('throws AppException on RestClientException during sync', () async {
      const accountId = 1;
      final localAccount = MockAccountEntitiesHelper.account(id: accountId);

      when(mockAccountsDataSource$Local.deleteAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountEventsSyncDataSource.fetchEvents(any))
          .thenAnswer((_) async => [const SyncAction.delete(dataId: accountId, dataRemoteId: accountId)]);

      when(mockAccountsDataSource$Network.deleteAccount(any)).thenThrow(const ClientException(message: 'error'));

      expect(
        () => repository.deleteAccount(accountId).toList(),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('getAccountDetail', () {
    const accountId = 1;
    final localAccount = MockAccountEntitiesHelper.account(id: accountId, remoteId: 10);
    final accountDetailDto = MockAccountEntitiesHelper.accountDetailsDto(10);
    final syncedAccount = MockAccountEntitiesHelper.account(id: 10);

    test('emits offline then online detail on success', () async {
      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountsDataSource$Network.getAccount(localAccount.remoteId)).thenAnswer((_) async => accountDetailDto);

      when(mockAccountsDataSource$Local.syncAccountDetails(accountDetailDto, id: accountId))
          .thenAnswer((_) async => syncedAccount);

      final results = await repository.getAccountDetail(accountId).toList();

      expect(results.length, 2);
      expect(results[0].isOffline, isTrue);
      expect(results[0].data.id, localAccount.id);

      expect(results[1].isOffline, isFalse);
      expect(results[1].data.id, syncedAccount.id);
    });

    test('throws StateError if local account has no remoteId', () async {
      final localAccountNoRemote = MockAccountEntitiesHelper.account(id: accountId, remoteId: null);

      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => localAccountNoRemote);

      expect(
        () => repository.getAccountDetail(accountId).toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StateError if local account is null', () async {
      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => null);

      expect(
        () => repository.getAccountDetail(accountId).toList(),
        throwsA(isA<StateError>()),
      );
    });

    test('throws AppException on StructuredBackendException', () async {
      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountsDataSource$Network.getAccount(localAccount.remoteId)).thenThrow(
        const StructuredBackendException(
          error: {
            'message': 'Backend error',
          },
        ),
      );

      expect(
        () => repository.getAccountDetail(accountId).toList(),
        throwsA(isA<AppException$Simple>()),
      );
    });
  });

  group('getAccountHistory', () {
    test('emits offline then online history on success', () async {
      const accountId = 1;
      final localAccount = MockAccountEntitiesHelper.account(id: accountId);
      final accountHistoryDto = MockAccountEntitiesHelper.accountHistoryDto(accountId);
      final syncedAccount = MockAccountEntitiesHelper.account(id: accountId);

      when(mockAccountEventsSyncDataSource.fetchEvents(any)).thenAnswer((_) async => []);

      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountsDataSource$Network.getAccountHistory(accountId)).thenAnswer((_) async => accountHistoryDto);

      when(mockAccountsDataSource$Local.syncAccountHistory(localAccount.id, accountHistory: accountHistoryDto))
          .thenAnswer((_) async => syncedAccount);

      final results = await repository.getAccountHistory(accountId).toList();

      expect(results.length, 2);

      expect(results[0].isOffline, isTrue);
      expect(results[0].data, isA<AccountHistory>());
      expect(results[0].data.accountId, accountId);

      expect(results[1].isOffline, isFalse);
      expect(results[1].data, isA<AccountHistory>());
      expect(results[1].data.accountId, accountId);
    });

    test('throws AppException on StructuredBackendException', () async {
      const accountId = 1;
      final localAccount = MockAccountEntitiesHelper.account(id: accountId);

      when(mockAccountEventsSyncDataSource.fetchEvents(any)).thenAnswer((_) async => []);

      when(mockAccountsDataSource$Local.fetchAccount(accountId)).thenAnswer((_) async => localAccount);

      when(mockAccountsDataSource$Network.getAccountHistory(accountId)).thenThrow(
        const StructuredBackendException(
          error: {
            'message': 'Backend error',
          },
        ),
      );

      expect(
        () => repository.getAccountHistory(accountId).toList(),
        throwsA(isA<AppException$Simple>()),
      );
    });
  });

  group('watchAccounts', () {
    test('returns stream from local data source', () async {
      final accounts = [
        MockAccountEntitiesHelper.account(id: 1, name: 'Account 1'),
        MockAccountEntitiesHelper.account(id: 2, name: 'Account 2'),
      ];

      when(mockAccountsDataSource$Local.watchAccounts()).thenAnswer((_) => Stream.value(accounts));

      final stream = repository.watchAccounts();

      final emitted = await stream.first;

      expect(emitted, accounts);
    });
  });
}
