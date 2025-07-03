import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionItems, TransactionCategoryItems])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  Future<int> transactionCategoryRowsCount() => transactionCategoryItems.count().getSingle();
  Future<List<TransactionCategoryItem>> fetchTransactionCategories() => transactionCategoryItems.select().get();

  Future<void> insertTransactionCategories(List<TransactionCategoryItemsCompanion> transactionCategoryCompanions) =>
      transactionCategoryItems.insertAll(transactionCategoryCompanions);

  Future<int> transactionRowsCount() => transactionItems.count().getSingle();

  Future<List<TransactionItem>> fetchTransactions(int accountId) {
    final transactionsStatement = select(transactionItems)..where((tx) => tx.account.equals(accountId));

    return transactionsStatement.get();
  }

  Future<List<TransactionDetailedValueObject>> fetchTransactionsDetailed(
    int accountId, {
    bool? isIncome,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactionsWithRefs = await attachedDatabase.managers.transactionItems
        .withReferences((prefetch) => prefetch(category: true, account: true))
        .filter(
      (f) {
        final filtersList = [
          f.account.id.equals(accountId),
          if (startDate != null) f.transactionDate.isAfterOrOn(startDate),
          if (endDate != null) f.transactionDate.isBeforeOrOn(endDate),
          if (isIncome != null) f.category.isIncome.equals(isIncome),
        ];

        return Expression.and(filtersList);
      },
    ).get();

    return transactionsWithRefs
        .map(
          (transactionsWithRefs) => TransactionDetailedValueObject(
            transaction: transactionsWithRefs.$1,
            category: transactionsWithRefs.$2.category.prefetchedData?.singleOrNull,
            account: transactionsWithRefs.$2.account.prefetchedData?.singleOrNull,
          ),
        )
        .toList();
  }

  Future<TransactionDetailedValueObject?> fetchTransaction(int id) async {
    final transactionItem = await attachedDatabase.managers.transactionItems
        .withReferences((prefetch) => prefetch(account: true, category: true))
        .filter((f) => f.id.equals(id))
        .getSingleOrNull();
    if (transactionItem == null) return null;
    return TransactionDetailedValueObject(
      transaction: transactionItem.$1,
      category: transactionItem.$2.category.prefetchedData?.singleOrNull,
      account: transactionItem.$2.account.prefetchedData?.singleOrNull,
    );
  }

  Future<void> insertTransactions(List<TransactionItemsCompanion> companions) => transactionItems.insertAll(companions);

  Future<TransactionItem> upsertTransaction(TransactionItemsCompanion companion) async =>
      companion.id.present ? _updateTransaction(companion) : _insertTransaction(companion);

  Future<TransactionItem> _insertTransaction(TransactionItemsCompanion companion) async =>
      into(transactionItems).insertReturning(companion);

  Future<TransactionItem> _updateTransaction(TransactionItemsCompanion companion) async => transaction(() async {
        final statement = update(transactionItems)..where((tx) => tx.id.equals(companion.id.value));
        final updatedRowId = await statement.write(companion);
        final updatedTransaction = select(transactionItems)..where((tx) => tx.rowId.equals(updatedRowId));
        return updatedTransaction.getSingle();
      });

  Future<int> deleteTransaction(int id) => (delete(transactionItems)..where((t) => t.id.equals(id))).go();

  Stream<List<TransactionDetailedValueObject>> transactionDetailedListChanges(
    int accountId, {
    bool? isIncome,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    final query = attachedDatabase.managers.transactionItems
        .withReferences((prefetched) => prefetched(category: true, account: true))
        .filter((f) {
      final filters = <Expression<bool>>[
        f.account.id.equals(accountId),
        if (startDate != null) f.transactionDate.isAfterOrOn(startDate),
        if (endDate != null) f.transactionDate.isBeforeOrOn(endDate),
        if (isIncome != null) f.category.isIncome.equals(isIncome),
      ];
      return Expression.and(filters);
    });

    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }

    return query.watch().map(
          (transactionsWithRefs) => transactionsWithRefs
              .map(
                (transactionWithRefs) => TransactionDetailedValueObject(
                  transaction: transactionWithRefs.$1,
                  category: transactionWithRefs.$2.category.prefetchedData?.singleOrNull,
                  account: transactionWithRefs.$2.account.prefetchedData?.singleOrNull,
                ),
              )
              .toList(),
        );
  }

  Stream<TransactionDetailedValueObject?> transactionChanges(int id) {
    final query = attachedDatabase.managers.transactionItems
        .withReferences((prefetched) => prefetched(category: true, account: true))
        .filter((f) => f.id.equals(id));

    return query.watchSingleOrNull().map(
          (transactionWithRefs) => transactionWithRefs != null
              ? TransactionDetailedValueObject(
                  transaction: transactionWithRefs.$1,
                  category: transactionWithRefs.$2.category.prefetchedData?.singleOrNull,
                  account: transactionWithRefs.$2.account.prefetchedData?.singleOrNull,
                )
              : null,
        );
  }
}
