import 'package:flutter_test/flutter_test.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/mock_transactions_repository.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';

void main() {
  late MockTransactionsRepository repository;

  setUp(() {
    repository = MockTransactionsRepository();
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

    expect(tx.id, equals(1));
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

    expect(detail.id, equals(created.id));
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

    expect(() => repository.getTransaction(created.id), throwsException);
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

    final result = await repository.getTransactions(
      accountId: 1,
      startDate: now.subtract(const Duration(days: 1)),
    );

    expect(result.length, equals(1));
    expect(result.first.comment, equals('New'));
  });
}
