import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/src/l10n/app_localizations.g.dart';

/// {@template localization}
/// Localization class which is used to localize app.
/// This class provides handy methods and tools.
/// {@endtemplate}
final class Localization {
  /// {@macro localization}
  const Localization._({required this.locale});

  /// List of supported locales.
  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  static const _delegate = AppLocalizations.delegate;

  /// List of localization delegates.
  static List<LocalizationsDelegate<void>> get localizationDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        _delegate,
      ];

  /// {@macro localization}
  static Localization? get current => _current;

  /// {@macro localization}
  static Localization? _current;

  /// Locale which is currently used.
  final Locale locale;

  /// Computes the default locale.
  ///
  /// This is the locale that is used when no locale is specified.
  // ignore: prefer_expression_function_bodies
  static Locale computeDefaultLocale() {
    // TODO(initialization): uncomment, if needed
    // final locale = WidgetsBinding.instance.platformDispatcher.locale;
    //
    // if (_delegate.isSupported(locale)) return locale;

    return const Locale('ru');
  }

  /// Obtain [AppLocalizations] instance from [BuildContext].
  static AppLocalizations of(BuildContext context) =>
      AppLocalizations.of(context) ?? (throw ArgumentError('No Localization found in context'));
}
