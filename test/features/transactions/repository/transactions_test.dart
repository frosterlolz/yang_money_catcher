import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/mock_transactions_repository.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

void main() {
  late TransactionsLocalDataSource transactionsLocalDataSource;
  late MockTransactionsRepository repository;

  setUp(() {
    transactionsLocalDataSource = TransactionsLocalDataSource();
    repository = MockTransactionsRepository(transactionsLocalDataSource);
  });

  test('Создание новой транзакции', () async {
    final tx = await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '500',
        transactionDate: DateTime.now(),
        comment: 'Test',
      ),
    );

    expect(tx.categoryId, equals(1));
    expect(tx.amount, equals('500'));
  });

  test('Получение транзакции по ID', () async {
    final created = await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '100',
        transactionDate: DateTime.now(),
        comment: 'Get Test',
      ),
    );

    final detail = await repository.getTransaction(created.id);

    expect(detail?.id, equals(created.id));
  });

  test('Обновление транзакции', () async {
    final created = await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '200',
        transactionDate: DateTime.now(),
        comment: 'Update Test',
      ),
    );

    final updated = await repository.updateTransaction(
      TransactionRequest$Update(
        id: created.id,
        accountId: 1,
        categoryId: 1,
        transactionDate: DateTime.now(),
        amount: '999',
        comment: 'Updated',
      ),
    );

    expect(updated.amount, equals('999'));
    expect(updated.comment, equals('Updated'));
  });

  test('Удаление транзакции', () async {
    final created = await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '300',
        transactionDate: DateTime.now(),
        comment: 'Delete Test',
      ),
    );

    await repository.deleteTransaction(created.id);

    final deleted = await repository.getTransaction(created.id);

    expect(deleted, isNull);
  });

  test('Получение транзакций по accountId и дате', () async {
    final now = DateTime.now();

    await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '150',
        transactionDate: now.subtract(const Duration(days: 5)),
        comment: 'Old',
      ),
    );

    await repository.createTransaction(
      TransactionRequest$Create(
        accountId: 1,
        categoryId: 1,
        amount: '250',
        transactionDate: now,
        comment: 'New',
      ),
    );

    final filters = TransactionFilters(accountId: 1, startDate: now.subtract(const Duration(days: 1)));
    final result = await repository.getTransactions(filters);

    expect(result.length, equals(1));
    final found = result.firstWhereOrNull((tx) => tx.comment == 'New');
    expect(found, isNotNull);
    expect(found!.amount, equals('250'));
  });
}
