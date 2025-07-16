part of 'pin_authentication_bloc.dart';

@freezed
sealed class PinAuthenticationEvent with _$PinAuthenticationEvent {
  const factory PinAuthenticationEvent.signIn(String pin) = _SignIn;
  const factory PinAuthenticationEvent.signUp(String pin) = _SignUp;
  const factory PinAuthenticationEvent.verifyAccess(String pin) = _VerifyAccess;
  const factory PinAuthenticationEvent.changePin({required String oldPin, required String newPin}) = _ChangePin;
  const factory PinAuthenticationEvent.changeBiometricStatus(BiometricPreference preference) = _ChangeBiometricStatus;
  const factory PinAuthenticationEvent.resetPin() = _ResetPin;
}
