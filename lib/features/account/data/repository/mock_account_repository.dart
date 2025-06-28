import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

final class MockAccountRepository implements AccountRepository {
  MockAccountRepository() {
    _generateMockData();
  }

  final List<AccountEntity> _accounts = [];
  final Map<int, AccountDetailEntity> _accountDetails = {};
  final Map<int, AccountHistory> _accountHistories = {};
  int _idCounter = 1;

  @override
  Future<AccountEntity> createAccount(AccountRequest$Create request) async {
    final account = AccountEntity(
      id: _idCounter++,
      userId: 1,
      name: request.name,
      balance: request.balance,
      currency: Currency.rub,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _accounts.add(account);

    _accountDetails[account.id] = AccountDetailEntity(
      id: account.id,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      incomeStats: [],
      expenseStats: [],
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );

    _accountHistories[account.id] = AccountHistory(
      accountId: account.id,
      accountName: account.name,
      currency: account.currency,
      currencyBalance: account.balance,
      history: [],
    );

    return account;
  }

  @override
  Future<AccountDetailEntity> getAccountDetail(int accountId) async {
    final detail = _accountDetails[accountId];
    if (detail == null) {
      throw Exception('Account detail not found');
    }
    return detail;
  }

  @override
  Future<AccountHistory> getAccountHistory(int accountId) async {
    final history = _accountHistories[accountId];
    if (history == null) {
      throw Exception('Account history not found');
    }
    return history;
  }

  @override
  Future<Iterable<AccountEntity>> getAccounts() async => _accounts;

  @override
  Future<AccountEntity> updateAccount(AccountRequest$Update request) async {
    final index = _accounts.indexWhere((acc) => acc.id == request.id);
    if (index == -1) {
      throw Exception('Account not found');
    }

    final updated = _accounts[index].copyWith(
      name: request.name,
      updatedAt: DateTime.now(),
    );
    _accounts[index] = updated;

    final detail = _accountDetails[request.id];
    if (detail != null) {
      _accountDetails[request.id] = detail.copyWith(
        name: request.name,
        updatedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    _accounts.removeWhere((account) => account.id == accountId);
    return Future<void>.value();
  }

  void _generateMockData() {
    final requests = List.generate(
      10,
      (index) => AccountRequest.create(
        name: 'Transaction $index',
        balance: '100$index.00',
        currency: Currency.rub,
      ),
    ).cast<AccountRequest$Create>();
    for (final request in requests) {
      createAccount(request);
    }
  }
}
