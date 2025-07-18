import 'package:local_auth/local_auth.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

final class LocalAuthService {
  LocalAuthService() : _localAuthentication = LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> checkBiometricsAvailability() async {
    final canAuthWithBiometrics = await _localAuthentication.canCheckBiometrics;

    return canAuthWithBiometrics || await _localAuthentication.isDeviceSupported();
  }

  Future<BiometricPreference?> getBiometricAvailableType() async {
    if (!await checkBiometricsAvailability()) return null;
    final availableBiometrics = await _localAuthentication.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) return null;

    final isFingerprint = availableBiometrics
        .any((availableType) => [BiometricType.fingerprint, BiometricType.strong].any((type) => type == availableType));
    final isFaceId = availableBiometrics
        .any((availableType) => [BiometricType.face, BiometricType.weak].any((type) => type == availableType));

    if (isFingerprint) return BiometricPreference.fingerprint;
    if (isFaceId) return BiometricPreference.face;

    return null;
  }

  Future<bool> authenticate(String localizedReason) =>
      _localAuthentication.authenticate(localizedReason: localizedReason);
}
