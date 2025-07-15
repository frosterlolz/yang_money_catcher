import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';
import 'package:yang_money_catcher/features/settings/domain/repository/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

typedef _Emitter = Emitter<SettingsState>;

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(super.initialState, {required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository {
    on<SettingsEvent>(
      (event, emitter) => switch (event) {
        _Update() => _update(event, emitter),
        _UpdateHaptic() => _updateHaptic(event, emitter),
      },
    );
  }

  final SettingsRepository _settingsRepository;

  Future<void> _update(_Update event, _Emitter emitter) async {
    emitter(SettingsState.processing(state.settings));
    try {
      await _settingsRepository.save(event.settings);
      emitter(SettingsState.idle(event.settings));
    } on Object catch (e, s) {
      emitter(SettingsState.error(state.settings, error: e));
      onError(e, s);
    }
  }

  Future<void> _updateHaptic(_UpdateHaptic event, _Emitter emitter) async {
    final currentHaptic = state.settings.hapticType;
    if (currentHaptic == event.type) return;
    emitter(SettingsState.processing(state.settings));
    try {
      final nextSettings = state.settings.copyWith(hapticType: event.type);
      await _settingsRepository.save(nextSettings);
      emitter(SettingsState.idle(nextSettings));
    } on Object catch (e, s) {
      emitter(SettingsState.error(state.settings, error: e));
      onError(e, s);
    }
  }
}
