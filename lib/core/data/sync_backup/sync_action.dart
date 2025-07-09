import 'package:yang_money_catcher/core/data/sync_backup/sync_action_type.dart';

class SyncAction<T> {
  const SyncAction({
    required this.id,
    required this.actionType,
    required this.timestamp,
    required this.data,
  });

  final int id;
  final SyncActionType actionType;
  final DateTime timestamp;
  final T data;

  SyncAction<T>? merge(SyncAction<T> other) {
    assert(id == other.id, 'Cannot merge actions with different ids');

    return switch (actionType) {
      SyncActionType.create => switch (other.actionType) {
          SyncActionType.update => other.copyWith(actionType: SyncActionType.create),
          SyncActionType.delete => null,
          SyncActionType.create => this,
        },
      SyncActionType.update => switch (other.actionType) {
          SyncActionType.update => other,
          SyncActionType.delete => other,
          SyncActionType.create => this,
        },
      SyncActionType.delete => switch (other.actionType) {
          SyncActionType.create => other.copyWith(actionType: SyncActionType.update),
          SyncActionType.update => this,
          SyncActionType.delete => this,
        },
    };
  }

  SyncAction<T> copyWith({
    int? id,
    SyncActionType? actionType,
    DateTime? timestamp,
    T? data,
  }) =>
      SyncAction<T>(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        timestamp: timestamp ?? this.timestamp,
        data: data ?? this.data,
      );
}
