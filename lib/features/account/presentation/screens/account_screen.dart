import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template AccountScreen.class}
/// Экран отображения баланса, валюты, а также движений по счету
/// {@endtemplate}
@RoutePage()
class AccountScreen extends StatelessWidget {
  /// {@macro AccountScreen.class}
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.myAccount)),
        body: Center(child: Text(context.l10n.account)),
      );
}
