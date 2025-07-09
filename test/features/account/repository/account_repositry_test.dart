import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yang_money_catcher/features/account/data/repository/account_repository_impl.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';

import '../../transactions/repository/transactions_test.mocks.dart';
import '../mock_entity_helper/account_entities.dart';
import 'account_repositry_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AccountsLocalDataSource>(), MockSpec<AccountsNetworkDataSource>()])
void main() {
  late AccountRepository repository;
  late AccountsLocalDataSource mockAccountsStorage;
  late TransactionsLocalDataSource mockTransactionsLocalDataSource;

  setUp(() {
    mockAccountsStorage = MockAccountsLocalDataSource();
    mockTransactionsLocalDataSource = MockTransactionsLocalDataSource();
    repository = AccountRepositoryImpl(
      accountsNetworkDataSource: MockAccountsNetworkDataSource(),
      accountsLocalStorage: mockAccountsStorage,
      transactionsLocalStorage: mockTransactionsLocalDataSource,
    );
  });

  test('Создание нового аккаунта', () async {
    final request = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountEntity = MockAccountEntitiesHelper.entityFromRequest(request);
    when(mockAccountsStorage.updateAccount(request)).thenAnswer((_) async => accountEntity);
    final account = await repository.createAccount(request).first;

    expect(account.data.name, equals(accountEntity.name));
    expect(account.data.balance, equals(account.data.balance));
  });

  test('Получение списка аккаунтов', () async {
    final firstRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final secondRequest = MockAccountEntitiesHelper.sampleCreateRequest().copyWith(name: 'B', balance: '1500');
    final firstAccountEntity = MockAccountEntitiesHelper.entityFromRequest(firstRequest);
    final secondAccountEntity = MockAccountEntitiesHelper.entityFromRequest(secondRequest, id: 2);
    when(mockAccountsStorage.updateAccount(firstRequest)).thenAnswer((_) async => firstAccountEntity);
    when(mockAccountsStorage.updateAccount(secondRequest)).thenAnswer((_) async => secondAccountEntity);
    await repository.createAccount(firstRequest).first;
    await repository.createAccount(secondRequest).first;

    when(mockAccountsStorage.fetchAccounts()).thenAnswer((_) async => [firstAccountEntity, secondAccountEntity]);
    final accounts = await repository.getAccounts().first;

    expect(accounts.data.length, equals(secondAccountEntity.id));
  });

  test('Обновление аккаунта', () async {
    final createRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountEntity = MockAccountEntitiesHelper.entityFromRequest(createRequest);
    when(mockAccountsStorage.updateAccount(createRequest)).thenAnswer((_) async => accountEntity);
    final created = await repository.createAccount(createRequest).first;

    final updateRequest = AccountRequest$Update(
      id: created.data.id,
      name: 'Updated name',
      balance: created.data.balance,
      currency: created.data.currency,
    );
    final updatedAccount = accountEntity.copyWith(name: updateRequest.name);
    when(mockAccountsStorage.updateAccount(updateRequest)).thenAnswer((_) async => updatedAccount);
    final updated = await repository.updateAccount(updateRequest).first;

    expect(updated.data.name, equals(updatedAccount.name));
  });

  test('Получение деталей аккаунта', () async {
    final createRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountEntity = MockAccountEntitiesHelper.entityFromRequest(createRequest);
    when(mockAccountsStorage.updateAccount(createRequest)).thenAnswer((_) async => accountEntity);
    final created = await repository.createAccount(createRequest).first;

    when(mockAccountsStorage.fetchAccount(accountEntity.id)).thenAnswer((_) async => accountEntity);
    when(mockTransactionsLocalDataSource.fetchTransactions(accountEntity.id)).thenAnswer((_) async => []);
    when(mockTransactionsLocalDataSource.fetchTransactionCategories()).thenAnswer((_) async => []);
    final detail = await repository.getAccountDetail(created.data.id).first;

    expect(detail.data.name, equals(accountEntity.name));
  });

  test('Получение истории аккаунта', () async {
    final request = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountEntity = MockAccountEntitiesHelper.entityFromRequest(request);
    when(mockAccountsStorage.updateAccount(request)).thenAnswer((_) async => accountEntity);
    final created = await repository.createAccount(request).first;

    when(mockAccountsStorage.fetchAccount(created.data.id)).thenAnswer((_) async => accountEntity);
    final history = await repository.getAccountHistory(created.data.id).first;

    expect(history.data.accountId, equals(created.data.id));
  });
}
