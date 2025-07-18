import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/codecs/pin_config_codec.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/source/local/pin_config_storage.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_hasher.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

const _pinConfigStorageKey = 'pin_config';
const _effectivePinLength = 4;

final class PinConfigStorageImpl implements PinConfigStorage {
  PinConfigStorageImpl(this._storage, {int? defaultPinLength})
      : _codec = PinConfigCodec(defaultPinLength ?? _effectivePinLength),
        _pinHasher = const PinHasher();

  final FlutterSecureStorage _storage;
  final PinConfigCodec _codec;
  final PinHasher _pinHasher;

  @override
  Future<PinConfig> fetchPinConfig() async {
    final configJson = await _storage.read(key: _pinConfigStorageKey);
    return _codec.decode(configJson == null ? {} : jsonDecode(configJson) as JsonMap);
  }

  @override
  Future<void> changeBiometricPreference(bool shouldAllowBiometric) async {
    final oldConfig = await fetchPinConfig();
    if (oldConfig.shouldAllowBiometric == shouldAllowBiometric) return;
    final newConfig = oldConfig.copyWith(shouldAllowBiometric: shouldAllowBiometric);
    await _writePinConfig(newConfig);
  }

  @override
  Future<PinConfig> changePinCode(String pin) async {
    final oldConfig = await fetchPinConfig();
    final newHash = _pinHasher.hashPin(pin);
    // Нечего менять- коды совпадают
    if (oldConfig.pinHash == newHash) return oldConfig;
    final newConfig = oldConfig.copyWith(pinHash: newHash, pinLength: pin.length);
    await _writePinConfig(newConfig);
    return newConfig;
  }

  @override
  Future<bool> checkPinCode(String pinCode) async {
    final pinConfig = await fetchPinConfig();
    final storedHash = pinConfig.pinHash;
    if (storedHash == null) return false;
    return _pinHasher.verify(pinCode, storedHash);
  }

  @override
  Future<PinConfig> resetPin() async {
    final oldConfig = await fetchPinConfig();
    if (oldConfig.pinHash == null) return oldConfig;
    final newConfig = PinConfig(
      pinHash: null,
      pinLength: _codec.fallbackPinLength,
      shouldAllowBiometric: oldConfig.shouldAllowBiometric,
    );
    await _writePinConfig(newConfig);
    return newConfig;
  }

  Future<void> _writePinConfig(PinConfig config) async {
    final configMap = _codec.encode(config);
    await _storage.write(key: _pinConfigStorageKey, value: jsonEncode(configMap));
  }
}
