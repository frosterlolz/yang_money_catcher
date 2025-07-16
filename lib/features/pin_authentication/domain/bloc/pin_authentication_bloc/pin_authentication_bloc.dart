import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/repository/pin_authentication_repository.dart';

part 'pin_authentication_event.dart';
part 'pin_authentication_state.dart';
part 'pin_authentication_bloc.freezed.dart';

typedef _Emitter = Emitter<PinAuthenticationState>;

class PinAuthenticationBloc extends Bloc<PinAuthenticationEvent, PinAuthenticationState> {
  PinAuthenticationBloc(super.initialState, {required PinAuthenticationRepository pinAuthenticationRepository})
      : _pinAuthenticationRepository = pinAuthenticationRepository {
    on<PinAuthenticationEvent>(
      (event, emitter) => switch (event) {
        _SignIn() => _signIn(event, emitter),
        _ChangePin() => _changePin(event, emitter),
        _ChangeBiometricStatus() => _changeBiometricStatus(event, emitter),
        _SignUp() => _signUp(event, emitter),
        _ResetPin() => _resetPin(event, emitter),
        _VerifyAccess() => _verifyAccess(event, emitter),
      },
    );
  }

  final PinAuthenticationRepository _pinAuthenticationRepository;

  Future<void> _signIn(_SignIn event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    try {
      final nextStatus = await _pinAuthenticationRepository.checkAuthenticationStatus(event.pin);
      emitter(PinAuthenticationState.idle(status: nextStatus, biometricPreference: state.biometricPreference));
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );

      onError(e, s);
    }
  }

  Future<void> _changePin(_ChangePin event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    if (state.status != PinAuthenticationStatus.authenticated) {
      return emitter(
        PinAuthenticationState.error(
          status: state.status,
          biometricPreference: state.biometricPreference,
          error: const PinException$Forbidden('Cannot change pin from other state except Authenticated'),
        ),
      );
    }
    try {
      final nextStatus =
          await _pinAuthenticationRepository.changePinCode(newPinCode: event.newPin, oldPinCode: event.oldPin);
      emitter(PinAuthenticationState.success(status: nextStatus, biometricPreference: state.biometricPreference));
    } on PinException$Invalid catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );
      logger.warn(e.internalMessage, error: e, stackTrace: s);
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );

      onError(e, s);
    } finally {
      emitter(PinAuthenticationState.idle(status: state.status, biometricPreference: state.biometricPreference));
    }
  }

  Future<void> _changeBiometricStatus(_ChangeBiometricStatus event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    try {
      await _pinAuthenticationRepository.changeBiometricPreference(event.preference);
      emitter(PinAuthenticationState.idle(status: state.status, biometricPreference: event.preference));
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );

      onError(e, s);
    }
  }

  Future<void> _signUp(_SignUp event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    try {
      final nextStatus = await _pinAuthenticationRepository.changePinCode(newPinCode: event.pin);
      emitter(PinAuthenticationState.idle(status: nextStatus, biometricPreference: state.biometricPreference));
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );

      onError(e, s);
    }
  }

  Future<void> _resetPin(_ResetPin event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    try {
      await _pinAuthenticationRepository.resetPin();
      emitter(
        PinAuthenticationState.idle(
          status: PinAuthenticationStatus.disabled,
          biometricPreference: state.biometricPreference,
        ),
      );
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );
      onError(e, s);
    }
  }

  Future<void> _verifyAccess(_VerifyAccess event, _Emitter emitter) async {
    emitter(PinAuthenticationState.processing(status: state.status, biometricPreference: state.biometricPreference));
    try {
      final verificationStatus = await _pinAuthenticationRepository.checkAuthenticationStatus(event.pin);
      if (verificationStatus != PinAuthenticationStatus.unauthenticated) {
        emitter(PinAuthenticationState.success(status: state.status, biometricPreference: state.biometricPreference));
      }
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(status: state.status, biometricPreference: state.biometricPreference, error: e),
      );
      onError(e, s);
    } finally {
      emitter(PinAuthenticationState.idle(status: state.status, biometricPreference: state.biometricPreference));
    }
  }
}
