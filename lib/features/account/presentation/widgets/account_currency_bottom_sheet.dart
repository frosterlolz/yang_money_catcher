import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

Future<Currency?> showAccountCurrencyBottomSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AccountCurrencyBottomSheet(),
    );

/// {@template _AccountCurrencyBottomSheet.class}
/// _AccountCurrencyBottomSheet widget.
/// {@endtemplate}
class _AccountCurrencyBottomSheet extends StatelessWidget {
  /// {@macro _AccountCurrencyBottomSheet.class}
  const _AccountCurrencyBottomSheet();

  void _onCurrencyTap(BuildContext context, Currency? currency) {
    context.maybePop(currency);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ...Currency.values.map(
              (e) => ListTile(
                onTap: () => _onCurrencyTap(context, e),
                leading: Text(e.symbol),
                title: Text(context.l10n.currencyValue(e.key)),
              ),
            ),
            ListTile(
              onTap: () => _onCurrencyTap(context, null),
              tileColor: colorScheme.error,
              textColor: colorScheme.onError,
              iconColor: colorScheme.onError,
              leading: const Icon(Icons.cancel_outlined),
              title: Text(context.l10n.cancelAction),
            ),
          ],
        ).toList(),
      ),
    );
  }
}
