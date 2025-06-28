import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/account_selected_wrapper.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_loader_wrapper.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transactions_body_view.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template TransactionsScreen.class}
/// Параметризированный экран со списком транзакций на "сегодня"
/// {@endtemplate}
class TransactionsScreen extends StatelessWidget {
  /// {@macro TransactionsScreen.class}
  const TransactionsScreen({super.key, required this.isIncome});

  final bool isIncome;

  void _onAddTransactionTap() {
    // TODO(frosterlolz): реализовать переход на экран добавления транзакции
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(isIncome ? context.l10n.incomesToday : context.l10n.expensesToday)),
        body: AccountsLoaderWrapper(
          (accounts) => AccountSelectedWrapper(
            (account) => TransactionsBodyView(accountId: account.id, isIncome: isIncome),
            accountId: accounts.first.id,
          ),
        ),
        floatingActionButton: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) => accountState.account == null
              ? const SizedBox.shrink()
              : FloatingActionButton(
                  onPressed: _onAddTransactionTap,
                  child: const Icon(Icons.add),
                ),
        ),
      );
}
