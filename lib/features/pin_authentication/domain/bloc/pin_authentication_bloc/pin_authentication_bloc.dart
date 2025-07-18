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
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    try {
      final nextStatus = event.forceWithBiometric
          ? PinAuthenticationStatus.authenticated
          : await _pinAuthenticationRepository.checkAuthenticationStatus(event.pin);
      emitter(
        PinAuthenticationState.success(
          status: nextStatus,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
        ),
      );
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );

      onError(e, s);
    } finally {
      emitter(
        PinAuthenticationState.idle(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
        ),
      );
    }
  }

  Future<void> _changePin(_ChangePin event, _Emitter emitter) async {
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    if (state.status != PinAuthenticationStatus.authenticated) {
      return emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: const PinException$Forbidden('Cannot change pin from other state except Authenticated'),
        ),
      );
    }
    try {
      final newConfig = await _pinAuthenticationRepository.changePinCode(event.v);
      emitter(
        PinAuthenticationState.success(
          status: PinAuthenticationStatus.authenticated,
          pinLength: newConfig.pinLength,
          shouldAllowBiometric: state.shouldAllowBiometric,
        ),
      );
    } on PinException$Invalid catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );
      logger.warn(e.internalMessage, error: e, stackTrace: s);
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );

      onError(e, s);
    } finally {
      emitter(
        PinAuthenticationState.idle(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
        ),
      );
    }
  }

  Future<void> _changeBiometricStatus(_ChangeBiometricStatus event, _Emitter emitter) async {
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    try {
      await _pinAuthenticationRepository.changeBiometricPreference(event.shouldAllowBiometric);
      emitter(
        PinAuthenticationState.idle(
          status: state.status,
          shouldAllowBiometric: event.shouldAllowBiometric,
          pinLength: state.pinLength,
        ),
      );
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );

      onError(e, s);
    }
  }

  Future<void> _signUp(_SignUp event, _Emitter emitter) async {
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    try {
      final newConfig = await _pinAuthenticationRepository.changePinCode(event.pin);
      emitter(
        PinAuthenticationState.idle(
          status: PinAuthenticationStatus.authenticated,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: newConfig.pinLength,
        ),
      );
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );

      onError(e, s);
    }
  }

  Future<void> _resetPin(_ResetPin event, _Emitter emitter) async {
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    try {
      final newConfig = await _pinAuthenticationRepository.resetPin();
      emitter(
        PinAuthenticationState.idle(
          status: PinAuthenticationStatus.disabled,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: newConfig.pinLength,
        ),
      );
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );
      onError(e, s);
    }
  }

  Future<void> _verifyAccess(_VerifyAccess event, _Emitter emitter) async {
    emitter(
      PinAuthenticationState.processing(
        status: state.status,
        shouldAllowBiometric: state.shouldAllowBiometric,
        pinLength: state.pinLength,
      ),
    );
    try {
      final nextStatus = event.forceWithBiometric
          ? PinAuthenticationStatus.authenticated
          : await _pinAuthenticationRepository.checkAuthenticationStatus(event.pin);
      if (nextStatus != PinAuthenticationStatus.unauthenticated) {
        emitter(
          PinAuthenticationState.success(
            status: state.status,
            shouldAllowBiometric: state.shouldAllowBiometric,
            pinLength: state.pinLength,
          ),
        );
      }
    } on Object catch (e, s) {
      emitter(
        PinAuthenticationState.error(
          status: state.status,
          shouldAllowBiometric: state.shouldAllowBiometric,
          pinLength: state.pinLength,
          error: e,
        ),
      );
      onError(e, s);
    } finally {
      emitter(
        PinAuthenticationState.idle(
          status: state.status,
          pinLength: state.pinLength,
          shouldAllowBiometric: state.shouldAllowBiometric,
        ),
      );
    }
  }
}
