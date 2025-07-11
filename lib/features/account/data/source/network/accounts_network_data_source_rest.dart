import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_dto.dart';
import 'package:yang_money_catcher/features/account/data/dto/account_history_dto.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';

final class AccountsNetworkDataSource$Rest implements AccountsNetworkDataSource {
  const AccountsNetworkDataSource$Rest(this._client);

  final RestClient _client;

  @override
  Future<AccountDto> createAccount(AccountRequest$Create request) async {
    // удаляем union type из сериализации
    final fixedJsonRequest = request.toJson()..remove('type');
    final response = await _client.post('/createAccount', body: fixedJsonRequest);
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST createAccount');
    return AccountDto.fromJson(response);
  }

  @override
  Future<void> deleteAccount(int id) => _client.delete('/accounts/$id');

  @override
  Future<AccountDetailsDto> getAccount(int id) async {
    final response = await _client.get('/accounts/$id');
    if (response == null) throw const ClientException(message: 'Unexpected null response from GET getAccount');
    return AccountDetailsDto.fromJson(response);
  }

  @override
  Future<AccountHistoryDto> getAccountHistory(int id) async {
    final response = await _client.get('/accounts/$id/history');
    if (response == null) throw const ClientException(message: 'Unexpected null response from GET getAccountHistory');

    return AccountHistoryDto.fromJson(response);
  }

  @override
  Future<List<AccountDto>> getAccounts() async {
    final response = await _client.get('/accounts');
    final data = response?['data'];
    if (data is! JsonList) return [];
    return data.cast<JsonMap>().map(AccountDto.fromJson).toList();
  }

  @override
  Future<AccountDto> updateAccount(AccountRequest$Update request) async {
    // удаляем union type из сериализации
    final fixedJsonRequest = request.toJson()..remove('type');
    final response = await _client.put('/accounts/${request.id}', body: fixedJsonRequest);
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST updateAccount');
    return AccountDto.fromJson(response);
  }
}
