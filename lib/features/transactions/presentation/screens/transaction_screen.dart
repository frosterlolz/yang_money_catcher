import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yang_money_catcher/core/presentation/common/input_formatters.dart';
import 'package:yang_money_catcher/core/presentation/common/processing_state_mixin.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';
import 'package:yang_money_catcher/core/utils/extensions/date_time_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_brief.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/account_selector_view.dart';
import 'package:yang_money_catcher/features/initialization/presentation/dependencies_scope.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transaction_categories/presentation/widget/transaction_category_selector_view.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_change_request.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/bottom_sheets/item_selector_sheet.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/dialogs/text_confirm_dialog.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';
import 'package:yang_money_catcher/ui_kit/loaders/typed_progress_indicator.dart';
import 'package:yang_money_catcher/ui_kit/snacks/topside_snack_bars.dart';

Future<void> showTransactionScreen(
  BuildContext context, {
  required bool isIncome,
  TransactionDetailEntity? initialTransaction,
}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      useRootNavigator: false,
      useSafeArea: true,
      barrierColor: ColorScheme.of(context).primary,
      builder: (_) => BlocProvider(
        create: (_) {
          final bloc = TransactionBloc(
            TransactionState.processing(initialTransaction, isOffline: initialTransaction?.remoteId == null),
            transactionsRepository: DependenciesScope.of(context).transactionsRepository,
          );
          if (initialTransaction != null) {
            bloc.add(TransactionEvent.load(initialTransaction.id));
          }
          return bloc;
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) =>
              TransactionScreen(isIncome: isIncome, initialTransaction: transactionState.transaction),
        ),
      ),
    );

/// {@template TransactionScreen.class}
/// Экран просмотра/добавления/обновления/удаления транзакции
/// {@endtemplate}
class TransactionScreen extends StatefulWidget {
  /// {@macro TransactionScreen.class}
  const TransactionScreen({required this.isIncome, this.initialTransaction, super.key});

  final bool isIncome;
  final TransactionDetailEntity? initialTransaction;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> with _TransactionFormMixin, ProcessingStateMixin {
  Future<void> _selectAccount() async {
    final selectedAccount = await showItemSelectorModalBottomSheet<AccountEntity>(
      context,
      body: AccountSelectorView(currentAccountId: _account?.id),
    );
    if (selectedAccount == null) return;
    _changeAccount(AccountBrief.fromEntity(selectedAccount));
  }

  Future<void> _selectTransactionCategory() async {
    final selectedTransactionCategory = await showItemSelectorModalBottomSheet<TransactionCategory>(
      context,
      body: TransactionCategorySelectorView(
        currentTransactionCategoryId: _transactionCategory?.id,
        isIncome: widget.isIncome,
      ),
    );
    if (selectedTransactionCategory == null) return;
    _changeTransactionCategory(selectedTransactionCategory);
  }

  Future<void> _selectAmount(Currency currency) async {
    final res = await showDialog<num>(
      context: context,
      builder: (context) => _SelectAmountDialog(inputAmount: _amount, currency: currency),
    );
    if (res == null) return;
    _changeAmount(res);
  }

  Future<void> _selectDate() async {
    final dtNow = DateTime.now();
    final effectiveFirstDate = dtNow.copyWith(year: dtNow.year - 1);
    final effectiveEndDate = dtNow;
    final fallbackFirstDate = _transactionDate.isBefore(effectiveFirstDate) ? _transactionDate : effectiveFirstDate;
    final fallbackEndDate = _transactionDate.isAfter(effectiveEndDate) ? _transactionDate : effectiveEndDate;
    final date = await showDatePicker(
      context: context,
      firstDate: fallbackFirstDate,
      lastDate: fallbackEndDate,
      initialDate: _transactionDate,
    );
    if (date == null) return;
    _changeTransactionDate(date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_transactionDate),
    );
    if (time == null) return;
    _changeTransactionTime(time);
  }

  Future<void> _selectComment() async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => TextConfirmDialog(
        initialValue: _comment,
        onConfirmTap: context.maybePop,
        title: context.l10n.inputComment,
      ),
    );
    if (comment == null) return;
    _changeComment(comment);
  }

  Future<void> _deleteTransaction(int transactionId) async {
    final transactionBloc = context.read<TransactionBloc>()..add(TransactionEvent.delete(transactionId));
    final nextState = await transactionBloc.stream.firstWhere((state) => state is! TransactionState$Processing);
    if (!mounted) return;
    switch (nextState) {
      case TransactionState$Processing():
      case TransactionState$Idle():
        break;
      case TransactionState$Updated():
        unawaited(context.maybePop());
      case TransactionState$Error(:final error):
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(TopSideSnackBars.error(context, error: error));
    }
    return;
  }

  Future<void> _save(BuildContext context) async {
    final transactionBloc = context.read<TransactionBloc>();
    try {
      final request = _createRequest();
      transactionBloc.add(TransactionEvent.update(request));
    } on Object catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(TopSideSnackBars.error(context, error: e));
      return;
    }
    final nextState = await transactionBloc.stream.firstWhere((state) => state is! TransactionState$Processing);
    if (!context.mounted) return;
    switch (nextState) {
      case TransactionState$Processing():
      case TransactionState$Idle():
        break;
      case TransactionState$Updated():
        ScaffoldMessenger.of(context).showSnackBar(
          TopSideSnackBars.success(
            context,
            message: widget.isIncome ? context.l10n.incomeSavedSuccessfully : context.l10n.expenseSavedSuccessfully,
          ),
        );
      case TransactionState$Error(:final error):
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(TopSideSnackBars.error(context, error: error));
    }
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(
        absorbing: isProcessing,
        child: Scaffold(
          appBar: AppBar(
            leading: AutoLeadingButton(
              builder: (_, __, onClose) => IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ),
            title: Text(context.l10n.myExpenses),
            actions: [if (_hasChanges) _SaveTransactionButton(() => doProcessing(() => _save(context)))],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...ListTile.divideTiles(
                context: context,
                tiles: [
                  // Счет
                  ListTile(
                    onTap: _selectAccount,
                    title: Row(
                      children: [
                        Text(context.l10n.account),
                        if (_account != null)
                          Expanded(
                            child: Align(alignment: Alignment.centerRight, child: Text(_account!.name)),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColorScheme.of(context).labelTertiary.withValues(alpha: AppSizes.double03),
                    ),
                  ),
                  // Статья
                  ListTile(
                    onTap: _selectTransactionCategory,
                    title: Row(
                      children: [
                        Text(context.l10n.article),
                        if (_transactionCategory != null)
                          Expanded(
                            child: Align(alignment: Alignment.centerRight, child: Text(_transactionCategory!.name)),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColorScheme.of(context).labelTertiary.withValues(alpha: AppSizes.double03),
                    ),
                  ),
                  // Сумма
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _account == null
                        ? const SizedBox.shrink()
                        : ListTile(
                            onTap: () => _selectAmount(_account!.currency),
                            title: Row(
                              children: [
                                Text(context.l10n.amount),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _amount
                                          .thousandsSeparated(fractionalLength: null)
                                          .withCurrency(_account?.currency.symbol ?? Currency.rub.symbol, 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Дата
                  ListTile(
                    onTap: _selectDate,
                    title: Row(
                      children: [
                        Text(context.l10n.date),
                        const Spacer(),
                        Text(_transactionDate.ddMMyyyy),
                      ],
                    ),
                  ),
                  // Время
                  ListTile(
                    onTap: _selectTime,
                    title: Row(
                      children: [
                        Text(context.l10n.time),
                        const Spacer(),
                        Text(_transactionDate.hhmm),
                      ],
                    ),
                  ),
                  // Комментарий
                  ListTile(
                    onTap: _selectComment,
                    title: _comment?.trim().isEmpty ?? true ? Text(context.l10n.comment) : Text(_comment!),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSizes.double32),
              _DeleteTransactionButton(
                onDeleteTap: (transactionId) => doProcessing(() => _deleteTransaction(transactionId)),
                isIncome: widget.isIncome,
              ),
              if (kDebugMode)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LocalId:${widget.initialTransaction?.id} RemoteId:${widget.initialTransaction?.remoteId}'),
                    Text(
                        'AccountId:${widget.initialTransaction?.account.id} AccountRemoteId:${widget.initialTransaction?.account.remoteId}'),
                  ],
                ),
            ],
          ),
        ),
      );
}

mixin _TransactionFormMixin on State<TransactionScreen> {
  AccountBrief? _account;
  TransactionCategory? _transactionCategory;
  late num _amount;
  late DateTime _transactionDate;
  String? _comment;

  bool get _hasChanges {
    // Если создаем транзацию- сохранение автоматически доступно
    if (widget.initialTransaction == null) return true;
    final accountChanged = _account != widget.initialTransaction?.account;
    final categoryChanged = _transactionCategory != widget.initialTransaction?.category;
    final amountChanged = _amount != widget.initialTransaction?.amount.amountToNum();
    final dateChanged = _transactionDate != widget.initialTransaction?.transactionDate;
    final commentChanged = _comment != widget.initialTransaction?.comment;
    return accountChanged || categoryChanged || amountChanged || dateChanged || commentChanged;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _initFromTransaction(widget.initialTransaction!);
    } else {
      _transactionDate = DateTime.now();
      _amount = 0.0;
    }
  }

  void _initFromTransaction(TransactionDetailEntity transaction) {
    _account = transaction.account;
    _transactionCategory = transaction.category;
    _amount = transaction.amount.amountToNum();
    _transactionDate = transaction.transactionDate;
    _comment = transaction.comment;
  }

  void _changeAccount(AccountBrief account) {
    if (account == _account || !mounted) return;
    setState(() => _account = account);
  }

  void _changeTransactionCategory(TransactionCategory category) {
    if (category == _transactionCategory || !mounted) return;
    setState(() => _transactionCategory = category);
  }

  void _changeAmount(num amount) {
    if (amount == _amount || !mounted) return;
    setState(() => _amount = amount);
  }

  void _changeTransactionDate(DateTime date) {
    final dtNow = DateTime.now();
    final nextDate = date.isFutureDay(dtNow) ? dtNow : date;
    if (nextDate.isSameDate(_transactionDate) || !mounted) return;
    setState(
      () => _transactionDate = _transactionDate.copyWith(
        year: nextDate.year,
        month: nextDate.month,
        day: nextDate.day,
      ),
    );
  }

  void _changeTransactionTime(TimeOfDay time) {
    if (time.isSameTime(TimeOfDay.fromDateTime(_transactionDate)) || !mounted) return;
    setState(
      () => _transactionDate = _transactionDate.copyWith(
        hour: time.hour,
        minute: time.minute,
      ),
    );
  }

  void _changeComment(String comment) {
    if (comment == _comment || !mounted) return;
    setState(() => _comment = comment);
  }

  TransactionRequest _createRequest() {
    final initialTransactionId = widget.initialTransaction?.id;
    final accountId = _account?.id;
    if (accountId == null) {
      throw AppException$Simple(context.l10n.selectAccount);
    }
    final transactionCategoryId = _transactionCategory?.id;
    if (transactionCategoryId == null) {
      throw AppException$Simple(context.l10n.selectArticle);
    }
    return initialTransactionId == null
        ? TransactionRequest.create(
            accountId: accountId,
            categoryId: transactionCategoryId,
            amount: _amount.toString(),
            transactionDate: _transactionDate,
            comment: _comment,
          )
        : TransactionRequest.update(
            id: initialTransactionId,
            accountId: accountId,
            categoryId: transactionCategoryId,
            amount: _amount.toString(),
            transactionDate: _transactionDate,
            comment: _comment,
          );
  }
}

/// {@template _SelectAmountDialog.class}
/// _SelectAmountDialog widget.
/// {@endtemplate}
class _SelectAmountDialog extends StatefulWidget {
  /// {@macro _SelectAmountDialog.class}
  const _SelectAmountDialog({required this.inputAmount, required this.currency});

  final Currency currency;
  final num inputAmount;

  @override
  State<_SelectAmountDialog> createState() => _SelectAmountDialogState();
}

class _SelectAmountDialogState extends State<_SelectAmountDialog> {
  late num _amount;
  late String _decimalSeparator;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(_calculateFractionalPartSeparator);
    _amount = widget.inputAmount;
    super.didChangeDependencies();
  }

  void _onChanged(String value) {
    String newAmount = value.trim();
    if (newAmount.endsWith(_decimalSeparator)) {
      newAmount += '0';
    }
    if (_decimalSeparator != '.') {
      newAmount = newAmount.replaceAll(_decimalSeparator, '.');
    }
    final newAmountNum = newAmount.amountToNum();
    if (newAmountNum == _amount) return;
    setState(() => _amount = newAmountNum);
  }

  void _calculateFractionalPartSeparator() {
    final numberFormat = NumberFormat.decimalPattern(context.l10n.localeName);
    final decimalSeparator = numberFormat.symbols.DECIMAL_SEP;
    _decimalSeparator = decimalSeparator;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.l10n.inputAmount),
        content: TextFormField(
          onChanged: _onChanged,
          initialValue: NumberFormat.decimalPattern(context.l10n.localeName).format(_amount),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: widget.currency.symbol,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            DecimalSanitizerFormatter(fractionalLength: 1, decimalSeparator: _decimalSeparator),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _amount == widget.inputAmount ? null : () => context.maybePop(_amount),
            child: Text(context.l10n.save),
          ),
          TextButton(onPressed: () => context.maybePop(), child: Text(context.l10n.cancel)),
        ],
      );
}

/// {@template _SaveTransactionButton.class}
/// _SaveTransactionButton widget.
/// {@endtemplate}
class _SaveTransactionButton extends StatefulWidget {
  /// {@macro _SaveTransactionButton.class}
  const _SaveTransactionButton(this.onSaveTap);

  final Future<void> Function() onSaveTap;

  @override
  State<_SaveTransactionButton> createState() => _SaveTransactionButtonState();
}

class _SaveTransactionButtonState extends State<_SaveTransactionButton> with ProcessingStateMixin {
  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: () => doProcessing(widget.onSaveTap),
        icon: isProcessing
            ? TypedProgressIndicator.small(indicatorColor: Theme.of(context).colorScheme.onPrimary)
            : const Icon(Icons.done),
      );
}

/// {@template _DeleteTransactionButton.class}
/// Кнопка удаления транзакции
/// {@endtemplate}
class _DeleteTransactionButton extends StatefulWidget {
  /// {@macro _DeleteTransactionButton.class}
  const _DeleteTransactionButton({required this.onDeleteTap, required this.isIncome});

  final bool isIncome;
  final Future<void> Function(int id) onDeleteTap;

  @override
  State<_DeleteTransactionButton> createState() => _DeleteTransactionButtonState();
}

class _DeleteTransactionButtonState extends State<_DeleteTransactionButton> with ProcessingStateMixin {
  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, transactionState) => switch (transactionState) {
          _ when transactionState.transaction != null => Padding(
              padding: const HorizontalSpacing.compact(),
              child: ElevatedButton(
                onPressed: () => doProcessing(() => widget.onDeleteTap.call(transactionState.transaction!.id)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColorScheme.of(context).error),
                child: isProcessing
                    ? const TypedProgressIndicator.small()
                    : Text(widget.isIncome ? context.l10n.deleteIncome : context.l10n.deleteExpense),
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      );
}
