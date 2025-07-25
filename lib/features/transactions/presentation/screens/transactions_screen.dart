import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/account_selected_wrapper.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_loader_wrapper.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transactions_body_view.dart';

/// {@template TransactionsScreen.class}
/// Параметризированный экран со списком транзакций на "сегодня"
/// {@endtemplate}
class TransactionsScreen extends StatelessWidget {
  /// {@macro TransactionsScreen.class}
  const TransactionsScreen({super.key, required this.isIncome});

  final bool isIncome;

  void _onAddTransactionTap(BuildContext context) {
    context.read<SettingsBloc>().state.settings.hapticType.play();
    showTransactionScreen(context, isIncome: isIncome);
  }

  void _onTransactionsHistoryTap(BuildContext context, {required int accountId}) {
    context.pushRoute(TransactionsHistoryRoute(isIncome: isIncome, accountId: accountId));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(isIncome ? context.l10n.incomesToday : context.l10n.expensesToday),
          actions: [
            BlocSelector<AccountBloc, AccountState, int?>(
              selector: (state) => state.account?.id,
              builder: (context, accountId) => accountId == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: () => _onTransactionsHistoryTap(context, accountId: accountId),
                      icon: const Icon(Icons.history),
                    ),
            ),
          ],
        ),
        body: AccountsLoaderWrapper(
          (accounts) => AccountSelectedWrapper(
            (account) => TransactionsBodyView(account: account, isIncome: isIncome),
            accountId: accounts.first.id,
          ),
        ),
        floatingActionButton: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) => accountState.account == null
              ? const SizedBox.shrink()
              : FloatingActionButton(
                  key: Key(isIncome ? 'fab_income' : 'fab_expense'),
                  heroTag: 'hero_add_transaction_isIncome_$isIncome',
                  onPressed: () => _onAddTransactionTap(context),
                  child: const Icon(Icons.add),
                ),
        ),
      );
}
