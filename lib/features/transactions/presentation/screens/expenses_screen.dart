import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template ExpensesScreen.class}
/// Экран отображения списка расходов
/// {@endtemplate}
@RoutePage()
class ExpensesScreen extends StatelessWidget {
  /// {@macro ExpensesScreen.class}
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.expensesToday)),
        body: const Center(child: Text('Расходы')),
      );
}
