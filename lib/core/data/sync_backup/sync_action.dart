import 'dart:developer' as dev;
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/config/env_constants.dart';

part 'sync_action.freezed.dart';

@freezed
sealed class SyncAction<T> with _$SyncAction<T> {
  const factory SyncAction.create({
    required T data,
    required int? dataRemoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int attempts,
  }) = SyncAction$Create<T>;

  const factory SyncAction.update({
    required T data,
    required int? dataRemoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int attempts,
  }) = SyncAction$Update<T>;

  const factory SyncAction.delete({
    required int dataId,
    required int? dataRemoteId,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int attempts,
  }) = SyncAction$Delete<T>;

  const SyncAction._();

  @useResult
  SyncAction<T>? merge(SyncAction<T> other) {
    final otherAttempts = max(1, other.attempts);
    final nextAttempts = attempts + otherAttempts;
    if (nextAttempts > EnvConstants.maxSyncActionAttempts) {
      dev.log('SyncAction for ${T.runtimeType} dropped due to max attempts');
      return null;
    }
    final dataRemoteId = this.dataRemoteId ?? other.dataRemoteId;

    return switch (this) {
      SyncAction$Create() => switch (other) {
          SyncAction$Create() => copyWith(attempts: nextAttempts),
          SyncAction$Update() => SyncAction.create(
              updatedAt: other.updatedAt,
              data: other.data,
              dataRemoteId: dataRemoteId,
              attempts: nextAttempts,
            ),
          SyncAction$Delete() => null,
        },
      SyncAction$Update() => switch (other) {
          SyncAction$Create() => copyWith(attempts: nextAttempts),
          SyncAction$Update() => copyWith(attempts: nextAttempts),
          SyncAction$Delete() => other.copyWith(attempts: nextAttempts),
        },
      SyncAction$Delete() => switch (other) {
          SyncAction$Create() => SyncAction.update(
              updatedAt: other.updatedAt,
              data: other.data,
              dataRemoteId: dataRemoteId,
              attempts: nextAttempts,
            ),
          SyncAction$Update() => copyWith(attempts: nextAttempts),
          SyncAction$Delete() => copyWith(attempts: nextAttempts),
        },
    };
  }

  SyncActionType get actionType => switch (this) {
        SyncAction$Create() => SyncActionType.create,
        SyncAction$Update() => SyncActionType.update,
        SyncAction$Delete() => SyncActionType.delete,
      };
}

enum SyncActionType {
  create,
  update,
  delete;

  factory SyncActionType.fromName(String name) => values.firstWhere((e) => e.name == name);
}
