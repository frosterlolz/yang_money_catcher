part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationState with _$PinAuthenticationState {
  const PinAuthenticationState._();

  const factory PinAuthenticationState.processing({
    required PinAuthenticationStatus status,
    required int pinLength,
    required bool shouldAllowBiometric,
  }) = PinAuthenticationState$Processing;

  const factory PinAuthenticationState.success({
    required PinAuthenticationStatus status,
    required int pinLength,
    required bool shouldAllowBiometric,
  }) = PinAuthenticationState$Success;

  const factory PinAuthenticationState.idle({
    required PinAuthenticationStatus status,
    required int pinLength,
    required bool shouldAllowBiometric,
  }) = PinAuthenticationState$Idle;

  const factory PinAuthenticationState.error({
    required PinAuthenticationStatus status,
    required int pinLength,
    required bool shouldAllowBiometric,
    required Object error,
  }) = PinAuthenticationState$Error;
}
