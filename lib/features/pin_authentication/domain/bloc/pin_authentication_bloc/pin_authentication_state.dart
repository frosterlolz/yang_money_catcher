part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationState with _$PinAuthenticationState {
  const PinAuthenticationState._();

  const factory PinAuthenticationState.processing({
    required PinConfig pinConfig,
    required int pinBuffer,
  }) = PinAuthenticationState$Processing;

  const factory PinAuthenticationState.idle({
    required PinConfig pinConfig,
    required int pinBuffer,
  }) = PinAuthenticationState$Idle;

  const factory PinAuthenticationState.error({
    required PinConfig pinConfig,
    required int pinBuffer,
    required Object error,
  }) = PinAuthenticationState$Error;

  bool get isAuthenticated => pinBuffer == pinConfig.pinCode;
}
