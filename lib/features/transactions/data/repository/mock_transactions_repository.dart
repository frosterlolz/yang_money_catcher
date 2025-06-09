import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

final class MockTransactionsRepository implements TransactionsRepository {
  final List<TransactionDetailEntity> _transactions = [];
  int _idCounter = 1;

  @override
  Future<TransactionEntity> createTransaction(TransactionRequest$Create request) async {
    final newTransaction = TransactionDetailEntity(
      id: _idCounter++,
      account: AccountBrief(id: request.accountId, name: 'Mock Account', balance: '12.12', currency: Currency.rub),
      category: TransactionCategory(
        id: request.categoryId,
        name: 'Mock Category',
        emoji: '📝',
        isIncome: false,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions.add(newTransaction);

    return TransactionEntity(
      id: newTransaction.id,
      accountId: newTransaction.account.id,
      categoryId: newTransaction.category.id,
      amount: newTransaction.amount,
      transactionDate: newTransaction.transactionDate,
      comment: newTransaction.comment,
      createdAt: newTransaction.createdAt,
      updatedAt: newTransaction.updatedAt,
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    _transactions.removeWhere((tx) => tx.id == id);
  }

  @override
  Future<TransactionDetailEntity> getTransaction(int id) async {
    final tx = _transactions.firstWhere((tx) => tx.id == id, orElse: () => throw Exception('Transaction not found'));
    return tx;
  }

  @override
  Future<TransactionDetailEntity> updateTransaction(TransactionRequest$Update request) async {
    final index = _transactions.indexWhere((tx) => tx.id == request.id);
    if (index == -1) throw Exception('Transaction not found');

    final existing = _transactions[index];
    final updated = existing.copyWith(
      amount: request.amount,
      comment: request.comment ?? existing.comment,
      updatedAt: DateTime.now(),
      transactionDate: request.transactionDate,
    );

    _transactions[index] = updated;
    return updated;
  }

  @override
  Future<Iterable<TransactionDetailEntity>> getTransactions({
    required int accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async =>
      _transactions.where((tx) {
        final matchesAccount = tx.account.id == accountId;
        final matchesStart = startDate == null ||
            tx.transactionDate.isAfter(startDate) ||
            tx.transactionDate.isAtSameMomentAs(startDate);
        final matchesEnd =
            endDate == null || tx.transactionDate.isBefore(endDate) || tx.transactionDate.isAtSameMomentAs(endDate);
        return matchesAccount && matchesStart && matchesEnd;
      });
}
