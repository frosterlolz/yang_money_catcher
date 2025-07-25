import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

typedef AccountDetailsBuilder = Widget Function(AccountDetailEntity account);

/// {@template AccountSelectedWrapper.class}
/// Враппер для экранов/виджетов, где необходимо иметь выбранный счет [AccountDetailEntity]
/// {@endtemplate}
class AccountSelectedWrapper extends StatefulWidget {
  /// {@macro AccountSelectedWrapper.class}
  const AccountSelectedWrapper(this.accountDetailsBuilder, {required this.accountId, super.key});

  final int accountId;
  final AccountDetailsBuilder accountDetailsBuilder;

  @override
  State<AccountSelectedWrapper> createState() => _AccountSelectedWrapperState();
}

class _AccountSelectedWrapperState extends State<AccountSelectedWrapper> {
  @override
  void initState() {
    super.initState();
    final accountBloc = context.read<AccountBloc>();
    if (accountBloc.state is AccountState$Processing) {
      accountBloc.add(AccountEvent.load(widget.accountId));
    }
  }

  void _onAccountReloadTap(BuildContext context) {
    context.read<AccountBloc>().add(AccountEvent.load(widget.accountId));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountBloc, AccountState>(
        builder: (context, accountState) => switch (accountState) {
          _ when accountState.account != null => widget.accountDetailsBuilder.call(accountState.account!),
          AccountState$Error(:final error) => ErrorBodyView(
              title: ErrorUtil.messageFromObject(context, error: error),
              retryButtonText: context.l10n.tryItAgain,
              description: context.l10n.retry,
              onRetryTap: () => _onAccountReloadTap(context),
            ),
          _ => const LoadingBodyView(),
        },
      );
}
