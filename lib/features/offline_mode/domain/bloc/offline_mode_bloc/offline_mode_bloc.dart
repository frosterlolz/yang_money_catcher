import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yang_money_catcher/core/data/rest_client/interceptors/offline_mode_check_interceptor.dart';
import 'package:yang_money_catcher/features/offline_mode/domain/repository/offline_mode_repository.dart';

part 'offline_mode_event.dart';
part 'offline_mode_state.dart';
part 'offline_mode_bloc.freezed.dart';

typedef _Emitter = Emitter<OfflineModeState>;

class OfflineModeBloc extends Bloc<_OfflineModeEvent, OfflineModeState> {
  OfflineModeBloc(OfflineModeRepository offlineModeRepository) : super(const OfflineModeState(OfflineModeReason.none)) {
    on<_OfflineModeEvent>(
      (event, emitter) => switch (event) {
        _Update() => _update(event, emitter),
      },
    );
    _offlineReasonSubscription = offlineModeRepository
        .watchReason()
        .distinct()
        .debounceTime(const Duration(milliseconds: 300))
        .listen((nextReason) => add(_Update(nextReason)));
  }

  StreamSubscription<OfflineModeReason>? _offlineReasonSubscription;

  @override
  Future<void> close() {
    _offlineReasonSubscription?.cancel();
    return super.close();
  }

  void _update(_Update event, _Emitter emitter) {
    if (event.reason == state.reason) return;
    emitter(state.copyWith(reason: event.reason));
  }
}
