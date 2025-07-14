import 'package:flutter/material.dart' show Locale, ThemeMode, immutable;
import 'package:yang_money_catcher/features/settings/domain/enity/theme_configuration.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

@immutable
class Settings {
  const Settings({
    required this.themeConfig,
    required this.locale,
  });

  final ThemeConfiguration themeConfig;
  final Locale locale;

  static final initial = Settings(
    themeConfig: ThemeConfiguration(
      seedColor: const AppColorScheme.light().primary,
      themeMode: ThemeMode.light,
    ),
    locale: const Locale('ru'),
  );

  Settings copyWith({
    ThemeConfiguration? themeConfig,
    Locale? locale,
  }) =>
      Settings(
        themeConfig: themeConfig ?? this.themeConfig,
        locale: locale ?? this.locale,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          runtimeType == other.runtimeType &&
          themeConfig == other.themeConfig &&
          locale == other.locale;

  @override
  int get hashCode => themeConfig.hashCode ^ locale.hashCode;
}
