import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

abstract interface class TransactionsNetworkDataSource {
  Future<List<TransactionCategory>> getTransactionCategories([bool? isIncome]);
  Future<List<TransactionDetailsDto>> getTransactions(TransactionFilters filters);
  Future<TransactionDetailsDto> getTransaction(int id);
  Future<TransactionDto> createTransaction(TransactionRequest$Create request);
  Future<TransactionDetailsDto> updateTransaction(TransactionRequest$Update request);
  Future<void> deleteTransaction(int id);
}
