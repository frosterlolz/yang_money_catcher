abstract interface class PinConfigStorage {
  /// Проверяет, включена ли биометрия
  Future<bool> isBiometricEnabled();

  /// Включает/выключает биометрию
  Future<void> changeBiometricEnabled(bool isEnabled);

  /// Проверяет, установлен ли Pin-код
  Future<bool> hasPinCode();

  /// Изменяет Pin-код
  /// [oldPinCode] - старый Pin-код, если ранее был установлен- обязательно указывать
  /// [newPinCode] - новый Pin-код
  /// Если [oldPinCode] указан и он совпадает с текущим Pin-кодом в сторедже, то [newPinCode] устанавливается
  Future<bool> changePinCode({
    int? oldPinCode,
    required int newPinCode,
  });

  /// Проверяет Pin-код
  Future<bool> checkPinCode(int pinCode);
}
