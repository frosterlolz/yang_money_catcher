import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';

/// {@template AccountsEmptyView.class}
/// AccountsEmptyView widget.
/// {@endtemplate}
class AccountsEmptyView extends StatelessWidget {
  /// {@macro AccountsEmptyView.class}
  const AccountsEmptyView({super.key});

  void _onReloadAccountsTap(BuildContext context) => context.read<AccountsBloc>().add(const AccountsEvent.load());

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const HorizontalSpacing.compact(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                context.l10n.accountsAreEmpty,
                textAlign: TextAlign.center,
                style: TextTheme.of(context).titleMedium,
              ),
              const Spacer(),
              ElevatedButton(onPressed: () => _onReloadAccountsTap(context), child: Text(context.l10n.update)),
              const SizedBox(height: AppSizes.double10),
            ],
          ),
        ),
      );
}
