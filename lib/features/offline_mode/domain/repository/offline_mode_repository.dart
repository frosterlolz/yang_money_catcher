import 'package:yang_money_catcher/core/data/rest_client/interceptors/offline_mode_check_interceptor.dart';

abstract interface class OfflineModeRepository {
  OfflineModeReason get reason;

  void setReason(OfflineModeReason reason);
  Stream<OfflineModeReason> watchReason();
}
