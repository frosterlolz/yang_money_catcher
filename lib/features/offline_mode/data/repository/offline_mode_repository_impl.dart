import 'dart:async';

import 'package:yang_money_catcher/core/data/rest_client/interceptors/offline_mode_check_interceptor.dart';
import 'package:yang_money_catcher/features/offline_mode/domain/repository/offline_mode_repository.dart';

final class OfflineModeRepositoryImpl implements OfflineModeRepository {
  OfflineModeRepositoryImpl([this._currentReason = OfflineModeReason.none])
      : _reasonsController = StreamController.broadcast();

  OfflineModeReason _currentReason;
  final StreamController<OfflineModeReason> _reasonsController;

  @override
  OfflineModeReason get reason => _currentReason;

  @override
  void setReason(OfflineModeReason reason) {
    if (_currentReason == reason) return;
    _currentReason = reason;
    _reasonsController.add(_currentReason);
  }

  @override
  Stream<OfflineModeReason> watchReason() => _reasonsController.stream;
}
