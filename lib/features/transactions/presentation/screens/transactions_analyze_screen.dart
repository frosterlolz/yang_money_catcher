import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_chart/pretty_chart.dart';
import 'package:yang_money_catcher/core/utils/extensions/date_time_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/presentation/models/transactions_analysis_summary.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';

/// {@template TransactionsAnalyzeScreen.class}
/// TransactionsAnalyzeScreen widget.
/// {@endtemplate}
@RoutePage()
class TransactionsAnalyzeScreen extends StatefulWidget implements AutoRouteWrapper {
  /// {@macro TransactionsAnalyzeScreen.class}
  const TransactionsAnalyzeScreen({
    super.key,
    required this.initialDtRange,
    required this.accountId,
    required this.isIncome,
  });

  final int accountId;
  final DateTimeRange? initialDtRange;
  final bool isIncome;

  @override
  State<TransactionsAnalyzeScreen> createState() => _TransactionsAnalyzeScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    final dependenciesScope = DependenciesScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TransactionsBloc(dependenciesScope.transactionsRepository)),
        BlocProvider(
          create: (context) => AccountBloc(dependenciesScope.accountRepository)..add(AccountEvent.load(accountId)),
        ),
      ],
      child: this,
    );
  }
}

class _TransactionsAnalyzeScreenState extends State<TransactionsAnalyzeScreen> with _TransactionAnalyzeFormMixin {
  void _accountListener(BuildContext context, AccountState state) {
    final account = state.account;
    if (account == null) return;
    _loadTransactions(account);
  }

  void _loadTransactions([AccountDetailEntity? accountDetails]) {
    if (!mounted) return;
    final account = accountDetails ?? context.read<AccountBloc>().state.account;
    final filters = TransactionFilters(
      accountId: widget.accountId,
      accountRemoteId: account?.remoteId,
      isIncome: widget.isIncome,
      startDate: _dateTimeRange.start,
      endDate: _dateTimeRange.end,
    );
    context.read<TransactionsBloc>().add(TransactionsEvent.load(filters));
  }

  Future<void> _onSelectStartDate() async {
    final resDate = await _showDateSelector(_dateTimeRange.start);
    if (resDate == null) return;
    final isChanged = _changeDateRange(start: resDate);
    if (!isChanged) return;
    _loadTransactions();
  }

  Future<void> _onSelectEndDate() async {
    final resDate = await _showDateSelector(_dateTimeRange.end);
    if (resDate == null) return;
    final isChanged = _changeDateRange(end: resDate);
    if (!isChanged) return;
    _loadTransactions();
  }

  Future<DateTime?> _showDateSelector(DateTime? initialDate) async {
    final dtNow = DateTime.now();
    final resDate = await showDatePicker(
      context: context,
      firstDate: dtNow.copyWith(year: dtNow.year - 1),
      lastDate: dtNow.copyWith(year: dtNow.year + 1),
      initialDate: initialDate,
    );
    return resDate;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final appColorScheme = AppColorScheme.of(context);

    return BlocListener<AccountBloc, AccountState>(
      listenWhen: (o, c) => o.account?.id != c.account?.id,
      listener: _accountListener,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appColorScheme.background,
          title: Text(context.l10n.analyze),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...ListTile.divideTiles(
                    context: context,
                    tiles: [
                      // beginning
                      ListTile(
                        onTap: _onSelectStartDate,
                        title: Text('${context.l10n.period}: ${context.l10n.beginning.toLowerCase()}'),
                        trailing: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.double16)),
                            color: colorScheme.primary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.double20,
                              vertical: AppSizes.double6,
                            ),
                            child: Text(_dateTimeRange.start.ddMMMMyyyy),
                          ),
                        ),
                      ),
                      // end
                      ListTile(
                        onTap: _onSelectEndDate,
                        title: Text('${context.l10n.period}: ${context.l10n.end.toLowerCase()}'),
                        trailing: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.double16)),
                            color: colorScheme.primary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.double20,
                              vertical: AppSizes.double6,
                            ),
                            child: Text(_dateTimeRange.end.ddMMMMyyyy),
                          ),
                        ),
                      ),
                      // amount
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: BlocBuilder<TransactionsBloc, TransactionsState>(
                          builder: (context, transactionsState) => switch (transactionsState) {
                            _ when transactionsState.transactions != null => Column(
                                children: [
                                  ListTile(
                                    title: Text(context.l10n.amount),
                                    trailing: Text(
                                      transactionsState.totalAmount.thousandsSeparated().withCurrency(
                                            transactionsState.transactions?.firstOrNull?.account.currency.symbol ??
                                                Currency.rub.symbol,
                                            1,
                                          ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, transactionsState) => switch (transactionsState) {
                _ when transactionsState.transactions != null => _TransactionsSuccessView(
                    transactions: transactionsState.transactions!,
                    totalAmount: transactionsState.totalAmount,
                  ),
                TransactionsState$Error(:final error) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorBodyView.fromError(
                      error,
                      onRetryTap: _loadTransactions,
                    ),
                  ),
                _ => const SliverFillRemaining(hasScrollBody: false, child: LoadingBodyView()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

mixin _TransactionAnalyzeFormMixin on State<TransactionsAnalyzeScreen> {
  late DateTimeRange _dateTimeRange;

  @override
  void initState() {
    super.initState();
    _initDateTimeRange();
  }

  void _initDateTimeRange() {
    final dtNow = DateTime.now();
    final fallbackDateRange = DateTimeRange(
      start: dtNow.copyWithEndOfDayTme.copyWith(month: dtNow.month - 1),
      end: dtNow.copyWithEndOfDayTme,
    );
    final effectiveDateRange = widget.initialDtRange ?? fallbackDateRange;
    _dateTimeRange = effectiveDateRange;
  }

  /// returns `true` if date range was changed
  bool _changeDateRange({DateTime? start, DateTime? end}) {
    if (start == null && end == null) return false;

    final rawStart = start ?? _dateTimeRange.start;
    final rawEnd = end ?? _dateTimeRange.end;

    final normalizedStart = start == null ? _normalizeStartRange(start: rawStart, end: rawEnd) : rawStart;
    final normalizedEnd = end == null ? _normalizeEndRange(end: rawEnd, start: rawStart) : rawEnd;

    final withTimeStart = normalizedStart.copyWithStartOfDayTme;
    final withTimeEnd = normalizedEnd.copyWithEndOfDayTme;

    final isSameStart = withTimeStart.isSameDateTime(_dateTimeRange.start);
    final isSameEnd = withTimeEnd.isSameDateTime(_dateTimeRange.end);
    if (isSameStart && isSameEnd) return false;

    if (!mounted) return false;
    setState(() {
      _dateTimeRange = DateTimeRange(start: withTimeStart, end: withTimeEnd);
    });
    return true;
  }

  DateTime _normalizeStartRange({required DateTime start, required DateTime end}) => start.isBefore(end) ? start : end;

  DateTime _normalizeEndRange({required DateTime start, required DateTime end}) => end.isAfter(start) ? end : start;
}

/// {@template _TransactionsSuccessView.class}
/// _TransactionsSuccessView widget.
/// {@endtemplate}
class _TransactionsSuccessView extends StatefulWidget {
  /// {@macro _TransactionsSuccessView.class}
  const _TransactionsSuccessView({required this.transactions, required this.totalAmount});

  final num totalAmount;
  final List<TransactionDetailEntity> transactions;

  @override
  State<_TransactionsSuccessView> createState() => _TransactionsSuccessViewState();
}

class _TransactionsSuccessViewState extends State<_TransactionsSuccessView> {
  late TransactionsAnalysisSummary _transactionCategoryAnalysisList;

  @override
  void initState() {
    super.initState();
    _setTransactionCategoryAnalysisList();
  }

  @override
  void didUpdateWidget(covariant _TransactionsSuccessView oldWidget) {
    if (!const ListEquality<TransactionDetailEntity>().equals(widget.transactions, oldWidget.transactions)) {
      setState(_setTransactionCategoryAnalysisList);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setTransactionCategoryAnalysisList() {
    final transactionAnalysisMap = <TransactionCategory, List<TransactionDetailEntity>>{};
    for (final transaction in widget.transactions) {
      final currentTransactions = transactionAnalysisMap[transaction.category];
      transactionAnalysisMap[transaction.category] =
          currentTransactions == null ? [transaction] : [...currentTransactions, transaction];
    }
    _transactionCategoryAnalysisList = TransactionsAnalysisSummary(
      transactionAnalysisMap.entries
          .map<TransactionAnalysisSummaryItem>(
            (transactionAnalysisEntry) => TransactionAnalysisSummaryItem(
              transactionCategory: transactionAnalysisEntry.key,
              transactions: transactionAnalysisEntry.value,
            ),
          )
          .toList(),
    );
  }

  void _onTransactionAnalysisTap(
    BuildContext context, {
    required TransactionCategory category,
    required List<TransactionDetailEntity> transactions,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          builder: (context, controller) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.double16)),
              color: AppColorScheme.of(context).surface,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.double16),
              child: Column(
                spacing: 10.0,
                children: [
                  Text(category.name, style: TextTheme.of(context).titleLarge),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionListTile(
                          title: transaction.comment ?? transaction.category.name,
                          emoji: transaction.category.emoji,
                          comment: transaction.transactionDate.ddMMMMyyyy,
                          amount: transaction.amount
                              .amountToNum()
                              .thousandsSeparated(fractionalLength: null)
                              .withCurrency(transaction.account.currency.symbol, 1),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(context.l10n.nothingFound)));
    }
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedPieChart(
            List.generate(_transactionCategoryAnalysisList.items.length, (index) {
              final item = _transactionCategoryAnalysisList.items[index];
              return ChartItemData(
                id: item.transactionCategory.id,
                label: item.transactionCategory.name,
                value: _transactionCategoryAnalysisList.amountPercentage(item.transactionCategory),
              );
            }),
          ),
        ),
        SliverList.builder(
          itemCount: _transactionCategoryAnalysisList.items.length,
          itemBuilder: (context, index) {
            final transactionAnalysisItem = _transactionCategoryAnalysisList.items.elementAt(index);

            return TransactionListTile(
              title: transactionAnalysisItem.transactionCategory.name,
              comment: transactionAnalysisItem.transactions.lastOrNull?.comment,
              emoji: transactionAnalysisItem.transactionCategory.emoji,
              amount: transactionAnalysisItem.totalAmount.thousandsSeparated(fractionalLength: null).withCurrency(
                    transactionAnalysisItem.transactions.firstOrNull?.account.currency.symbol ?? Currency.rub.symbol,
                    1,
                  ),
              transactionDateTime:
                  '${_transactionCategoryAnalysisList.amountPercentage(transactionAnalysisItem.transactionCategory).smartTruncate()} %',
              enableTopDivider: index == 0,
              enableBottomDivider: true,
              onTap: () => _onTransactionAnalysisTap(
                context,
                transactions: transactionAnalysisItem.transactions,
                category: transactionAnalysisItem.transactionCategory,
              ),
            );
          },
        ),
      ],
    );
  }
}
