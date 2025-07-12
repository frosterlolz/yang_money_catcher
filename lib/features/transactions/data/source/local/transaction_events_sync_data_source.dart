import 'dart:async';

import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

abstract interface class TransactionEventsSyncDataSource {
  Future<void> addAction(SyncAction<TransactionEntity> event);
  Future<void> removeAction(SyncAction<TransactionEntity> action);
  FutureOr<List<SyncAction<TransactionEntity>>> fetchActions(SyncAction<TransactionEntity>? mergeWithNext);
  Future<void> dispose();
}
