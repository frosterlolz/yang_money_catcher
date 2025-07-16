part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationState with _$PinAuthenticationState {
  const PinAuthenticationState._();

  const factory PinAuthenticationState.processing({
    required PinAuthenticationStatus status,
    required BiometricPreference biometricPreference,
  }) = PinAuthenticationState$Processing;

  const factory PinAuthenticationState.success({
    required PinAuthenticationStatus status,
    required BiometricPreference biometricPreference,
  }) = PinAuthenticationState$Success;

  const factory PinAuthenticationState.idle({
    required PinAuthenticationStatus status,
    required BiometricPreference biometricPreference,
  }) = PinAuthenticationState$Idle;

  const factory PinAuthenticationState.error({
    required PinAuthenticationStatus status,
    required BiometricPreference biometricPreference,
    required Object error,
  }) = PinAuthenticationState$Error;
}
