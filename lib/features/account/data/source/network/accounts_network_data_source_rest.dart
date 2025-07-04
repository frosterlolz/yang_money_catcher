import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

final class AccountsNetworkDataSource$Rest implements AccountsNetworkDataSource {
  @override
  Future<AccountEntity> createAccount(AccountRequest$Create request) {
    // TODO(frosterlolz): implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(int id) {
    // TODO(frosterlolz): implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<AccountDetailEntity> getAccount(int id) {
    // TODO(frosterlolz): implement getAccount
    throw UnimplementedError();
  }

  @override
  Future<AccountHistory> getAccountHistory(int id) {
    // TODO(frosterlolz): implement getAccountHistory
    throw UnimplementedError();
  }

  @override
  Future<List<AccountEntity>> getAccounts() {
    // TODO(frosterlolz): implement getAccounts
    throw UnimplementedError();
  }

  @override
  Future<AccountEntity> updateAccount(AccountRequest$Update request) {
    // TODO(frosterlolz): implement updateAccount
    throw UnimplementedError();
  }
}
