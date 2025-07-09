import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_history.dart';

final class AccountsNetworkDataSource$Rest implements AccountsNetworkDataSource {
  const AccountsNetworkDataSource$Rest(this._client);

  final RestClient _client;

  @override
  Future<AccountEntity> createAccount(AccountRequest$Create request) async {
    final response = await _client.post('/createAccount', body: request.toJson());
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST createAccount');
    return AccountEntity.fromJson(response);
  }

  @override
  Future<void> deleteAccount(int id) => _client.delete('/accounts/$id');

  @override
  Future<AccountDetailEntity> getAccount(int id) async {
    final response = await _client.get('/accounts/$id');
    if (response == null) throw const ClientException(message: 'Unexpected null response from GET getAccount');
    return AccountDetailEntity.fromJson(response);
  }

  @override
  Future<AccountHistory> getAccountHistory(int id) async {
    final response = await _client.get('/accounts/$id/history');
    if (response == null) throw const ClientException(message: 'Unexpected null response from GET getAccountHistory');

    return AccountHistory.fromJson(response);
  }

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final response = await _client.get('/accounts');
    final data = response?['data'];
    if (data is! JsonList) return [];
    return data.cast<JsonMap>().map(AccountEntity.fromJson).toList();
  }

  @override
  Future<AccountEntity> updateAccount(AccountRequest$Update request) async {
    final response = await _client.put('/accounts/${request.id}', body: request.toJson());
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST updateAccount');
    return AccountEntity.fromJson(response);
  }
}
