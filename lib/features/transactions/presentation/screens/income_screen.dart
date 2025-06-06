import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template IncomeScreen.class}
/// Экран отображения списка доходов
/// {@endtemplate}
@RoutePage()
class IncomeScreen extends StatelessWidget {
  /// {@macro IncomeScreen.class}
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Доходы'));
}
