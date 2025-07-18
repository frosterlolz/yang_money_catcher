part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationEvent with _$PinAuthenticationEvent {
  const factory PinAuthenticationEvent.signIn(
    String pin, {
    @Default(false) bool forceWithBiometric,
  }) = _SignIn;
  const factory PinAuthenticationEvent.signUp(String pin) = _SignUp;
  const factory PinAuthenticationEvent.verifyAccess(
    String pin, {
    @Default(false) bool forceWithBiometric,
  }) = _VerifyAccess;
  const factory PinAuthenticationEvent.changePin(String v) = _ChangePin;
  const factory PinAuthenticationEvent.changeBiometricStatus(bool shouldAllowBiometric) = _ChangeBiometricStatus;
  const factory PinAuthenticationEvent.resetPin() = _ResetPin;
}
