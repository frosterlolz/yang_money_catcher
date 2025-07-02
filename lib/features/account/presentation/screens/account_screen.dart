import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/core/presentation/common/processing_state_mixin.dart';
import 'package:yang_money_catcher/core/presentation/common/visibility_by_tilt_mixin.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_change_request.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/account_currency_bottom_sheet.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_loader_wrapper.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';
import 'package:yang_money_catcher/ui_kit/dialogs/text_confirm_dialog.dart';
import 'package:yang_money_catcher/ui_kit/loaders/typed_progress_indicator.dart';
import 'package:yang_money_catcher/ui_kit/placeholders/noise_placeholder.dart';

/// {@template AccountScreen.class}
/// Экран отображения баланса, валюты, а также движений по счету
/// {@endtemplate}
@RoutePage()
class AccountScreen extends StatelessWidget {
  /// {@macro AccountScreen.class}
  const AccountScreen({super.key});

  void _onRetryTap(BuildContext context, int accountId) =>
      context.read<AccountBloc>().add(AccountEvent.load(accountId));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.myAccount)),
        body: AccountsLoaderWrapper(
          (accounts) => BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) => switch (accountState) {
              _ when accountState.account != null => _AccountSuccessView(accountState.account!),
              AccountState$Error(:final error) =>
                ErrorBodyView.fromError(error, onRetryTap: () => _onRetryTap(context, accounts.first.id)),
              _ => const LoadingBodyView(),
            },
          ),
        ),
      );
}

/// {@template _AccountSuccessView.class}
/// _AccountSuccessView widget.
/// {@endtemplate}
class _AccountSuccessView extends StatelessWidget {
  /// {@macro _AccountSuccessView.class}
  const _AccountSuccessView(this.account);

  final AccountDetailEntity account;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          ...ListTile.divideTiles(
            context: context,
            tiles: [
              // balance
              _AccountBalanceTile(account: account),
              // currency
              _AccountCurrencyTile(account: account),
            ],
          ),
        ],
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
        await accountBloc.stream.firstWhere((state) => state is AccountState$Processing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColorScheme = AppColorScheme.of(context);

    return ListTile(
      onTap: isProcessing ? null : _onBalanceTap,
      tileColor: colorScheme.secondary,
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
        color: appColorScheme.labelTertiary.withValues(alpha: AppSizes.double03),
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
    final colorScheme = Theme.of(context).colorScheme;
    final appColorScheme = AppColorScheme.of(context);

    return ListTile(
      onTap: isProcessing ? null : _onCurrencyTap,
      tileColor: colorScheme.secondary,
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
        color: appColorScheme.labelTertiary.withValues(alpha: AppSizes.double03),
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
