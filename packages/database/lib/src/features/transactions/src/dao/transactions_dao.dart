import 'package:database/database.dart';
import 'package:drift/drift.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionItems, TransactionCategoryItems, AccountItems])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  Future<int> transactionCategoryRowsCount() => transactionCategoryItems.count().getSingle();

  Future<void> syncTransactions({
    required List<TransactionItemsCompanion> transactionsToUpsert,
    required List<int> transactionIdsToDelete,
    required List<AccountItemsCompanion> accountsToUpsert,
    required Map<int, int> txAccountRemoteIdMap,
  }) async {
    await transaction(() async {
      // 1. Обновляем аккаунты по remoteId (если они уже существуют)
      for (final acc in accountsToUpsert) {
        final remoteId = acc.remoteId.value;
        if (remoteId == null) continue;

        await (update(accountItems)..where((tbl) => tbl.remoteId.equals(remoteId))).write(acc);
      }

      // 2. Получаем обновлённые аккаунты из базы, чтобы достать их локальные id
      final updatedRemoteIds = accountsToUpsert.map((acc) => acc.remoteId.value).whereType<int>().toSet().toList();

      final existingAccounts = await (select(accountItems)..where((tbl) => tbl.remoteId.isIn(updatedRemoteIds))).get();

      final remoteToLocalAccountId = {
        for (final acc in existingAccounts) acc.remoteId: acc.id,
      };

      // 3. Подставляем правильный accountId в каждую транзакцию
      final transactionsWithAccount = transactionsToUpsert.map((tx) {
        final remoteTxId = tx.remoteId.value;
        final remoteAccountId = txAccountRemoteIdMap[remoteTxId];

        if (remoteAccountId == null) {
          throw Exception('Missing remoteAccountId for transaction $remoteTxId');
        }

        final localAccountId = remoteToLocalAccountId[remoteAccountId];

        if (localAccountId == null) {
          throw Exception('No local account for remoteAccountId $remoteAccountId');
        }

        return tx.copyWith(account: Value(localAccountId));
      }).toList();

      // 4. Выполняем удаление и вставку транзакций
      await batch((batch) {
        if (transactionIdsToDelete.isNotEmpty) {
          batch.deleteWhere(transactionItems, (tbl) => tbl.id.isIn(transactionIdsToDelete));
        }

        if (transactionsWithAccount.isNotEmpty) {
          for (final txItem in transactionsWithAccount) {
            final txRemoteId = txItem.remoteId.value;
            if (txRemoteId == null) continue;
            if (txItem.id.present) {
              batch.insert(transactionItems, txItem, onConflict: DoUpdate((_) => txItem));
            } else {
              batch.update(transactionItems, txItem, where: (tbl) => tbl.remoteId.equals(txRemoteId));
            }
          }
        }
      });
    });
  }

  Future<List<TransactionCategoryItem>> fetchTransactionCategories() => transactionCategoryItems.select().get();

  Future<List<TransactionCategoryItem>> insertTransactionCategories(List<TransactionCategoryItemsCompanion> items) =>
      transaction(() async {
        await transactionCategoryItems.deleteAll();

        if (items.isNotEmpty) {
          await batch((b) => b.insertAll(transactionCategoryItems, items));
        }

        return transactionCategoryItems.select().get();
      });

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

  Future<TransactionDetailedValueObject> syncTransactionDetailed(
    TransactionItemsCompanion transactionCompanion,
    AccountItemsCompanion accountCompanion,
  ) async =>
      transaction(() async {
        final accountRemoteId = accountCompanion.remoteId.value ?? (throw StateError('Account remoteId is null'));
        final transactionRemoteId =
            transactionCompanion.remoteId.value ?? (throw StateError('Transaction remoteId is null'));
        // 1. Обновляем аккаунт по remoteId, если найден
        final rowsCount =
            await (update(accountItems)..where((a) => a.remoteId.equals(accountRemoteId))).write(accountCompanion);
        if (rowsCount == 0) throw StateError('Account from transaction could not be updated');

        // 2. Получаем локальный id аккаунта по его remoteId
        final account =
            await (select(accountItems)..where((a) => a.remoteId.equals(accountRemoteId))).getSingleOrNull();
        if (account == null) throw StateError('Account with remoteId=$accountRemoteId not found after update');

        // 3. Обновляем TransactionItemsCompanion, чтобы он ссылался на нужный локальный account.id
        final updatedTransactionCompanion = transactionCompanion.copyWith(
          account: Value(account.id),
        );

        // 4. Вставляем/обновляем транзакцию
        if (updatedTransactionCompanion.id.present) {
          await transactionItems.insertOnConflictUpdate(updatedTransactionCompanion);
        } else {
          await (transactionItems.update()..where((table) => table.remoteId.equals(transactionRemoteId)))
              .write(updatedTransactionCompanion);
        }

        // 5. Получаем связанную категорию

        final txItemWithRefs = await attachedDatabase.managers.transactionItems
            .withReferences((prefetch) => prefetch(account: true, category: true))
            .filter((table) => table.remoteId.equals(transactionRemoteId))
            .getSingleOrNull();

        if (txItemWithRefs == null) throw StateError('TransactionItem with remoteId $transactionRemoteId not found');

        return TransactionDetailedValueObject(
          transaction: txItemWithRefs.$1,
          account: txItemWithRefs.$2.account.prefetchedData?.singleOrNull,
          category: txItemWithRefs.$2.category.prefetchedData?.singleOrNull,
        );
      });

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

  /// Возвращает удаленную транзакцию
  Future<TransactionItem?> deleteTransaction(int id) async => transaction(() async {
        final transaction = await (select(transactionItems)..where((t) => t.id.equals(id))).getSingleOrNull();
        await (delete(transactionItems)..where((t) => t.id.equals(id))).go();
        return transaction;
      });

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
