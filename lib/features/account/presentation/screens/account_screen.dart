import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:localization/localization.dart';
import 'package:pretty_chart/pretty_chart.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/core/presentation/common/processing_state_mixin.dart';
import 'package:yang_money_catcher/core/presentation/common/visibility_by_tilt_mixin.dart';
import 'package:yang_money_catcher/core/utils/extensions/date_time_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/account_currency_bottom_sheet.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_loader_wrapper.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';

const _chartMaxHeight = 233.0;

/// {@template AccountScreen.class}
/// Экран отображения баланса, валюты, а также движений по счету
/// {@endtemplate}
@RoutePage()
class AccountScreen extends StatelessWidget implements AutoRouteWrapper {
  /// {@macro AccountScreen.class}
  const AccountScreen({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => TransactionsBloc(DependenciesScope.of(context).transactionsRepository),
        child: this,
      );

  void _onRetryTap(BuildContext context, int accountId) =>
      context.read<AccountBloc>().add(AccountEvent.load(accountId));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.myAccount)),
        body: AccountsLoaderWrapper(
          (accounts) => BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) => switch (accountState) {
              _ when accountState.account != null => _AccountSuccessView(accountState.account!),
              AccountState$Error(:final error) => ErrorBodyView(
                  title: ErrorUtil.messageFromObject(context, error: error),
                  retryButtonText: context.l10n.tryItAgain,
                  description: context.l10n.retry,
                  onRetryTap: () => _onRetryTap(context, accounts.first.id),
                ),
              _ => const LoadingBodyView(),
            },
          ),
        ),
      );
}

/// {@template _AccountSuccessView.class}
/// _AccountSuccessView widget.
/// {@endtemplate}
class _AccountSuccessView extends StatefulWidget {
  /// {@macro _AccountSuccessView.class}
  const _AccountSuccessView(this.account);

  final AccountDetailEntity account;

  @override
  State<_AccountSuccessView> createState() => _AccountSuccessViewState();
}

class _AccountSuccessViewState extends State<_AccountSuccessView> {
  late CalendarValues _fetchCalendarValue;

  @override
  void initState() {
    super.initState();
    _fetchCalendarValue = CalendarValues.day;
    _loadTransactions();
  }

  @override
  void didUpdateWidget(covariant _AccountSuccessView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.account.id != oldWidget.account.id) {
      _loadTransactions();
    }
  }

  Future<void> _refreshAccount() async {
    final accountBloc = context.read<AccountBloc>()..add(AccountEvent.load(widget.account.id));
    await accountBloc.stream.firstWhere((state) => state is! AccountState$Processing);
  }

  Future<void> _loadTransactions() async {
    final dtNow = DateTime.now();
    final startDate = switch (_fetchCalendarValue) {
      CalendarValues.day => dtNow.copyWith(month: dtNow.month - 1),
      CalendarValues.month => dtNow.copyWith(year: dtNow.year - 1),
      CalendarValues.week => throw UnimplementedError(),
      CalendarValues.year => throw UnimplementedError(),
    };
    final filters = TransactionFilters(
      accountId: widget.account.id,
      accountRemoteId: widget.account.remoteId,
      startDate: startDate,
      endDate: dtNow,
    );
    final transactionsBloc = context.read<TransactionsBloc>()..add(TransactionsEvent.load(filters));
    await transactionsBloc.stream.firstWhere((state) => state is! TransactionsState$Processing);
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      _refreshAccount(),
      _loadTransactions(),
    ]).timeout(const Duration(seconds: 20));
  }

  void _changeCalendarValue(CalendarValues value) {
    if (value == _fetchCalendarValue || !mounted) return;
    setState(() => _fetchCalendarValue = value);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator.adaptive(
        onRefresh: _onRefresh,
        child: ListView(
          children: [
            ...ListTile.divideTiles(
              context: context,
              tiles: [
                // balance
                _AccountBalanceTile(account: widget.account),
                // currency
                _AccountCurrencyTile(account: widget.account),
              ],
            ),
            const SizedBox(height: AppSizes.double16),
            // chart
            ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.fromHeight(_chartMaxHeight)),
              child: BlocBuilder<TransactionsBloc, TransactionsState>(
                builder: (context, transactionsState) {
                  final errorWithNothingToShow =
                      transactionsState is TransactionsState$Error && transactionsState.transactions == null
                          ? transactionsState.error
                          : null;
                  final showSecond = transactionsState.transactions != null;
                  return AnimatedCrossFade(
                    firstChild: errorWithNothingToShow == null
                        ? const TypedProgressIndicator.small()
                        : ErrorBodyView(
                            title: ErrorUtil.messageFromObject(context, error: errorWithNothingToShow),
                            retryButtonText: context.l10n.tryItAgain,
                            description: context.l10n.retry,
                            onRetryTap: _loadTransactions,
                          ),
                    secondChild: _AccountTransactionsAnalyzeChart(
                      transactions: transactionsState.transactions ?? [],
                      calendarValues: _fetchCalendarValue,
                    ),
                    crossFadeState: showSecond ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 400),
                  );
                },
              ),
            ),
            Center(
              child: CalendarSegmentedButton(
                selected: _fetchCalendarValue,
                values: const [CalendarValues.day, CalendarValues.month],
                titleBuilder: (value) => context.l10n.selectByCalendarValue(value.name),
                onChanged: _changeCalendarValue,
              ),
            ),
          ],
        ),
      );
}

/// {@template _AccountBalanceTile.class}
/// _AccountBalanceTile widget.
/// {@endtemplate}
class _AccountBalanceTile extends StatefulWidget {
  /// {@macro _AccountBalanceTile.class}
  const _AccountBalanceTile({required this.account});

  final AccountDetailEntity account;

  @override
  State<_AccountBalanceTile> createState() => _AccountBalanceTileState();
}

class _AccountBalanceTileState extends State<_AccountBalanceTile> with ProcessingStateMixin {
  Future<void> _onBalanceTap() async {
    final accountName = await showDialog<String>(
      context: context,
      builder: (context) => TextConfirmDialog(
        initialValue: widget.account.name,
        onConfirmTap: context.maybePop,
        title: context.l10n.account,
        confirmButtonTitle: context.l10n.save,
        cancelButtonTitle: context.l10n.cancel,
      ),
    );
    if (accountName == null || !mounted) return;
    final request = AccountRequest.update(
      id: widget.account.id,
      name: accountName,
      balance: widget.account.balance,
      currency: widget.account.currency,
    );
    final accountBloc = context.read<AccountBloc>()..add(AccountEvent.update(request));
    unawaited(
      doProcessing(() async {
        await accountBloc.stream.firstWhere((state) => state is! AccountState$Processing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return ListTile(
      onTap: isProcessing ? null : _onBalanceTap,
      tileColor: colorScheme.primaryContainer,
      leading: SvgPicture.asset(SvgIcons.moneyBag),
      title: Row(
        spacing: 5.0,
        children: [
          Text(widget.account.name),
          if (isProcessing) const TypedProgressIndicator.small(isCentered: false),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _BalanceAnimatedWidget(
                widget.account.balance
                    .amountToNum()
                    .thousandsSeparated()
                    .withCurrency(widget.account.currency.symbol, 1),
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.outline.withValues(alpha: AppSizes.double03),
      ),
    );
  }
}

/// {@template _AccountCurrencyTile.class}
/// _AccountCurrencyTile widget.
/// {@endtemplate}
class _AccountCurrencyTile extends StatefulWidget {
  /// {@macro _AccountCurrencyTile.class}
  const _AccountCurrencyTile({required this.account});

  final AccountDetailEntity account;

  @override
  State<_AccountCurrencyTile> createState() => _AccountCurrencyTileState();
}

class _AccountCurrencyTileState extends State<_AccountCurrencyTile> with ProcessingStateMixin {
  Future<void> _onCurrencyTap() async {
    final currency = await showAccountCurrencyBottomSheet(context);
    if (currency == null || !mounted) return;
    final request = AccountRequest.update(
      id: widget.account.id,
      name: widget.account.name,
      balance: widget.account.balance,
      currency: currency,
    );
    final accountBloc = context.read<AccountBloc>()..add(AccountEvent.update(request));
    unawaited(
      doProcessing(() async {
        await accountBloc.stream.firstWhere((state) => state is AccountState$Processing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return ListTile(
      onTap: isProcessing ? null : _onCurrencyTap,
      tileColor: colorScheme.primaryContainer,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.currency),
          if (isProcessing)
            const TypedProgressIndicator.small(isCentered: false)
          else
            Text(widget.account.currency.symbol),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.outline.withValues(alpha: AppSizes.double03),
      ),
    );
  }
}

/// {@template _BalanceAnimatedWidget.class}
/// _BalanceAnimatedWidget widget.
/// {@endtemplate}
class _BalanceAnimatedWidget extends StatefulWidget {
  /// {@macro _BalanceAnimatedWidget.class}
  const _BalanceAnimatedWidget(this.balance);

  final String balance;

  @override
  State<_BalanceAnimatedWidget> createState() => _BalanceAnimatedWidgetState();
}

class _BalanceAnimatedWidgetState extends State<_BalanceAnimatedWidget> with VisibilityByTiltMixin {
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: isVisible
            ? Text(
                widget.balance,
                key: const ValueKey('balance'),
              )
            : const NoisePlaceholder(
                key: ValueKey('placeholder'),
                size: Size(70, 30),
              ),
      );
}

/// {@template _AccountTransactionsAnalyzeChart.class}
/// _AccountTransactionsAnalyzeChart widget.
/// {@endtemplate}
class _AccountTransactionsAnalyzeChart extends StatefulWidget {
  /// {@macro _AccountTransactionsAnalyzeChart.class}
  const _AccountTransactionsAnalyzeChart({required this.transactions, required this.calendarValues});

  final CalendarValues calendarValues;
  final List<TransactionDetailEntity> transactions;

  @override
  State<_AccountTransactionsAnalyzeChart> createState() => _AccountTransactionsAnalyzeChartState();
}

class _AccountTransactionsAnalyzeChartState extends State<_AccountTransactionsAnalyzeChart> {
  late final Map<DateTime, ChartItemData> _chartItemsMap;

  @override
  void initState() {
    super.initState();
    _chartItemsMap = {};
  }

  @override
  void didChangeDependencies() {
    _updateChartItemsMap();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _AccountTransactionsAnalyzeChart oldWidget) {
    final areTransactionListsEqual =
        const ListEquality<TransactionDetailEntity>().equals(widget.transactions, oldWidget.transactions);
    final isCalendarValueChanged = widget.calendarValues != oldWidget.calendarValues;
    if (!areTransactionListsEqual || isCalendarValueChanged) {
      _updateChartItemsMap();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateChartItemsMap() {
    _chartItemsMap.clear();
    for (final transaction in widget.transactions) {
      final clearDate = transaction.transactionDate.toLocal().copyWithStartOfDayTme.copyWith(
            day: switch (widget.calendarValues) {
              CalendarValues.day => null,
              CalendarValues.month => 0,
              CalendarValues.year => 0,
              CalendarValues.week => throw UnimplementedError(),
            },
            month: switch (widget.calendarValues) {
              CalendarValues.day => null,
              CalendarValues.month => null,
              CalendarValues.year => 0,
              CalendarValues.week => throw UnimplementedError(),
            },
          );
      final oldItem = _chartItemsMap[clearDate] ??
          ChartItemData(
            id: clearDate.millisecondsSinceEpoch,
            value: 0.0,
            label: switch (widget.calendarValues) {
              CalendarValues.day => clearDate.ddMM,
              CalendarValues.week => clearDate.ddMM,
              CalendarValues.month => clearDate.MMyyyy,
              CalendarValues.year => clearDate.yyyy,
            },
          );
      final currentTotal = oldItem.value +
          (transaction.category.isIncome ? transaction.amount.amountToNum() : -transaction.amount.amountToNum());
      _chartItemsMap[clearDate] = oldItem.copyWith(
        value: currentTotal,
        tooltipLabel:
            '${context.l10n.total}: ${currentTotal.thousandsSeparated(fractionalLength: null).withCurrency(transaction.account.currency.symbol, 1)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = ColorScheme.of(context);
    final appColorScheme = AppColorScheme.of(context);
    if (widget.transactions.isEmpty) return Center(child: Text(context.l10n.nothingFound, textAlign: TextAlign.center));

    return AnimatedBarChart(
      _chartItemsMap.values.mapIndexed((index, e) {
        final shouldShowLabel =
            index == 0 || index == _chartItemsMap.values.length ~/ 2 || index == _chartItemsMap.values.length - 1;
        return shouldShowLabel ? e : e.copyWith(label: '');
      }).toList(),
      columnColorBuilder: (item) => item.isNegative ? appColorScheme.analyzeNegative : appColorScheme.primary,
      labelStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface),
    );
  }
}
