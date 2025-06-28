import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';

/// {@template AccountsScope.class}
/// AccountsScope widget.
/// {@endtemplate}
class AccountsScope extends StatelessWidget {
  /// {@macro AccountsScope.class}
  const AccountsScope({required this.accountRepository,required this.child, super.key});

  final AccountRepository accountRepository;
  final Widget child;

  void _accountChangesListener(BuildContext context, AccountsState state) {
    final accounts = state.accounts;
    // TODO(frosterlolz): полагаю в будущем логика обновится с возможностью выбора конкретного счета
    final firstAccount = accounts?.firstOrNull;
    if (firstAccount == null) return;
    context.read<AccountBloc>().add(AccountEvent.load(firstAccount.id));
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AccountsBloc(accountRepository)..add(const AccountsEvent.load())),
        BlocProvider(create: (_) => AccountBloc(accountRepository)),
      ],
      child: BlocListener<AccountsBloc, AccountsState>(listener: _accountChangesListener, child: child),
    );
}
