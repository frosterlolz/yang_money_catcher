import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/presentation/widgets/accounts_empty_view.dart';

typedef AccountItemsBuilder = Widget Function(List<AccountEntity> accounts);

/// {@template AccountsLoaderWrapper.class}
/// AccountsLoaderWrapper widget.
/// {@endtemplate}
class AccountsLoaderWrapper extends StatelessWidget {
  /// {@macro AccountsLoaderWrapper.class}
  const AccountsLoaderWrapper(this.accountItemsBuilder, {super.key});

  final AccountItemsBuilder accountItemsBuilder;

  void _onRetryTap(BuildContext context) => context.read<AccountsBloc>().add(const AccountsEvent.load());

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, accountsState) => switch (accountsState) {
          _ when accountsState.accounts?.isNotEmpty ?? false => accountItemsBuilder.call(accountsState.accounts!),
          _ when accountsState.accounts?.isEmpty ?? false => const AccountsEmptyView(),
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
