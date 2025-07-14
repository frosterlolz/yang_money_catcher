import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';
import 'package:yang_money_catcher/features/settings/data/codecs/settings_codec.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';

const _settingsStorageKey = 'settings';

final class SettingsDataSource$Local {
  SettingsDataSource$Local(this._sharedPrefs, {required SettingsCodec settingsCodec})
      : _settingsCodec = settingsCodec,
        _settingsStreamController = StreamController.broadcast();

  final SharedPreferencesAsync _sharedPrefs;
  final SettingsCodec _settingsCodec;
  final StreamController<Settings?> _settingsStreamController;

  Future<void> saveSettings(Settings settings) async {
    final settingsMap = _settingsCodec.encode(settings);
    await _sharedPrefs.setString(_settingsStorageKey, jsonEncode(settingsMap));
    _settingsStreamController.add(settings);
  }

  Future<Settings> readSettings() async {
    final settingsMap = await _sharedPrefs.getString(_settingsStorageKey);

    return _settingsCodec.decode(settingsMap == null ? {} : jsonDecode(settingsMap) as JsonMap);
  }

  Stream<Settings?> watchSettings() => _settingsStreamController.stream;
}
