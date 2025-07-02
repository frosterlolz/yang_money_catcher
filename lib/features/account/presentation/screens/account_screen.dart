import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_loader_wrapper.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/common/error_body_view.dart';
import 'package:yang_money_catcher/ui_kit/common/loading_body_view.dart';

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

  void _onBalanceTap() {
    // TODO(frosterlolz): реализовать
  }

  void _onCurrencyTap() {
    // TODO(frosterlolz): реализовать
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColorScheme = AppColorScheme.of(context);
    return ListView(
      children: [
        ...ListTile.divideTiles(
          context: context,
          tiles: [
            // balance
            ListTile(
              onTap: _onBalanceTap,
              tileColor: colorScheme.secondary,
              leading: SvgPicture.asset(SvgIcons.moneyBag),
              title: Row(
                children: [
                  Text(context.l10n.balance),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        account.balance.amountToNum().thousandsSeparated().withCurrency(account.currency.symbol, 1),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: appColorScheme.labelTertiary.withValues(alpha: AppSizes.double03),
              ),
            ),
            // currency
            ListTile(
              onTap: _onCurrencyTap,
              tileColor: colorScheme.secondary,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(context.l10n.currency), Text(account.currency.symbol)],
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: appColorScheme.labelTertiary.withValues(alpha: AppSizes.double03),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
