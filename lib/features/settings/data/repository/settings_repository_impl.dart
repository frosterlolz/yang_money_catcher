import 'package:yang_money_catcher/features/settings/data/source/local/settings_data_source_local.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';
import 'package:yang_money_catcher/features/settings/domain/repository/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._settingsStorage);

  final SettingsDataSource$Local _settingsStorage;

  @override
  Future<Settings> read() => _settingsStorage.readSettings();

  @override
  Future<void> save(Settings settings) => _settingsStorage.saveSettings(settings);

  @override
  Stream<Settings?> watch() => _settingsStorage.watchSettings();
}
