import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

abstract interface class PinConfigStorage {
  /// Возвращает текущую конфигурацию
  Future<PinConfig> fetchPinConfig();

  /// Включает/выключает биометрию
  Future<void> changeBiometricPreference(bool shouldAllowBiometric);

  /// Изменяет Pin-код
  Future<PinConfig> changePinCode(String pin);

  /// Проверяет Pin-код
  Future<bool> checkPinCode(String pinCode);

  /// Сбрасывает Pin-код
  Future<PinConfig> resetPin();
}
