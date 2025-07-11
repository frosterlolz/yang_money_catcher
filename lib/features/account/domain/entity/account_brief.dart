import 'package:database/database.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/features/account/domain/entity/account_entity.dart';
import 'package:yang_money_catcher/features/account/domain/entity/enum.dart';

part 'account_brief.freezed.dart';

@freezed
class AccountBrief with _$AccountBrief {
  const factory AccountBrief({
    required int id,
    required int? remoteId,
    required String name,
    required String balance,
    required Currency currency,
  }) = _AccountBrief;

  factory AccountBrief.fromEntity(AccountEntity entity) => AccountBrief(
        id: entity.id,
        remoteId: entity.remoteId,
        name: entity.name,
        balance: entity.balance,
        currency: entity.currency,
      );

  factory AccountBrief.fromTableItem(AccountItem item) => AccountBrief(
        id: item.id,
        remoteId: item.remoteId,
        name: item.name,
        balance: item.balance,
        currency: Currency.fromKey(item.currency),
      );
}
