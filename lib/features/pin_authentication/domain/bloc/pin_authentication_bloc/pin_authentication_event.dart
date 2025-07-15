part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationEvent with _$PinAuthenticationEvent {
  const factory PinAuthenticationEvent.signIn(int pin) = _SignIn;
  const factory PinAuthenticationEvent.changePin(int pin) = _ChangePin;
  const factory PinAuthenticationEvent.changeBiometricStatus(bool enable) = _ChangeBiometricStatus;
}
