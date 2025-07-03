import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:yang_money_catcher/features/account/data/repository/account_repository_impl.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_storage.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';

import '../../transactions/repository/transactions_test.mocks.dart';
import '../mock_entity_helper/account_entities.dart';
import 'account_repositry_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AccountsLocalStorage>()])
void main() {
  late AccountRepository repository;
  late AccountsLocalStorage mockAccountsStorage;
  late TransactionsLocalDataSource mockTransactionsLocalDataSource;

  setUp(() {
    mockAccountsStorage = MockAccountsLocalStorage();
    mockTransactionsLocalDataSource = MockTransactionsLocalDataSource();
    repository = AccountRepositoryImpl(
      accountsLocalStorage: mockAccountsStorage,
      transactionsLocalStorage: mockTransactionsLocalDataSource,
    );
  });

  test('Создание нового аккаунта', () async {
    final request = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountItem = MockAccountEntitiesHelper.accountFromRequest(request);
    when(mockAccountsStorage.updateAccount(request)).thenAnswer((_) async => accountItem.id);
    when(mockAccountsStorage.fetchAccount(accountItem.id)).thenAnswer((_) async => accountItem);
    final account = await repository.createAccount(request);

    expect(account.name, equals(accountItem.name));
    expect(account.balance, equals(account.balance));
  });

  test('Получение списка аккаунтов', () async {
    final firstRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final secondRequest = MockAccountEntitiesHelper.sampleCreateRequest().copyWith(name: 'B', balance: '1500');
    final firstAccountItem = MockAccountEntitiesHelper.accountFromRequest(firstRequest);
    final secondAccountItem = MockAccountEntitiesHelper.accountFromRequest(secondRequest, id: 2);
    when(mockAccountsStorage.updateAccount(firstRequest)).thenAnswer((_) async => firstAccountItem.id);
    when(mockAccountsStorage.updateAccount(secondRequest)).thenAnswer((_) async => secondAccountItem.id);
    when(mockAccountsStorage.fetchAccount(firstAccountItem.id)).thenAnswer((_) async => firstAccountItem);
    when(mockAccountsStorage.fetchAccount(secondAccountItem.id)).thenAnswer((_) async => secondAccountItem);
    await repository.createAccount(firstRequest);
    await repository.createAccount(secondRequest);

    when(mockAccountsStorage.fetchAccounts()).thenAnswer((_) async => [firstAccountItem, secondAccountItem]);
    final accounts = await repository.getAccounts();

    expect(accounts.length, equals(secondAccountItem.id));
  });

  test('Обновление аккаунта', () async {
    final createRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountItem = MockAccountEntitiesHelper.accountFromRequest(createRequest);
    when(mockAccountsStorage.updateAccount(createRequest)).thenAnswer((_) async => 1);
    when(mockAccountsStorage.fetchAccount(accountItem.id)).thenAnswer((_) async => accountItem);
    final created = await repository.createAccount(createRequest);

    final updateRequest = AccountRequest$Update(
      id: created.id,
      name: 'Updated name',
      balance: created.balance,
      currency: created.currency,
    );
    final updatedAccount = accountItem.copyWith(name: updateRequest.name);
    when(mockAccountsStorage.updateAccount(updateRequest)).thenAnswer((_) async => accountItem.id);
    when(mockAccountsStorage.fetchAccount(accountItem.id)).thenAnswer((_) async => updatedAccount);
    final updated = await repository.updateAccount(updateRequest);

    expect(updated.name, equals(updatedAccount.name));
  });

  test('Получение деталей аккаунта', () async {
    final createRequest = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountItem = MockAccountEntitiesHelper.accountFromRequest(createRequest);
    when(mockAccountsStorage.updateAccount(createRequest)).thenAnswer((_) async => accountItem.id);
    when(mockAccountsStorage.fetchAccount(accountItem.id)).thenAnswer((_) async => accountItem);
    final created = await repository.createAccount(createRequest);

    when(mockTransactionsLocalDataSource.fetchTransactions(accountItem.id)).thenAnswer((_) async => []);
    when(mockTransactionsLocalDataSource.fetchTransactionCategories()).thenAnswer((_) async => []);
    final detail = await repository.getAccountDetail(created.id);

    expect(detail.name, equals(accountItem.name));
  });

  test('Получение истории аккаунта', () async {
    final request = MockAccountEntitiesHelper.sampleCreateRequest();
    final accountItem = MockAccountEntitiesHelper.accountFromRequest(request);
    when(mockAccountsStorage.updateAccount(request)).thenAnswer((_) async => accountItem.id);
    when(mockAccountsStorage.fetchAccount(accountItem.id)).thenAnswer((_) async => accountItem);
    final created = await repository.createAccount(request);

    final history = await repository.getAccountHistory(created.id);

    expect(history.accountId, equals(created.id));
  });
}
