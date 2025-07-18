import 'package:flutter/material.dart' show Locale, ThemeMode, immutable;
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/theme_configuration.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

@immutable
class Settings {
  const Settings({
    required this.themeConfig,
    required this.locale,
    required this.hapticType,
  });

  final ThemeConfiguration themeConfig;
  final Locale locale;
  final HapticType hapticType;

  static final initial = Settings(
    themeConfig: ThemeConfiguration(
      seedColor: const AppColorScheme.light().primary,
      themeMode: ThemeMode.light,
    ),
    locale: const Locale('ru'),
    hapticType: HapticType.heavy,
  );

  Settings copyWith({
    ThemeConfiguration? themeConfig,
    Locale? locale,
    HapticType? hapticType,
  }) =>
      Settings(
        themeConfig: themeConfig ?? this.themeConfig,
        locale: locale ?? this.locale,
        hapticType: hapticType ?? this.hapticType,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          runtimeType == other.runtimeType &&
          themeConfig == other.themeConfig &&
          locale == other.locale &&
          hapticType == other.hapticType;

  @override
  int get hashCode => Object.hash(themeConfig, locale, hapticType);
}
