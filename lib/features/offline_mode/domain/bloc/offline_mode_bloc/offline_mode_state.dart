part of 'offline_mode_bloc.dart';

@freezed
class OfflineModeState with _$OfflineModeState {
  const factory OfflineModeState(OfflineModeReason reason) = _OfflineModeState;
}
