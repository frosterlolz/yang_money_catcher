import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

abstract interface class PinConfigStorage {
  /// Проверяет, включена ли биометрия
  Future<BiometricPreference> fetchBiometricPreference();

  /// Включает/выключает биометрию
  Future<void> changeBiometricPreference(BiometricPreference preference);

  /// Проверяет, установлен ли Pin-код
  Future<bool> hasPinCode();

  /// Изменяет Pin-код
  /// [oldPinCode] - старый Pin-код, если ранее был установлен- обязательно указывать
  /// [newPinCode] - новый Pin-код
  /// Если [oldPinCode] указан и он совпадает с текущим Pin-кодом в сторедже, то [newPinCode] устанавливается
  Future<bool> changePinCode({
    String? oldPinCode,
    required String newPinCode,
  });

  /// Проверяет Pin-код
  Future<bool> checkPinCode(String pinCode);

  /// Сбрасывает Pin-код
  Future<void> resetPin();
}
