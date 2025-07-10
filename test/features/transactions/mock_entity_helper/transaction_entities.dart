import 'package:database/database.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

abstract class MockTransactionsEntitiesHelper {
  static TransactionRequest$Create sampleCreateRequest() => TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '500',
        transactionDate: DateTime.now(),
        comment: 'Test',
      );

  static TransactionItem sampleTransactionItem() => TransactionItem(
        id: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        account: 1,
        category: 1,
        amount: '500',
        transactionDate: DateTime.now(),
        comment: 'Test',
      );

  static TransactionItem tableItemFromRequest(TransactionRequest request, {int id = 1}) => TransactionItem(
        id: switch (request) {
          TransactionRequest$Create() => id,
          TransactionRequest$Update(:final id) => id,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        account: request.accountId,
        category: request.categoryId,
        amount: request.amount,
        transactionDate: request.transactionDate,
        comment: request.comment,
      );

  static TransactionEntity entityFromRequest(TransactionRequest request, {int id = 1}) => TransactionEntity(
        id: switch (request) {
          TransactionRequest$Create() => id,
          TransactionRequest$Update(:final id) => id,
        },
        remoteId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        accountId: 1,
        categoryId: 1,
        amount: request.amount,
        transactionDate: request.transactionDate,
        comment: request.comment,
      );

  static TransactionDetailEntity detailedEntityFromRequest(TransactionRequest request, {int id = 1}) =>
      TransactionDetailEntity(
        id: switch (request) {
          TransactionRequest$Create() => id,
          TransactionRequest$Update(:final id) => id,
        },
        remoteId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        account: const AccountBrief(id: 1, name: '', balance: '', currency: Currency.rub),
        category: const TransactionCategory(id: 1, name: '', emoji: '', isIncome: true),
        amount: request.amount,
        transactionDate: request.transactionDate,
        comment: request.comment,
      );
}
