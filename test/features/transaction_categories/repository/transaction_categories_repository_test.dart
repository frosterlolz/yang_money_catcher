import 'package:flutter_test/flutter_test.dart';
import 'package:yang_money_catcher/features/transaction_categories/data/repository/mock_transaction_repository.dart';

void main() {
  late MockTransactionCategoriesRepository repository;

  setUp(() {
    repository = MockTransactionCategoriesRepository();
  });

  test('Получение всех категорий', () async {
    final categories = await repository.getTransactionCategories();
    expect(categories.length, greaterThan(0));
  });

  test('Получение только доходных категорий', () async {
    final income = await repository.getTransactionCategoriesByType(true);
    expect(income.every((cat) => cat.isIncome), isTrue);
  });

  test('Получение только расходных категорий', () async {
    final expense = await repository.getTransactionCategoriesByType(false);
    expect(expense.every((cat) => !cat.isIncome), isTrue);
  });
}
