import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/account_bloc/account_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/bloc/transactions_bloc/transactions_bloc.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

/// {@template TransactionsScope.class}
/// TransactionsScope widget.
/// {@endtemplate}
class TransactionsScope extends StatelessWidget {
  /// {@macro TransactionsScope.class}
  const TransactionsScope({required this.transactionsRepository, required this.child, super.key});

  final Widget child;
  final TransactionsRepository transactionsRepository;

  void _accountChangesListener(BuildContext context, AccountState state) {
    final accountId = state.account?.id;
    if (accountId == null) return;
    context.read<TransactionsBloc>().add(TransactionsEvent.load(accountId));
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => TransactionsBloc(transactionsRepository),
        child: BlocListener<AccountBloc, AccountState>(
          listenWhen: (o, c) => o.account?.id != c.account?.id,
          listener: _accountChangesListener,
          child: child,
        ),
      );
}
