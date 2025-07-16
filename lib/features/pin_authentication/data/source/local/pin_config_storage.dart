import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

abstract interface class PinConfigStorage {
  /// Проверяет, включена ли биометрия
  Future<BiometricPreference> fetchBiometricPreference();

  /// Включает/выключает биометрию
  Future<void> changeBiometricPreference(BiometricPreference preference);

  /// Проверяет, установлен ли Pin-код
  Future<bool> hasPinCode();

  /// Изменяет Pin-код
  Future<bool> changePinCode(String pin);

  /// Проверяет Pin-код
  Future<bool> checkPinCode(String pinCode);

  /// Сбрасывает Pin-код
  Future<void> resetPin();
}
