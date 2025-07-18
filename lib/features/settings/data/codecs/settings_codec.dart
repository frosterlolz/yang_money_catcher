import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/features/settings/data/codecs/theme_config_codec.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/theme_configuration.dart';

/// {@template settings_codec}
/// Кодек для кодирования и декодирования настроек
/// {@endtemplate}
class SettingsCodec extends Codec<Settings, JsonMap> {
  /// {@macro settings_codec}
  const SettingsCodec(this.initialSettings);

  final Settings initialSettings;

  @override
  Converter<JsonMap, Settings> get decoder => _SettingsDecoder(
        initialLocale: initialSettings.locale,
        initialThemeConfiguration: initialSettings.themeConfig,
        initialHapticType: initialSettings.hapticType,
      );

  @override
  Converter<Settings, JsonMap> get encoder => const _SettingsEncoder();
}

class _SettingsEncoder extends Converter<Settings, JsonMap> {
  const _SettingsEncoder();

  static const _themeConfigurationCodec = ThemeConfigurationCodec();

  @override
  JsonMap convert(Settings input) => {
        'locale': input.locale.languageCode,
        'themeConfiguration': _themeConfigurationCodec.encode(input.themeConfig),
        'hapticType': input.hapticType.name,
      };
}

class _SettingsDecoder extends Converter<JsonMap, Settings> {
  const _SettingsDecoder({
    required this.initialLocale,
    required this.initialThemeConfiguration,
    required this.initialHapticType,
  });

  final Locale initialLocale;
  final ThemeConfiguration initialThemeConfiguration;
  final HapticType initialHapticType;

  static const _themeConfigurationCodec = ThemeConfigurationCodec();

  @override
  Settings convert(JsonMap input) {
    final locale = input['locale'] as String?;
    final themeConfigurationMap = input['themeConfiguration'] as JsonMap?;
    final hapticType = input['hapticType'] as String?;

    ThemeConfiguration? themeConfiguration;
    if (themeConfigurationMap != null) {
      themeConfiguration = _themeConfigurationCodec.decode(themeConfigurationMap);
    }

    return Settings(
      locale: locale == null ? initialLocale : Locale(locale),
      themeConfig: themeConfiguration ?? initialThemeConfiguration,
      hapticType: hapticType == null ? initialHapticType : HapticType.values.byName(hapticType),
    );
  }
}
