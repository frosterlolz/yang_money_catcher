import 'package:collection/collection.dart';
import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/dto/transaction_dto.dart';
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
    return transactionCategoryItems.map(TransactionCategory.fromTableItem).toList(growable: false);
  }

  @override
  Future<List<TransactionCategory>> insertTransactionCategories(List<TransactionCategory> transactionCategories) async {
    final transactionCategoryCompanions = transactionCategories
        .map(
          (e) => TransactionCategoryItemsCompanion.insert(
            id: Value(e.id),
            name: e.name,
            emoji: e.emoji,
            isIncome: e.isIncome,
          ),
        )
        .toList(growable: false);
    final transactionCategoryItems = await _transactionsDao.insertTransactionCategories(transactionCategoryCompanions);
    return transactionCategoryItems.map(TransactionCategory.fromTableItem).toList(growable: false);
  }

  @override
  Future<int> getTransactionsCount() => _transactionsDao.transactionRowsCount();

  @override
  Future<int?> deleteTransaction(int id) => _transactionsDao.deleteTransaction(id);

  @override
  Future<List<TransactionEntity>> fetchTransactions(int accountId) async {
    final transactionItems = await _transactionsDao.fetchTransactions(accountId);

    return transactionItems.map(TransactionEntity.fromTableItem).toList(growable: false);
  }

  @override
  Future<List<TransactionDetailEntity>> syncTransactions({
    required List<TransactionDetailEntity> localTransactions,
    required List<TransactionDetailsDto> remoteTransactions,
  }) async {
    final transactionsToUpsert = <TransactionItemsCompanion>[];
    final Map<int, AccountItemsCompanion> accountsMapToUpsert = {};

    for (final remoteTransaction in remoteTransactions) {
      final localOverlap =
          localTransactions.firstWhereOrNull((localTransaction) => localTransaction.remoteId == remoteTransaction.id);
      final transactionCompanion = TransactionItemsCompanion(
        id: localOverlap == null ? const Value.absent() : Value(localOverlap.id),
        remoteId: Value(remoteTransaction.id),
        account: localOverlap == null ? const Value.absent() : Value(localOverlap.account.id),
        category: Value(remoteTransaction.category.id),
        amount: Value(remoteTransaction.amount),
        transactionDate: Value(remoteTransaction.transactionDate),
        comment: Value(remoteTransaction.comment),
        createdAt: Value(remoteTransaction.createdAt),
        updatedAt: Value(remoteTransaction.updatedAt),
      );
      transactionsToUpsert.add(transactionCompanion);
      final remoteAccount = remoteTransaction.account;

      accountsMapToUpsert[remoteAccount.id] = AccountItemsCompanion(
        id: localOverlap == null ? const Value.absent() : Value(localOverlap.account.id),
        remoteId: Value(remoteTransaction.account.id),
        name: Value(remoteTransaction.account.name),
        balance: Value(remoteTransaction.account.balance),
        currency: Value(remoteTransaction.account.currency.key),
      );
    }

    final idSToDelete = localTransactions
        .where((local) => local.remoteId != null && !remoteTransactions.any((remote) => remote.id == local.remoteId))
        .map((local) => local.id)
        .toList(growable: false);
    await _transactionsDao.syncTransactions(
      transactionsToUpsert: transactionsToUpsert,
      transactionIdsToDelete: idSToDelete,
      accountsToUpsert: accountsMapToUpsert.values.toList(growable: false),
    );
    return fetchTransactionsDetailed(TransactionFilters(accountId: remoteTransactions.first.account.id));
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
        .toList(growable: false);
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
        .toList(growable: false);
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
            .toList(growable: false),
      );

  @override
  Future<TransactionEntity> syncTransaction(TransactionEntity transaction) {
    final companion = TransactionItemsCompanion(
      id: Value(transaction.id),
      account: Value(transaction.accountId),
      category: Value(transaction.categoryId),
      amount: Value(transaction.amount),
      transactionDate: Value(transaction.transactionDate),
      comment: Value(transaction.comment),
      updatedAt: Value(transaction.updatedAt),
    );
    return _transactionsDao.upsertTransaction(companion).then(TransactionEntity.fromTableItem);
  }

  @override
  Future<TransactionDetailEntity> syncTransactionWithDetails(
    TransactionDetailsDto transaction, {
    required int? localId,
  }) async {
    final transactionCompanion = TransactionItemsCompanion(
      id: localId == null ? const Value.absent() : Value(localId),
      remoteId: Value(transaction.id),
      category: Value(transaction.category.id),
      amount: Value(transaction.amount),
      transactionDate: Value(transaction.transactionDate),
      comment: Value(transaction.comment),
      updatedAt: Value(transaction.updatedAt),
    );
    final accountCompanion = AccountItemsCompanion(
      remoteId: Value(transaction.account.id),
      name: Value(transaction.account.name),
      balance: Value(transaction.account.balance),
      currency: Value(transaction.account.currency.key),
      updatedAt: Value(transaction.updatedAt),
    );

    final detailedValueObject =
        await _transactionsDao.upsertTransactionDetailed(transactionCompanion, accountCompanion);

    return TransactionDetailEntity.fromTableItem(
      detailedValueObject.transaction,
      accountBrief: AccountBrief.fromTableItem(detailedValueObject.account),
      category: TransactionCategory.fromTableItem(detailedValueObject.category),
    );
  }
}
