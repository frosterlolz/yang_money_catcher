import 'dart:convert';

import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

/// {@template pin_config_codec}
/// Кодек для кодирования и декодирования конфигурации пин-кода
/// {@endtemplate}
class PinConfigCodec extends Codec<PinConfig, JsonMap> {
  /// {@macro pin_config_codec}
  const PinConfigCodec();

  @override
  Converter<JsonMap, PinConfig> get decoder => const _PinConfigDecoder();

  @override
  Converter<PinConfig, JsonMap> get encoder => const _PinConfigEncoder();
}

class _PinConfigEncoder extends Converter<PinConfig, JsonMap> {
  const _PinConfigEncoder();

  @override
  JsonMap convert(PinConfig input) => {
        'pinCode': input.pinCode,
        'isBiometricEnabled': input.isBiometricEnabled,
      };
}

class _PinConfigDecoder extends Converter<JsonMap, PinConfig> {
  const _PinConfigDecoder();

  @override
  PinConfig convert(JsonMap input) {
    if (input case {'pinCode': final String? pinCode, 'isBiometricEnabled': final bool isBiometricEnabled}) {
      return PinConfig(
        pinCode: pinCode,
        isBiometricEnabled: isBiometricEnabled,
      );
    }

    throw FormatException('Invalid pin configuration format: $input');
  }
}
