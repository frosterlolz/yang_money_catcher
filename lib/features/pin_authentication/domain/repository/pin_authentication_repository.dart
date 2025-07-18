import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

abstract interface class PinAuthenticationRepository {
  Future<void> changeBiometricPreference(bool shouldAllowBiometric);
  Future<PinConfig> changePinCode(String pin);
  Future<PinAuthenticationStatus> checkAuthenticationStatus([String? pinCode]);
  Future<PinConfig> resetPin();
}
