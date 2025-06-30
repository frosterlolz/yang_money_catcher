import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/presentation/screens/transactions_screen.dart';

/// {@template IncomeScreen.class}
/// Экран отображения списка доходов
/// {@endtemplate}
@RoutePage()
class IncomeScreen extends StatelessWidget {
  /// {@macro IncomeScreen.class}
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => TransactionsBloc(DependenciesScope.of(context).transactionsRepository),
        child: const TransactionsScreen(isIncome: true),
      );
}
