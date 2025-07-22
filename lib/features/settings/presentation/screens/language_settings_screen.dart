import 'package:auto_route/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';

/// {@template LanguageSettingsScreen.class}
/// LanguageSettingsScreen widget.
/// {@endtemplate}
@RoutePage()
class LanguageSettingsScreen extends StatelessWidget {
  /// {@macro LanguageSettingsScreen.class}
  const LanguageSettingsScreen({super.key});

  void _onLocaleTap(BuildContext context, Locale locale) {
    context.read<SettingsBloc>().add(SettingsEvent.updateLocale(locale));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.language)),
      body: Padding(
        padding: const HorizontalSpacing.compact().copyWith(top: AppSizes.double16),
        child: Column(
          children: [
            BlocSelector<SettingsBloc, SettingsState, Locale>(
              selector: (state) => state.settings.locale,
              builder: (context, selectedLocale) => Card(
                child: Column(
                  children: ListTile.divideTiles(
                    context: context,
                    tiles: Localization.supportedLocales.map(
                      (locale) => ListTile(
                        onTap: () => _onLocaleTap(context, locale),
                        title: AppText.labelLarge(
                          context.l10n.localeTitle(locale.languageCode),
                          color: colorScheme.onSecondary,
                        ),
                        trailing: locale == selectedLocale ? Icon(Icons.done, color: colorScheme.onSecondary) : null,
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
