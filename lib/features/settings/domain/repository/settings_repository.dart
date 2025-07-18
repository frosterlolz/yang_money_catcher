import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';

/// Репозиторий для работы с настройками
abstract interface class SettingsRepository {
  Stream<Settings?> watch();
  Future<void> save(Settings settings);
  Future<Settings> read();
}
