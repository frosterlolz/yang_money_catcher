import 'dart:convert';

import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

/// {@template pin_config_codec}
/// Кодек для кодирования и декодирования конфигурации пин-кода
/// {@endtemplate}
class PinConfigCodec extends Codec<PinConfig, JsonMap> {
  /// {@macro pin_config_codec}
  const PinConfigCodec(this.fallbackPinLength);

  final int fallbackPinLength;

  @override
  Converter<JsonMap, PinConfig> get decoder => _PinConfigDecoder(fallbackPinLength);

  @override
  Converter<PinConfig, JsonMap> get encoder => const _PinConfigEncoder();
}

class _PinConfigEncoder extends Converter<PinConfig, JsonMap> {
  const _PinConfigEncoder();

  @override
  JsonMap convert(PinConfig input) => {
        'pinCode': input.pinHash,
        'shouldAllowBiometric': input.shouldAllowBiometric,
        'pinLength': input.pinLength,
      };
}

class _PinConfigDecoder extends Converter<JsonMap, PinConfig> {
  const _PinConfigDecoder(this._fallbackPinLength);

  final int _fallbackPinLength;

  @override
  PinConfig convert(JsonMap input) => PinConfig(
        pinHash: input['pinCode'] as String?,
        shouldAllowBiometric: (input['shouldAllowBiometric'] as bool?) ?? true,
        pinLength: (input['pinLength'] as int?) ?? _fallbackPinLength,
      );
}
