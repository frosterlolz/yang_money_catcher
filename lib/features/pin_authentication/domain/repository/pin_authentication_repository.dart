import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

abstract interface class PinAuthenticationRepository {
  Future<BiometricPreference> readBiometricPreference();
  Future<void> changeBiometricPreference(BiometricPreference preference);
  Future<PinAuthenticationStatus> changePinCode({String? oldPinCode, required String newPinCode});
  Future<PinAuthenticationStatus> checkAuthenticationStatus([String? pinCode]);
  Future<void> resetPin();
}
