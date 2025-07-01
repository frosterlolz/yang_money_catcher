import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';

final class TransactionsDriftStorage {
  const TransactionsDriftStorage(this.database);

  final AppDatabase database;

  Future<int> deleteTransaction(int id) =>
      (database.delete(database.transactionItems)..where((t) => t.id.equals(id))).go();

  Future<List<TransactionItem>> fetchTransactions(int accountId) =>
      (database.select(database.transactionItems)..where((t) => t.account.equals(accountId))).get();

  Future<TransactionItem?> fetchTransaction(int id) =>
      (database.select(database.transactionItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateTransaction(TransactionRequest request) async {
    final now = DateTime.now();
    final companion = TransactionItemsCompanion(
      id: switch (request) {
        TransactionRequest$Create() => const Value.absent(),
        TransactionRequest$Update(:final id) => Value(id),
      },
      account: Value(request.accountId),
      category: Value(request.categoryId),
      amount: Value(request.amount),
      transactionDate: Value(request.transactionDate),
      comment: Value(request.comment),
      createdAt: Value.absentIfNull(now),
      updatedAt: Value(now),
    );

    return database.into(database.transactionItems).insertOnConflictUpdate(companion);
  }
}
