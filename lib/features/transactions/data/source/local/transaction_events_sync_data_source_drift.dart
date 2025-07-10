import 'dart:async';

import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/transactions/domain/entity/transaction_entity.dart';

final class TransactionEventsSyncDataSource$Drift implements TransactionEventsSyncDataSource {
  TransactionEventsSyncDataSource$Drift(this._dao) : _events = [] {
    _accountEventsSubscription = _dao
        .watchEvents()
        .map<Iterable<SyncAction<TransactionEntity>>>(
          (eventVoS) => eventVoS.map<SyncAction<TransactionEntity>>(_fromVO),
        )
        .listen(_onEventsChanged);
  }

  final TransactionEventsDao _dao;
  final List<SyncAction<TransactionEntity>> _events;
  StreamSubscription<Iterable<SyncAction<TransactionEntity>>>? _accountEventsSubscription;

  @override
  FutureOr<List<SyncAction<TransactionEntity>>> fetchEvents() async {
    if (_events.isNotEmpty) return _events;
    final eventItems = await _dao.fetchEvents();
    final events = eventItems.map(_fromVO).toList();
    _events.addAll(events);

    return events;
  }

  @override
  Future<void> addEvent(SyncAction<TransactionEntity> event) async {
    final transactionId = _getSyncActionTransactionId(event);
    final index = _events.indexWhere((syncAction) => _getSyncActionTransactionId(syncAction) == transactionId);

    // Событие не найдено - добавляем
    if (index == -1) {
      final companion = TransactionEventItemsCompanion.insert(
        actionType: event.actionType.name,
        transaction: transactionId,
      );
      await _dao.insertEvent(companion);
      return;
    }
    final existing = _events[index];
    final merged = existing.merge(event);

    if (merged == null) {
      await _dao.deleteEvent(transactionId);
    } else {
      final updatedCompanion = TransactionEventItemsCompanion(
        actionType: Value(merged.actionType.name),
        transaction: Value(transactionId),
        createdAt: Value(merged.createdAt),
      );
      await _dao.updateEvent(updatedCompanion);
    }
  }

  @override
  Future<void> dispose() async {
    await _accountEventsSubscription?.cancel();
  }

  SyncAction<TransactionEntity> _fromVO(TransactionEventValueObject vo) {
    final actionType = SyncActionType.fromName(vo.event.actionType);
    return switch (actionType) {
      SyncActionType.create => SyncAction.create(
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
          data: TransactionEntity.fromTableItem(vo.transaction ?? (throw StateError('Account is null'))),
        ),
      SyncActionType.update => SyncAction.update(
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
          data: TransactionEntity.fromTableItem(vo.transaction ?? (throw StateError('Account is null'))),
        ),
      SyncActionType.delete => SyncAction<TransactionEntity>.delete(
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
          dataId: vo.event.transaction,
        ),
    };
  }

  void _onEventsChanged(Iterable<SyncAction<TransactionEntity>> events) => _events
    ..clear()
    ..addAll(events);

  int _getSyncActionTransactionId(SyncAction<TransactionEntity> event) => switch (event) {
        SyncAction$Create<TransactionEntity>(:final data) => data.id,
        SyncAction$Update<TransactionEntity>(:final data) => data.id,
        SyncAction$Delete<TransactionEntity>(:final dataId) => dataId,
      };
}
