import 'dart:async';

import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

abstract interface class TransactionEventsSyncDataSource {
  Future<void> addEvent(SyncAction<TransactionEntity> event);
  FutureOr<List<SyncAction<AccountEntity>>> fetchEvents();
  Future<void> dispose();
}
