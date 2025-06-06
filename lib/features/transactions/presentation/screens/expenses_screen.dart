import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template ExpensesScreen.class}
/// Экран отображения списка расходов
/// {@endtemplate}
@RoutePage()
class ExpensesScreen extends StatelessWidget {
  /// {@macro ExpensesScreen.class}
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Расходы'));
}
