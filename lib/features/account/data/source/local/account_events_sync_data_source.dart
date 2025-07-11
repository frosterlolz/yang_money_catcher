import 'dart:async';

import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

abstract interface class AccountEventsSyncDataSource {
  Future<void> addAction(SyncAction<AccountEntity> event);
  FutureOr<List<SyncAction<AccountEntity>>> fetchEvents(SyncAction<AccountEntity>? mergeWithNext);
  Future<void> dispose();
}
