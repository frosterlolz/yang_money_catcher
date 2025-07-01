import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/core/utils/extensions/date_time_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/key_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/core/utils/models/sort_types.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_filters.dart';
import 'package:yang_money_catcher/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';
import 'package:yang_money_catcher/ui_kit/loaders/typed_progress_indicator.dart';

/// {@template TransactionsHistoryScreen.class}
/// TransactionsHistoryScreen widget.
/// {@endtemplate}
@RoutePage()
class TransactionsHistoryScreen extends StatefulWidget implements AutoRouteWrapper {
  /// {@macro TransactionsHistoryScreen.class}
  const TransactionsHistoryScreen({super.key, required this.isIncome, this.initialRange, required this.accountId});

  final int accountId;
  final bool isIncome;
  final DateTimeRange? initialRange;

  @override
  State<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider(
        create: (context) => TransactionsBloc(DependenciesScope.of(context).transactionsRepository),
        child: this,
      );
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> with _TransactionHistoryFormMixin {
  late final GlobalKey _sortTileKey;

  @override
  void initState() {
    super.initState();
    _sortTileKey = GlobalKey();
    _loadTransactions();
  }

  void _loadTransactions() {
    if (!mounted) return;
    final filters = TransactionFilters(
      accountId: widget.accountId,
      isIncome: widget.isIncome,
      startDate: _dateTimeRange.start,
      endDate: _dateTimeRange.end,
    );
    context.read<TransactionsBloc>().add(TransactionsEvent.load(filters));
  }

  void _onAnalyzeTap(BuildContext context) {
    // TODO(frosterlolz): реализовать переход на экран анализа
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

  Future<void> _onSortTap() async {
    final tileRect = _sortTileKey.getRect();
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final top = tileRect.bottom;
    final res = await showMenu<SortTypes>(
      context: context,
      position: RelativeRect.fromLTRB(overlay.size.width, top, tileRect.left, 0),
      items: SortTypes.values
          .map(
            (type) => PopupMenuItem<SortTypes>(
              value: type,
              child: Text(context.l10n.sortingValue(type.name)),
            ),
          )
          .toList(),
    );
    if (res == null) return;
    _changeSortType(res);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myHistory),
        actions: [
          IconButton(onPressed: () => _onAnalyzeTap(context), icon: SvgPicture.asset(SvgIcons.calendarPlan)),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  // beginning
                  ListTile(
                    onTap: _onSelectStartDate,
                    tileColor: colorScheme.secondary,
                    title: Text(context.l10n.beginning),
                    trailing: Text(_dateTimeRange.start.ddMMMMyyyy),
                  ),
                  // end
                  ListTile(
                    onTap: _onSelectEndDate,
                    tileColor: colorScheme.secondary,
                    title: Text(context.l10n.end),
                    trailing: Text(_dateTimeRange.end.ddMMMMyyyy),
                  ),
                  // sort
                  ListTile(
                    key: _sortTileKey,
                    onTap: _onSortTap,
                    tileColor: colorScheme.secondary,
                    title: Text(context.l10n.sorting),
                    trailing: Text(context.l10n.sortingValue(_sortType.name)),
                  ),
                  // amount
                  BlocBuilder<TransactionsBloc, TransactionsState>(
                    builder: (context, transitionsState) => ListTile(
                      tileColor: colorScheme.secondary,
                      title: Text(context.l10n.amount),
                      trailing: switch (transitionsState) {
                        _ when transitionsState.transactions != null => Text(
                            transitionsState.totalAmount.thousandsSeparated().withCurrency(
                                  transitionsState.transactions!.firstOrNull?.account.currency.symbol ??
                                      Currency.rub.symbol,
                                  1,
                                ),
                          ),
                        TransactionsState$Error() => const SizedBox.shrink(),
                        _ => const TypedProgressIndicator.small(isCentered: false),
                      },
                    ),
                  ),
                ],
              ).toList(),
            ),
          ),
          // list with transactions
          BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, transactionsState) => switch (transactionsState) {
              _ when transactionsState.transactions != null =>
                _TransactionsSliverList(transactionsState.transactions!, sortType: _sortType),
              TransactionsState$Error(:final error) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorBodyView.fromError(error, onRetryTap: _loadTransactions),
                ),
              _ => const SliverFillRemaining(hasScrollBody: false, child: LoadingBodyView()),
            },
          ),
        ],
      ),
    );
  }
}

mixin _TransactionHistoryFormMixin on State<TransactionsHistoryScreen> {
  late DateTimeRange _dateTimeRange;
  late SortTypes _sortType;

  @override
  void initState() {
    super.initState();
    _initDateTimeRange();
    _sortType = SortTypes.byDefault;
  }

  void _initDateTimeRange() {
    final dtNow = DateTime.now();
    final fallbackDateRange = DateTimeRange(
      start: dtNow.endOfDay.copyWith(month: dtNow.month - 1),
      end: dtNow.endOfDay,
    );
    final effectiveDateRange = widget.initialRange ?? fallbackDateRange;
    _dateTimeRange = effectiveDateRange;
  }

  /// returns `true` if date range was changed
  bool _changeDateRange({DateTime? start, DateTime? end}) {
    if (start == null && end == null) return false;

    final rawStart = start ?? _dateTimeRange.start;
    final rawEnd = end ?? _dateTimeRange.end;

    final normalizedStart = start == null ? _normalizeStartRange(start: rawStart, end: rawEnd) : rawStart;
    final normalizedEnd = end == null ? _normalizeEndRange(end: rawEnd, start: rawStart) : rawEnd;

    final withTimeStart = normalizedStart.startOfDay;
    final withTimeEnd = normalizedEnd.startOfDay;

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

  bool _changeSortType(SortTypes type) {
    if (type == _sortType || !mounted) return false;
    setState(() => _sortType = type);
    return true;
  }
}

/// {@template _TransactionsSliverList.class}
/// _TransactionsSliverList widget.
/// {@endtemplate}
class _TransactionsSliverList extends StatefulWidget {
  /// {@macro _TransactionsSliverList.class}
  const _TransactionsSliverList(this.transactions, {required this.sortType});

  final List<TransactionDetailEntity> transactions;
  final SortTypes sortType;

  @override
  State<_TransactionsSliverList> createState() => _TransactionsSliverListState();
}

class _TransactionsSliverListState extends State<_TransactionsSliverList> {
  late List<TransactionDetailEntity> _transactions;

  @override
  void initState() {
    super.initState();
    _initSortedTransactions();
  }

  @override
  void didUpdateWidget(covariant _TransactionsSliverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sortType != oldWidget.sortType ||
        !const ListEquality<TransactionDetailEntity>().equals(oldWidget.transactions, widget.transactions)) {
      setState(_initSortedTransactions);
    }
  }

  void _initSortedTransactions() {
    _transactions = widget.transactions.toList();
    switch (widget.sortType) {
      case SortTypes.byDefault:
        _transactions.sort((a, b) => a.compareTo(b));
      case SortTypes.byDateAsc:
        _transactions.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
      case SortTypes.byDateDesc:
        _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      case SortTypes.byAmountAsc:
        _transactions.sort((a, b) => a.amount.compareTo(b.amount));
      case SortTypes.byAmountDesc:
        _transactions.sort((a, b) => b.amount.compareTo(a.amount));
    }
  }

  void _onTransactionTap(BuildContext context, TransactionDetailEntity transaction) {
    context.pushRoute(TransactionRoute(isIncome: transaction.category.isIncome, initialTransaction: transaction));
  }

  @override
  Widget build(BuildContext context) {
    if (_transactions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            context.l10n.nothingFound,
            textAlign: TextAlign.center,
            style: TextTheme.of(context).titleMedium,
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return TransactionListTile(
          title: transaction.category.name,
          comment: transaction.comment,
          commentStyle: Theme.of(context).textTheme.labelSmall,
          emoji: transaction.category.emoji,
          transactionDateTime: transaction.transactionDate.hhmm,
          enableTopDivider: true,
          enableBottomDivider: index == _transactions.length - 1,
          amount: transaction.amount
              .amountToNum()
              .thousandsSeparated(fractionalLength: null)
              .withCurrency(transaction.account.currency.symbol, 1),
          onTap: () => _onTransactionTap(context, transaction),
        );
      },
    );
  }
}
