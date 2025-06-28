import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/account/di/accounts_scope.dart';
import 'package:yang_money_catcher/features/app/presentation/app_material.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transactions/di/transactions_scope.dart';

class App extends StatelessWidget {
  const App(this.result, {super.key});

  final InitializationResult result;

  @override
  Widget build(BuildContext context) => DependenciesScope(
        dependencies: result.dependencies,
        child: AccountsScope(
          accountRepository: result.dependencies.accountRepository,
          child: TransactionsScope(
            transactionsRepository: result.dependencies.transactionsRepository,
            child: const AppMaterial(),
          ),
        ),
      );
}
