import 'package:yang_money_catcher/features/pin_authentication/data/source/local/pin_config_storage.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/repository/pin_authentication_repository.dart';

final class PinAuthenticationRepositoryImpl implements PinAuthenticationRepository {
  const PinAuthenticationRepositoryImpl(this._pinConfigStorage);

  final PinConfigStorage _pinConfigStorage;

  @override
  Future<void> changeBiometricPreference(bool shouldAllowBiometric) =>
      _pinConfigStorage.changeBiometricPreference(shouldAllowBiometric);

  @override
  Future<PinConfig> changePinCode(String pin) => _pinConfigStorage.changePinCode(pin);

  @override
  Future<PinAuthenticationStatus> checkAuthenticationStatus([String? pinCode]) async {
    if (pinCode == null) {
      final pinConfig = await _pinConfigStorage.fetchPinConfig();

      return pinConfig.pinHash == null ? PinAuthenticationStatus.disabled : PinAuthenticationStatus.unauthenticated;
    }
    final pinChecked = await _pinConfigStorage.checkPinCode(pinCode);
    if (!pinChecked) throw const PinException$Invalid('Invalid pin {checkAuthenticationStatus}');
    return PinAuthenticationStatus.authenticated;
  }

  @override
  Future<PinConfig> resetPin() => _pinConfigStorage.resetPin();
}
