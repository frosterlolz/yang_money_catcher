import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template SettingsScreen.class}
/// Экран отображения настроек
/// {@endtemplate}
@RoutePage()
class SettingsScreen extends StatelessWidget {
  /// {@macro SettingsScreen.class}
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.settings)),
        body: Center(child: Text(context.l10n.settings)),
      );
}
