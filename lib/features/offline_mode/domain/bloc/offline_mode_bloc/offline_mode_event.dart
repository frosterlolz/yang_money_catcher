part of 'offline_mode_bloc.dart';

@freezed
sealed class _OfflineModeEvent with _$OfflineModeEvent {
  factory _OfflineModeEvent.update(OfflineModeReason reason) = _Update;
}
