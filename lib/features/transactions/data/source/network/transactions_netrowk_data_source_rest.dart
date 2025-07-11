import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
import 'package:yang_money_catcher/features/transactions/data/source/network/transactions_network_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

class TransactionsNetworkDataSource$Rest implements TransactionsNetworkDataSource {
  const TransactionsNetworkDataSource$Rest(this._client);

  final RestClient _client;

  @override
  Future<TransactionDto> createTransaction(TransactionRequest$Create request) async {
    // удаляем union type из сериализации
    final fixedJsonRequest = request.toJson()..remove('type');
    final response = await _client.post('/transactions', body: fixedJsonRequest);
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST createTransaction');
    return TransactionDto.fromJson(response);
  }

  @override
  Future<void> deleteTransaction(int id) => _client.delete('/transactions/$id');

  @override
  Future<List<TransactionCategory>> getTransactionCategories([bool? isIncome]) async {
    final endpoint = isIncome == null ? '/categories' : '/categories/type/$isIncome';
    final response = await _client.get(endpoint);
    final data = response?['data'];
    if (data is! JsonList) return [];
    return data.cast<JsonMap>().map(TransactionCategory.fromJson).toList(growable: false);
  }

  @override
  Future<List<TransactionDetailsDto>> getTransactions(TransactionFilters filters) async {
    if (filters.accountRemoteId == null) return <TransactionDetailsDto>[];
    final transactions =
        await _client.get('/transactions/account/${filters.accountRemoteId}/period', queryParams: filters.toJson());
    final data = transactions?['data'];
    if (data is! JsonList) return [];
    return data.cast<JsonMap>().map(TransactionDetailsDto.fromJson).toList();
  }

  @override
  Future<TransactionDetailsDto> getTransaction(int id) async {
    final response = await _client.get('/transactions/$id');
    if (response == null) throw const ClientException(message: 'Unexpected null response from GET getTransaction');
    return TransactionDetailsDto.fromJson(response);
  }

  @override
  Future<TransactionDetailsDto> updateTransaction(TransactionRequest$Update request) async {
    // удаляем union type из сериализации
    final fixedJsonRequest = request.toJson()..remove('type');
    final response = await _client.put('/transactions/${request.id}', body: fixedJsonRequest);
    if (response == null) throw const ClientException(message: 'Unexpected null response from POST updateTransaction');
    return TransactionDetailsDto.fromJson(response);
  }
}
