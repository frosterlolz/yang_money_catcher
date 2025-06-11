import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/repository/transaction_categories_repository.dart';

final class MockTransactionCategoriesRepository implements TransactionCategoriesRepository {
  final List<TransactionCategory> _categories = [
    const TransactionCategory(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
    const TransactionCategory(id: 2, name: 'Подарок', emoji: '🎁', isIncome: true),
    const TransactionCategory(id: 3, name: 'Продукты', emoji: '🛒', isIncome: false),
    const TransactionCategory(id: 4, name: 'Транспорт', emoji: '🚗', isIncome: false),
    const TransactionCategory(id: 5, name: 'Развлечения', emoji: '🎮', isIncome: false),
  ];

  @override
  Future<Iterable<TransactionCategory>> getTransactionCategories() async => _categories;

  @override
  Future<Iterable<TransactionCategory>> getTransactionCategoriesByType(bool isIncome) async =>
      _categories.where((category) => category.isIncome == isIncome);
}
