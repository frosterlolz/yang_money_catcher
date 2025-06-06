import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template TransactionCategoriesScreen.class}
/// Экран отображения категорий транзакций
/// {@endtemplate}
@RoutePage()
class TransactionCategoriesScreen extends StatelessWidget {
  /// {@macro TransactionCategoriesScreen.class}
  const TransactionCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Статьи'));
}
