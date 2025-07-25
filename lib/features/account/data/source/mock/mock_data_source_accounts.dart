import 'dart:async';

import 'package:collection/collection.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

mixin MockDataSource$Accounts {
  final List<AccountEntity> _accounts = [
    AccountEntity(
      id: 1,
      remoteId: 1,
      userId: 1,
      name: 'Mock account 1',
      balance: '0.0',
      currency: Currency.rub,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final StreamController<List<AccountEntity>> _accountsListController =
      StreamController<List<AccountEntity>>.broadcast();
  final StreamController<(AccountEntity account, bool isDeleted)> _accountChangesController =
      StreamController<(AccountEntity account, bool isDeleted)>.broadcast();

  void dispose$Accounts() {
    _accountsListController.close();
    _accountChangesController.close();
  }

  List<AccountEntity> get accounts => List.of(_accounts, growable: false);

  void insertAccounts(List<AccountEntity> accounts) {
    final oldAccounts = this.accounts;
    _accounts
      ..clear()
      ..addAll(accounts);
    final newAccounts = this.accounts;
    _accountsListController.add(newAccounts);
    for (final oldAccount in oldAccounts) {
      final updatedAccount = newAccounts.firstWhereOrNull(
        (newAccount) => newAccount.id == oldAccount.id || newAccount.remoteId == oldAccount.remoteId,
      );
      if (updatedAccount == null) {
        _accountChangesController.add((oldAccount, true));
      } else {
        if (oldAccount == updatedAccount) continue;
        _accountChangesController.add((updatedAccount, false));
      }
    }
  }

  AccountEntity? findAccount(int id) => _accounts.firstWhereOrNull((e) => e.id == id);

  int upsertAccount(AccountRequest request) {
    final dtNow = DateTime.now();
    final newId = DateTime.now().millisecondsSinceEpoch;
    switch (request) {
      case AccountRequest$Create():
        final account = AccountEntity(
          id: newId,
          remoteId: null,
          name: request.name,
          balance: request.balance,
          currency: request.currency,
          createdAt: dtNow,
          updatedAt: dtNow,
          userId: 1,
        );
        _accounts.add(account);
        _accountsListController.add(_accounts);
        _accountChangesController.add((account, false));
        return newId;
      case AccountRequest$Update():
        final foundIndex = _accounts.indexWhere((e) => e.remoteId == request.id);
        if (foundIndex == -1) throw StateError('Account not found');
        _accounts[foundIndex] = _accounts[foundIndex].copyWith(
          name: request.name,
          balance: request.balance,
          currency: request.currency,
          updatedAt: dtNow,
        );
        _accountsListController.add(_accounts);
        _accountChangesController.add((_accounts[foundIndex], false));
        return _accounts[foundIndex].id;
    }
  }

  void deleteAccount(int id) {
    final account = findAccount(id);
    if (account == null) return;
    _accounts.remove(account);
    _accountsListController.add(_accounts);
    _accountChangesController.add((account, true));
  }

  Stream<List<AccountEntity>> accountsListChanges() => _accountsListController.stream;
  Stream<(AccountEntity account, bool isDeleted)> accountChanges(int id) =>
      _accountChangesController.stream.where((account) => account.$1.id == id);
}
