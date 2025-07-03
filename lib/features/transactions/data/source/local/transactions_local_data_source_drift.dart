import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

final class TransactionsLocalDataSource$Drift implements TransactionsLocalDataSource {
  const TransactionsLocalDataSource$Drift(this._transactionsDao);

  final TransactionsDao _transactionsDao;

  @override
  Future<int> transactionCategoriesCount() async => _transactionsDao.transactionCategoryRowsCount();

  @override
  Future<List<TransactionCategory>> fetchTransactionCategories() async {
    final transactionCategoryItems = await _transactionsDao.fetchTransactionCategories();
    return transactionCategoryItems.map(TransactionCategory.fromTableItem).toList();
  }

  @override
  Future<void> insertTransactionCategories(List<TransactionCategory> transactionCategories) async {
    final transactionCategoryCompanions = transactionCategories
        .map(
          (e) => TransactionCategoryItemsCompanion.insert(
            id: Value(e.id),
            name: e.name,
            emoji: e.emoji,
            isIncome: e.isIncome,
          ),
        )
        .toList();
    await _transactionsDao.insertTransactionCategories(transactionCategoryCompanions);
  }

  @override
  Future<int> getTransactionsCount() => _transactionsDao.transactionRowsCount();

  @override
  Future<int> deleteTransaction(int id) => _transactionsDao.deleteTransaction(id);

  @override
  Future<List<TransactionEntity>> fetchTransactions(int accountId) async {
    final transactionItems = await _transactionsDao.fetchTransactions(accountId);

    return transactionItems.map(TransactionEntity.fromTableItem).toList();
  }

  @override
  Future<List<TransactionDetailEntity>> fetchTransactionsDetailed(TransactionFilters filters) async {
    final transactionValueObjects = await _transactionsDao.fetchTransactionsDetailed(
      filters.accountId,
      startDate: filters.startDate,
      endDate: filters.endDate,
      isIncome: filters.isIncome,
    );

    return transactionValueObjects
        .map(
          (transactionValueObject) => TransactionDetailEntity.fromTableItem(
            transactionValueObject.transaction,
            accountBrief: AccountBrief.fromTableItem(transactionValueObject.account),
            category: TransactionCategory.fromTableItem(transactionValueObject.category),
          ),
        )
        .toList();
  }

  @override
  Future<TransactionDetailEntity?> fetchTransaction(int id) async {
    final transactionItem = await _transactionsDao.fetchTransaction(id);
    if (transactionItem == null) return null;
    return TransactionDetailEntity.fromTableItem(
      transactionItem.transaction,
      accountBrief: AccountBrief.fromTableItem(transactionItem.account),
      category: TransactionCategory.fromTableItem(transactionItem.category),
    );
  }

  @override
  Future<void> insertTransactions(List<TransactionRequest$Create> requests) async {
    final companions = requests
        .map(
          (e) => TransactionItemsCompanion.insert(
            account: e.accountId,
            category: e.categoryId,
            amount: e.amount,
            transactionDate: e.transactionDate,
            comment: Value(e.comment),
          ),
        )
        .toList();
    await _transactionsDao.insertTransactions(companions);
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionRequest request) async {
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
      updatedAt: Value(now),
    );
    final updatedTransaction = await _transactionsDao.upsertTransaction(companion);

    return TransactionEntity.fromTableItem(updatedTransaction);
  }

  @override
  Stream<TransactionDetailEntity?> transactionChanges(int id) => _transactionsDao.transactionChanges(id).map(
        (transactionDetailed) => transactionDetailed == null
            ? null
            : TransactionDetailEntity.fromTableItem(
                transactionDetailed.transaction,
                accountBrief: AccountBrief.fromTableItem(transactionDetailed.account),
                category: TransactionCategory.fromTableItem(transactionDetailed.category),
              ),
      );

  @override
  Stream<List<TransactionDetailEntity>> transactionsListChanges(TransactionFilters filters) => _transactionsDao
      .transactionDetailedListChanges(
        filters.accountId,
        startDate: filters.startDate,
        endDate: filters.endDate,
        isIncome: filters.isIncome,
      )
      .map(
        (transactionItems) => transactionItems
            .map(
              (transactionItem) => TransactionDetailEntity.fromTableItem(
                transactionItem.transaction,
                category: TransactionCategory.fromTableItem(transactionItem.category),
                accountBrief: AccountBrief.fromTableItem(transactionItem.account),
              ),
            )
            .toList(),
      );
}
