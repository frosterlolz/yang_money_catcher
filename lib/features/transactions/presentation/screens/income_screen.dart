import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template IncomeScreen.class}
/// Экран отображения списка доходов
/// {@endtemplate}
@RoutePage()
class IncomeScreen extends StatelessWidget {
  /// {@macro IncomeScreen.class}
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.incomesToday)),
        body: const Center(child: Text('Доходы')),
      );
}
