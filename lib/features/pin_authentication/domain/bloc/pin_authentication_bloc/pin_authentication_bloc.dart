import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/repository/pin_authentication_repository.dart';

part 'pin_authentication_event.dart';
part 'pin_authentication_state.dart';
part 'pin_authentication_bloc.freezed.dart';

typedef _Emitter = Emitter<PinAuthenticationState>;

class PinAuthenticationBloc extends Bloc<PinAuthenticationEvent, PinAuthenticationState> {
  PinAuthenticationBloc(super.initialState, {required PinAuthenticationRepository pinAuthenticationRepository})
      : _pinAuthenticationRepository = pinAuthenticationRepository {
    on<PinAuthenticationEvent>((event, emitter) {
      // TODO: implement event handler
    });
  }

  final PinAuthenticationRepository _pinAuthenticationRepository;
}
