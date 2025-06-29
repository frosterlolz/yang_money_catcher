import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/features/app/presentation/app_material.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/bloc/transaction_categories_bloc/transaction_categories_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';

class App extends StatelessWidget {
  const App(this.result, {super.key});

  final InitializationResult result;

  @override
  Widget build(BuildContext context) => DependenciesScope(
        dependencies: result.dependencies,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AccountsBloc(result.dependencies.accountRepository)..add(const AccountsEvent.load()),
            ),
            BlocProvider(create: (_) => AccountBloc(result.dependencies.accountRepository)),
            BlocProvider(
              create: (_) => TransactionCategoriesBloc(result.dependencies.transactionsRepository)
                ..add(const TransactionCategoriesEvent.load()),
            ),
            BlocProvider(create: (_) => TransactionsBloc(result.dependencies.transactionsRepository)),
          ],
          child: const AppMaterial(),
        ),
      );
}
