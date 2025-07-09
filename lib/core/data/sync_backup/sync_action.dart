import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_action.freezed.dart';

@freezed
sealed class SyncAction<T> with _$SyncAction<T> {
  const factory SyncAction.create({
    required DateTime createdAt,
    required DateTime updatedAt,
    required T data,
  }) = SyncAction$Create<T>;

  const factory SyncAction.update({
    required DateTime createdAt,
    required DateTime updatedAt,
    required T data,
  }) = SyncAction$Update<T>;

  const factory SyncAction.delete({
    required DateTime createdAt,
    required DateTime updatedAt,
    required int dataId,
  }) = SyncAction$Delete<T>;

  const SyncAction._();

  @useResult
  SyncAction<T>? merge(SyncAction<T> other) {
    final createAt = createdAt.isAfter(other.createdAt) ? other.createdAt : createdAt;
    return switch (this) {
      SyncAction$Create() => switch (other) {
          SyncAction$Create() => copyWith(createdAt: createAt),
          SyncAction$Update() => SyncAction.create(createdAt: createAt, updatedAt: other.updatedAt, data: other.data),
          SyncAction$Delete() => null,
        },
      SyncAction$Update() => switch (other) {
          SyncAction$Create() => copyWith(createdAt: createAt),
          SyncAction$Update() => copyWith(createdAt: createAt),
          SyncAction$Delete() => other.copyWith(createdAt: createAt),
        },
      SyncAction$Delete() => switch (other) {
          SyncAction$Create() => SyncAction.update(createdAt: createAt, updatedAt: other.updatedAt, data: other.data),
          SyncAction$Update() => copyWith(createdAt: createAt),
          SyncAction$Delete() => copyWith(createdAt: createAt),
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
