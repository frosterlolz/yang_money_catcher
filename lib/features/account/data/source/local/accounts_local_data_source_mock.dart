import 'package:yang_money_catcher/features/account/data/dto/account_dto.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_history_dto.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

final class AccountsLocalDataSource$Mock implements AccountsLocalDataSource {
  final List<AccountEntity> _accounts = [];

  @override
  Future<AccountEntity?> deleteAccount(int accountId) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity?> fetchAccount(int id) {
    // TODO: implement fetchAccount
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> fetchAccounts() {
    // TODO: implement fetchAccounts
    throw UnimplementedError();
  }

  @override
  Future<int> fetchAccountsCount() {
    // TODO: implement fetchAccountsCount
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity> syncAccount(AccountEntity account) {
    // TODO: implement syncAccount
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity> syncAccountDetails(AccountDetailsDto account, {int? id}) {
    // TODO: implement syncAccountDetails
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity> syncAccountHistory(int? id, {required AccountHistoryDto accountHistory}) {
    // TODO: implement syncAccountHistory
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> syncAccounts({
    required List<AccountEntity> localAccounts,
    required List<AccountDto> remoteAccounts,
  }) {
    // TODO: implement syncAccounts
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity> updateAccount(AccountRequest request) {
    // TODO: implement updateAccount
    throw UnimplementedError();
  }

  @override
  Stream<AccountDetailEntity> watchAccountDetail(int id) {
    // TODO: implement watchAccountDetail
    throw UnimplementedError();
  }

  @override
  Stream<List<AccountEntity>> watchAccounts() {
    // TODO: implement watchAccounts
    throw UnimplementedError();
  }

  AccountEntity syncWithBriefDto(AccountBriefDto accountBrief) {
    final foundIndex = _accounts.indexWhere((account) => account.remoteId == accountBrief.id);
    if (foundIndex == -1) throw StateError('Incorrect queue while syncWithBrief trying');
    _accounts[foundIndex] = _accounts[foundIndex].copyWith(
      name: accountBrief.name,
      balance: accountBrief.balance,
      currency: accountBrief.currency,
    );

    return _accounts[foundIndex];
  }
}
