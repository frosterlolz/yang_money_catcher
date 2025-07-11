import 'dart:async';

import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:yang_money_catcher/core/data/sync_backup/sync_action.dart';
import 'package:yang_money_catcher/features/account/data/source/local/account_events_sync_data_source.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';

final class AccountEventsSyncDataSource$Drift implements AccountEventsSyncDataSource {
  AccountEventsSyncDataSource$Drift(this._dao) : _events = [] {
    _accountEventsSubscription = _dao
        .watchEvents()
        .map<Iterable<SyncAction<AccountEntity>>>((eventVoS) => eventVoS.map<SyncAction<AccountEntity>>(_fromVO))
        .listen(_onEventsChanged);
  }

  final AccountEventsDao _dao;
  final List<SyncAction<AccountEntity>> _events;
  StreamSubscription<Iterable<SyncAction<AccountEntity>>>? _accountEventsSubscription;

  @override
  FutureOr<List<SyncAction<AccountEntity>>> fetchEvents(
    SyncAction<AccountEntity>? mergeWithNext, {
    bool forceUpdate = false,
  }) async {
    if (mergeWithNext != null) {
      await addAction(mergeWithNext);
    }
    if (_events.isNotEmpty && !forceUpdate) return _events;
    final eventItems = await _dao.fetchEvents();
    final events = eventItems.map(_fromVO).toList();
    _events.addAll(events);

    return events;
  }

  @override
  Future<void> addAction(SyncAction<AccountEntity> event) async {
    final accountId = _getSyncActionAccountId$Local(event);
    final index = _events.indexWhere((syncAction) => _getSyncActionAccountId$Local(syncAction) == accountId);

    // Событие не найдено - добавляем
    if (index == -1) {
      final companion = AccountEventItemsCompanion.insert(
        actionType: event.actionType.name,
        account: accountId,
      );
      await _dao.insertEvent(companion);
      return;
    }
    final existing = _events[index];
    final merged = existing.merge(event);

    if (merged == null) {
      await _dao.deleteEvent(accountId);
    } else {
      final updatedCompanion = AccountEventItemsCompanion(
        actionType: Value(merged.actionType.name),
        account: Value(accountId),
        attempts: Value(merged.attempts),
      );
      await _dao.updateEvent(updatedCompanion);
    }
    await fetchEvents(null, forceUpdate: true);
  }

  @override
  Future<void> dispose() async {
    await _accountEventsSubscription?.cancel();
    _events.clear();
  }

  SyncAction<AccountEntity> _fromVO(AccountEventsValueObject vo) {
    final actionType = SyncActionType.fromName(vo.event.actionType);
    return switch (actionType) {
      SyncActionType.create => SyncAction.create(
          data: AccountEntity.fromTableItem(vo.account ?? (throw StateError('Account is null'))),
          dataRemoteId: vo.event.accountRemoteId ?? vo.account?.remoteId,
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
        ),
      SyncActionType.update => SyncAction.update(
          data: AccountEntity.fromTableItem(vo.account ?? (throw StateError('Account is null'))),
          dataRemoteId: vo.event.accountRemoteId ?? vo.account?.remoteId,
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
        ),
      SyncActionType.delete => SyncAction<AccountEntity>.delete(
          dataId: vo.event.account,
          dataRemoteId: vo.event.accountRemoteId,
          createdAt: vo.event.createdAt,
          updatedAt: vo.event.updatedAt,
        ),
    };
  }

  void _onEventsChanged(Iterable<SyncAction<AccountEntity>> events) => _events
    ..clear()
    ..addAll(events);

  int _getSyncActionAccountId$Local(SyncAction<AccountEntity> event) => switch (event) {
        SyncAction$Create<AccountEntity>(:final data) => data.id,
        SyncAction$Update<AccountEntity>(:final data) => data.id,
        SyncAction$Delete<AccountEntity>(:final dataId) => dataId,
      };
}
