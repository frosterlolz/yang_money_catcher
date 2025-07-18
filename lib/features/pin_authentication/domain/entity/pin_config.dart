import 'package:flutter/foundation.dart' show immutable;

@immutable
class PinConfig {
  const PinConfig({
    required this.pinHash,
    required this.pinLength,
    required this.shouldAllowBiometric,
  });

  final String? pinHash;
  final int pinLength;
  final bool shouldAllowBiometric;

  PinConfig copyWith({
    String? pinHash,
    bool? shouldAllowBiometric,
    int? pinLength,
  }) =>
      PinConfig(
        pinHash: pinHash ?? this.pinHash,
        pinLength: pinLength ?? this.pinLength,
        shouldAllowBiometric: shouldAllowBiometric ?? this.shouldAllowBiometric,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinConfig &&
          runtimeType == other.runtimeType &&
          pinHash == other.pinHash &&
          shouldAllowBiometric == other.shouldAllowBiometric &&
          pinLength == other.pinLength;

  @override
  int get hashCode => Object.hash(pinHash, shouldAllowBiometric, pinLength);
}

enum PinAuthenticationStatus { authenticated, unauthenticated, disabled }

enum BiometricPreference { face, fingerprint, disabled }
