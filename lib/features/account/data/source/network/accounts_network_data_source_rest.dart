import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

final class AccountsNetworkDataSource$Rest implements AccountsNetworkDataSource {
  const AccountsNetworkDataSource$Rest(this._client);

  final RestClient _client;

  @override
  Future<AccountEntity?> createAccount(AccountRequest$Create request) async {
    final res = await _client.post('/accounts', body: request.toJson());
    return res == null ? null : AccountEntity.fromJson(res);
  }

  @override
  Future<void> deleteAccount(int id) => _client.delete('/accounts/$id');

  @override
  Future<AccountDetailEntity?> getAccount(int id) async {
    final res = await _client.get('accounts/$id');
    return res == null ? null : AccountDetailEntity.fromJson(res);
  }

  @override
  Future<AccountHistory?> getAccountHistory(int id) async {
    final response = await _client.get('accounts/$id/history');

    return response == null ? null : AccountHistory.fromJson(response);
  }

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final response = await _client.get('/accounts');
    final data = response?['data'];
    if (data is! JsonList) return [];
    return data.cast<JsonMap>().map(AccountEntity.fromJson).toList();
  }

  @override
  Future<AccountEntity?> updateAccount(AccountRequest$Update request) async {
    final updatedAccount = await _client.put('/accounts/${request.id}', body: request.toJson());
    return updatedAccount == null ? null : AccountEntity.fromJson(updatedAccount);
  }
}
