import 'package:flutter/foundation.dart' show immutable;

@immutable
class PinConfig {
  const PinConfig({
    required this.pinCode,
    required this.biometricPreference,
  });

  final String? pinCode;
  final BiometricPreference biometricPreference;

  PinConfig copyWith({
    String? pinCode,
    BiometricPreference? biometricPreference,
  }) =>
      PinConfig(
        pinCode: pinCode ?? this.pinCode,
        biometricPreference: biometricPreference ?? this.biometricPreference,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinConfig &&
          runtimeType == other.runtimeType &&
          pinCode == other.pinCode &&
          biometricPreference == other.biometricPreference;

  @override
  int get hashCode => Object.hash(pinCode, biometricPreference);
}

enum PinAuthenticationStatus { authenticated, unauthenticated, disabled }

enum BiometricPreference { face, fingerprint, disabled }
