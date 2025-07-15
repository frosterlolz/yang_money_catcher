part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.update(Settings settings) = _Update;

  const factory SettingsEvent.updateHaptic(HapticType type) = _UpdateHaptic;
}
