import 'package:yang_money_catcher/features/pin_authentication/data/source/local/pin_config_storage.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/repository/pin_authentication_repository.dart';

final class PinAuthenticationRepositoryImpl implements PinAuthenticationRepository {
  const PinAuthenticationRepositoryImpl(this._pinConfigStorage);

  final PinConfigStorage _pinConfigStorage;

  @override
  Future<BiometricPreference> readBiometricPreference() => _pinConfigStorage.fetchBiometricPreference();

  @override
  Future<void> changeBiometricPreference(BiometricPreference preference) =>
      _pinConfigStorage.changeBiometricPreference(preference);

  @override
  Future<PinAuthenticationStatus> changePinCode(String pin) async {
    final isChanged = await _pinConfigStorage.changePinCode(pin);
    return isChanged ? PinAuthenticationStatus.authenticated : PinAuthenticationStatus.unauthenticated;
  }

  @override
  Future<PinAuthenticationStatus> checkAuthenticationStatus([String? pinCode]) async {
    if (pinCode == null) {
      final hasPin = await _pinConfigStorage.hasPinCode();
      return hasPin ? PinAuthenticationStatus.unauthenticated : PinAuthenticationStatus.disabled;
    }
    final pinChecked = await _pinConfigStorage.checkPinCode(pinCode);
    if (!pinChecked) throw const PinException$Invalid('Invalid pin {checkAuthenticationStatus}');
    return PinAuthenticationStatus.authenticated;
  }

  @override
  Future<void> resetPin() => _pinConfigStorage.resetPin();
}
