import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/codecs/pin_config_codec.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/source/local/pin_config_storage.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_hasher.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

const _pinConfigStorageKey = 'pin_config';

final class PinConfigStorageImpl implements PinConfigStorage {
  const PinConfigStorageImpl(this._storage)
      : _codec = const PinConfigCodec(),
        _pinHasher = const PinHasher();

  final FlutterSecureStorage _storage;
  final PinConfigCodec _codec;
  final PinHasher _pinHasher;

  @override
  Future<void> changeBiometricPreference(BiometricPreference preference) async {
    final oldConfig = await _readPinConfig();
    if (oldConfig.biometricPreference == preference) return;
    final newConfig = oldConfig.copyWith(biometricPreference: preference);
    await _writePinConfig(newConfig);
  }

  @override
  Future<BiometricPreference> fetchBiometricPreference() async {
    final pinConfig = await _readPinConfig();
    return pinConfig.biometricPreference;
  }

  @override
  Future<bool> changePinCode({String? oldPinCode, required String newPinCode}) async {
    final oldConfig = await _readPinConfig();
    final storedHash = oldConfig.pinCode;
    final isFirstTime = storedHash == null;
    if (isFirstTime) return _writePinCode(newPinCode, oldConfig);

    final isOldPinCorrect = oldPinCode != null && _pinHasher.verify(oldPinCode, storedHash);
    if (!isOldPinCorrect) throw PinException$Invalid('Invalid old pin $oldPinCode');
    return _writePinCode(newPinCode, oldConfig);
  }

  @override
  Future<bool> checkPinCode(String pinCode) async {
    final pinConfig = await _readPinConfig();
    final storedHash = pinConfig.pinCode;
    if (storedHash == null) return false;
    return _pinHasher.verify(pinCode, storedHash);
  }

  @override
  Future<bool> hasPinCode() async {
    final pinConfig = await _readPinConfig();
    return pinConfig.pinCode != null;
  }

  @override
  Future<void> resetPin() async {
    final oldConfig = await _readPinConfig();
    final newConfig = PinConfig(pinCode: null, biometricPreference: oldConfig.biometricPreference);
    await _writePinConfig(newConfig);
  }

  Future<bool> _writePinCode(String pinCode, PinConfig oldConfig) async {
    final newHash = _pinHasher.hashPin(pinCode);
    // Нечего менять- коды совпадают
    if (oldConfig.pinCode == newHash) return true;
    final newConfig = oldConfig.copyWith(pinCode: newHash);
    await _writePinConfig(newConfig);
    return true;
  }

  Future<PinConfig> _readPinConfig() async {
    final configJson = await _storage.read(key: _pinConfigStorageKey);
    return _codec.decode(configJson == null ? {} : jsonDecode(configJson) as JsonMap);
  }

  Future<void> _writePinConfig(PinConfig config) async {
    final configMap = _codec.encode(config);
    await _storage.write(key: _pinConfigStorageKey, value: jsonEncode(configMap));
  }
}
