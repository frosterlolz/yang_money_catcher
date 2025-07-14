import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template SettingsScreen.class}
/// Экран отображения настроек
/// {@endtemplate}
@RoutePage()
class SettingsScreen extends StatelessWidget {
  /// {@macro SettingsScreen.class}
  const SettingsScreen({super.key});

  void _onThemeModeChanged(BuildContext context, {required ThemeMode themeMode}) {
    final nextValue = switch (themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
      ThemeMode.dark => throw UnsupportedError('Manual switch on dark theme not supported'),
    };
    final settingsBloc = context.read<SettingsBloc>();
    final currentSettings = settingsBloc.state.settings;
    settingsBloc.add(
      SettingsEvent.update(
        currentSettings.copyWith(themeConfig: currentSettings.themeConfig.copyWith(themeMode: nextValue)),
      ),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select main color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Colors.red,
            onColorChanged: (color) {},
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.settings)),
        body: SingleChildScrollView(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                BlocSelector<SettingsBloc, SettingsState, ThemeMode>(
                  selector: (state) => state.settings.themeConfig.themeMode,
                  builder: (context, themeMode) => SwitchListTile(
                    onChanged: (v) => _onThemeModeChanged(context, themeMode: themeMode),
                    title: Text(context.l10n.themeModeName(themeMode.name)),
                    value: switch (themeMode) {
                      ThemeMode.system => true,
                      _ => false,
                    },
                  ),
                ),
                ListTile(
                  title: Text(context.l10n.mainColor),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () => _showColorPicker(context),
                ),
                ListTile(
                  title: Text(context.l10n.sounds),
                  trailing: const Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text(context.l10n.haptics),
                  trailing: const Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text(context.l10n.codePassword),
                  trailing: const Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text(context.l10n.sync),
                  trailing: const Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text(context.l10n.language),
                  trailing: const Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text(context.l10n.appAbout),
                  trailing: const Icon(Icons.arrow_right),
                ),
                const Divider(),
              ],
            ).toList(),
          ),
        ),
      );
}
