import 'package:yang_money_catcher/features/pin_authentication/data/source/local/pin_config_storage.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/repository/pin_authentication_repository.dart';

final class PinAuthenticationRepositoryImpl implements PinAuthenticationRepository {
  const PinAuthenticationRepositoryImpl(this._pinConfigStorage);

  final PinConfigStorage _pinConfigStorage;

  // @override
  // Future<void> savePinConfig(PinConfig config) => _pinConfigStorage.savePinConfig(config);
}
