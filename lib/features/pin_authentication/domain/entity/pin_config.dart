import 'package:flutter/foundation.dart' show immutable;

@immutable
class PinConfig {
  const PinConfig({
    required this.pinCode,
    required this.isBiometricEnabled,
  });

  final String? pinCode;
  final bool isBiometricEnabled;

  PinConfig copyWith({
    String? pinCode,
    bool? isBiometricEnabled,
  }) =>
      PinConfig(
        pinCode: pinCode ?? this.pinCode,
        isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinConfig &&
          runtimeType == other.runtimeType &&
          pinCode == other.pinCode &&
          isBiometricEnabled == other.isBiometricEnabled;

  @override
  int get hashCode => Object.hash(pinCode, isBiometricEnabled);
}
