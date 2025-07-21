import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/core/utils/extensions/date_time_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/presentation/screens/transaction_screen.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';

/// {@template TransactionsView.class}
/// Тело экрана со списком транзакций
/// {@endtemplate}
class TransactionsBodyView extends StatefulWidget {
  /// {@macro TransactionsView.class}
  const TransactionsBodyView({super.key, required this.isIncome, required this.account});

  final bool isIncome;
  final AccountDetailEntity account;

  @override
  State<TransactionsBodyView> createState() => _TransactionsBodyViewState();
}

class _TransactionsBodyViewState extends State<TransactionsBodyView> {
  @override
  void initState() {
    super.initState();
    final transactionsBloc = context.read<TransactionsBloc>();
    if (transactionsBloc.state is TransactionsState$Processing) {
      _loadTransactions(context).ignore();
    }
  }

  Future<void> _loadTransactions(BuildContext context) async {
    final dtNow = DateTime.now();
    final start = dtNow.copyWithStartOfDayTme;
    final end = dtNow.copyWithEndOfDayTme;
    final filters = TransactionFilters(
      accountId: widget.account.id,
      accountRemoteId: widget.account.remoteId,
      startDate: start,
      endDate: end,
      isIncome: widget.isIncome,
    );
    final transactionsBloc = context.read<TransactionsBloc>()..add(TransactionsEvent.load(filters));
    await transactionsBloc.stream.firstWhere((state) => state is! TransactionsState$Processing);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, transactionsState) {
          final transactions = transactionsState.transactions;
          return switch (transactionsState) {
            _ when transactions != null => _TransactionsListView(
                transactions: transactions,
                isIncome: widget.isIncome,
                total: transactionsState.totalAmount,
                onRefresh: _loadTransactions,
              ),
            AccountState$Error(:final error) =>
              ErrorBodyView.fromError(error, onRetryTap: () => _loadTransactions(context)),
            _ => const LoadingBodyView(),
          };
        },
      );
}

/// {@template _TransactionsBodyView.class}
/// _TransactionsBodyView widget.
/// {@endtemplate}
class _TransactionsListView extends StatelessWidget {
  /// {@macro _TransactionsBodyView.class}
  const _TransactionsListView({
    required this.isIncome,
    required this.transactions,
    required this.onRefresh,
    required this.total,
  });

  final bool isIncome;
  final num total;
  final List<TransactionDetailEntity> transactions;
  final Future<void> Function(BuildContext context) onRefresh;

  void _onTransactionTap(BuildContext context, TransactionDetailEntity transaction) {
    showTransactionScreen(context, isIncome: transaction.category.isIncome, initialTransaction: transaction);
    // context.pushRoute(TransactionRoute(isIncome: isIncome, initialTransaction: transaction));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return RefreshIndicator.adaptive(
      onRefresh: () => onRefresh(context),
      child: CustomScrollView(
        slivers: [
          if (transactions.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: Center(child: _TransactionsEmptyView(isIncome)))
          else ...[
            SliverToBoxAdapter(
              child: ListTile(
                title: Text(context.l10n.total),
                trailing: Text(
                  total
                      .thousandsSeparated(fractionalLength: null)
                      .withCurrency(transactions.first.account.currency.symbol, 1),
                ),
                tileColor: colorScheme.primaryContainer,
              ),
            ),
            SliverList.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionListTile(
                  enableTopDivider: true,
                  enableBottomDivider: index == transactions.length - 1,
                  emoji: transaction.category.emoji,
                  title: transaction.category.name,
                  comment: transaction.comment,
                  amount: transaction.amount
                      .amountToNum()
                      .thousandsSeparated(fractionalLength: null)
                      .withCurrency(transaction.account.currency.symbol, 1),
                  onTap: () => _onTransactionTap(context, transaction),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// {@template _TransactionsEmptyView.class}
/// _TransactionsEmptyView widget.
/// {@endtemplate}
class _TransactionsEmptyView extends StatelessWidget {
  /// {@macro _TransactionsEmptyView.class}
  const _TransactionsEmptyView(this.isIncome);

  final bool isIncome;

  @override
  Widget build(BuildContext context) => Text(
        isIncome ? context.l10n.incomeAreEmpty : context.l10n.expensesAreEmpty,
        textAlign: TextAlign.center,
        style: TextTheme.of(context).titleMedium,
      );
}
