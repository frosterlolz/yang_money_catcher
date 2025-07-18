import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/core/utils/extensions/color_x.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/theme_configuration.dart';

/// {@template theme_configuration_codec}
/// Кодек для кодирования и декодирования конфигурации темы
/// {@endtemplate}
class ThemeConfigurationCodec extends Codec<ThemeConfiguration, JsonMap> {
  /// {@macro theme_configuration_codec}
  const ThemeConfigurationCodec();

  @override
  Converter<JsonMap, ThemeConfiguration> get decoder => const _ThemeConfigurationDecoder();

  @override
  Converter<ThemeConfiguration, JsonMap> get encoder => const _ThemeConfigurationEncoder();
}

class _ThemeConfigurationEncoder extends Converter<ThemeConfiguration, JsonMap> {
  const _ThemeConfigurationEncoder();

  @override
  JsonMap convert(ThemeConfiguration input) => {
        'themeMode': input.themeMode.name,
        'seedColor': input.seedColor.toARGB32(),
      };
}

class _ThemeConfigurationDecoder extends Converter<JsonMap, ThemeConfiguration> {
  const _ThemeConfigurationDecoder();

  @override
  ThemeConfiguration convert(JsonMap input) {
    if (input
        case {
          'themeMode': final String themeMode,
          'seedColor': final int seedColor,
        }) {
      return ThemeConfiguration(
        themeMode: ThemeMode.values.byName(themeMode),
        seedColor: Color(seedColor),
      );
    }

    throw FormatException('Invalid theme configuration format: $input');
  }
}
