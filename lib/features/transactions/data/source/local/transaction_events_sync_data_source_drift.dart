import 'dart:async';

import 'package:database/database.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

final class TransactionEventsSyncDataSource$Drift implements TransactionEventsSyncDataSource {
  const TransactionEventsSyncDataSource$Drift(this._dao);

  final TransactionEventsDao _dao;

  @override
  Future<void> addEvent(SyncAction<TransactionEntity> event) {
    // TODO: implement addEvent
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  FutureOr<List<SyncAction<AccountEntity>>> fetchEvents() {
    // TODO: implement fetchEvents
    throw UnimplementedError();
  }
}
