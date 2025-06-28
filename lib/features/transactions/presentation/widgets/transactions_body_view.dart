import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';

/// {@template TransactionsView.class}
/// Тело экрана со списком транзакций
/// {@endtemplate}
class TransactionsBodyView extends StatefulWidget {
  /// {@macro TransactionsView.class}
  const TransactionsBodyView({super.key, required this.isIncome, required this.accountId});

  final bool isIncome;
  final int accountId;

  @override
  State<TransactionsBodyView> createState() => _TransactionsBodyViewState();
}

class _TransactionsBodyViewState extends State<TransactionsBodyView> {
  @override
  void initState() {
    super.initState();
    final transactionsBloc = context.read<TransactionsBloc>();
    if (transactionsBloc.state is TransactionsState$Processing) {
      _onRetryTap(context).ignore();
    }
  }

  Future<void> _onRetryTap(BuildContext context) async {
    final currentDayRange = DateTimeRange(
      start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
      end: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
    );
    final transactionsBloc = context.read<TransactionsBloc>()
      ..add(TransactionsEvent.load(widget.accountId, range: currentDayRange));
    await transactionsBloc.stream.firstWhere((state) => state is! TransactionsState$Processing);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, transactionsState) {
          final transactions = transactionsState.transactions == null
              ? null
              : transactionsState.filtered(transactionsState.transactions!, isIncome: widget.isIncome).toList();
          return switch (transactionsState) {
            _ when transactions != null => _TransactionsListView(
                transactions: transactions,
                isIncome: widget.isIncome,
                onRefresh: _onRetryTap,
              ),
            AccountState$Error(:final error) => ErrorBodyView.fromError(error, onRetryTap: () => _onRetryTap(context)),
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
  const _TransactionsListView({required this.isIncome, required this.transactions, required this.onRefresh});

  final bool isIncome;
  final List<TransactionDetailEntity> transactions;
  final Future<void> Function(BuildContext context) onRefresh;

  num get total => transactions.fold(0, (a, b) => a + (num.tryParse(b.amount) ?? 0.0));

  void _onTransactionTap(TransactionDetailEntity transaction) {
    // TODO(frosterlolz): реализовать переход на экран транзакции
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator.adaptive(
        onRefresh: () => onRefresh(context),
        child: CustomScrollView(
          slivers: [
            if (transactions.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: Center(child: _TransactionsEmptyView(isIncome)))
            else ...[
              SliverToBoxAdapter(
                child: ListTile(
                  title: Text(context.l10n.total),
                  trailing: Text(total.thousandsSeparated(fractionalLength: null).withCurrency(transactions.first.account.currency.symbol, 1)),
                  tileColor: AppColorScheme.of(context).secondary,
                ),
              ),
              SliverList.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Column(
                    children: [
                      const Divider(),
                      TransactionListTile(
                        leadingEmoji: transaction.category.emoji,
                        title: transaction.category.name,
                        subtitle: transaction.comment,
                        amount: transaction.amount.amountToNum().thousandsSeparated(fractionalLength: null).withCurrency(transaction.account.currency.symbol, 1),
                        onTap: () => _onTransactionTap(transaction),
                      ),
                      if (index == transactions.length - 1) const Divider(),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      );
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
