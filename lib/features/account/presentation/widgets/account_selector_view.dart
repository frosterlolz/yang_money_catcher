import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/core/utils/extensions/string_x.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

/// {@template AccountSelectorView.class}
/// AccountSelectorView widget.
/// {@endtemplate}
class AccountSelectorView extends StatelessWidget {
  /// {@macro AccountSelectorView.class}
  const AccountSelectorView({super.key, this.currentAccountId});

  final int? currentAccountId;

  void _onRetryTap(BuildContext context) => context.read<AccountsBloc>().add(const AccountsEvent.load());

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, accountsState) => switch (accountsState) {
          _ when accountsState.accounts != null =>
            _AccountItemsView(accountsState.accounts!, currentAccountId: currentAccountId),
          AccountsState$Error(:final error) => ErrorBodyView(
              title: ErrorUtil.messageFromObject(context, error: error),
              retryButtonText: context.l10n.tryItAgain,
              description: context.l10n.retry,
              onRetryTap: () => _onRetryTap(context),
            ),
          _ => const LoadingBodyView(),
        },
      );
}

/// {@template _AccountItemsView.class}
/// _AccountItemsView widget.
/// {@endtemplate}
class _AccountItemsView extends StatelessWidget {
  /// {@macro _AccountItemsView.class}
  const _AccountItemsView(this.items, {this.currentAccountId});

  final int? currentAccountId;
  final List<AccountEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(context.l10n.accountsAreEmpty));
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final balance = item.balance.amountToNum().thousandsSeparated().withCurrency(item.currency.symbol, 1);
        return ListTile(
          key: Key('account_item_$index'),
          title: Text(item.name),
          subtitle: Text('${context.l10n.balance}: $balance'),
          trailing:
              currentAccountId == item.id ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
          onTap: () => context.maybePop(item),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}
