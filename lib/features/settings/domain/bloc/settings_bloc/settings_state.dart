part of 'settings_bloc.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState.idle(Settings settings) = SettingsState$Idle;
  const factory SettingsState.processing(Settings settings) = SettingsState$Processing;
  const factory SettingsState.error(Settings settings, {required Object error}) = SettingsState$Error;
}
