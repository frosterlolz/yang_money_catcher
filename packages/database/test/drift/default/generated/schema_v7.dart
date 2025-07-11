// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class AccountItems extends Table
    with TableInfo<AccountItems, AccountItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AccountItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> balance = GeneratedColumn<String>(
      'balance', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, createdAt, updatedAt, remoteId, name, balance, currency, userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountItemsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountItemsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
    );
  }

  @override
  AccountItems createAlias(String alias) {
    return AccountItems(attachedDatabase, alias);
  }
}

class AccountItemsData extends DataClass
    implements Insertable<AccountItemsData> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? remoteId;
  final String name;
  final String balance;
  final String currency;
  final int userId;
  const AccountItemsData(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.remoteId,
      required this.name,
      required this.balance,
      required this.currency,
      required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['name'] = Variable<String>(name);
    map['balance'] = Variable<String>(balance);
    map['currency'] = Variable<String>(currency);
    map['user_id'] = Variable<int>(userId);
    return map;
  }

  AccountItemsCompanion toCompanion(bool nullToAbsent) {
    return AccountItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      name: Value(name),
      balance: Value(balance),
      currency: Value(currency),
      userId: Value(userId),
    );
  }

  factory AccountItemsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountItemsData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      name: serializer.fromJson<String>(json['name']),
      balance: serializer.fromJson<String>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      userId: serializer.fromJson<int>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<int?>(remoteId),
      'name': serializer.toJson<String>(name),
      'balance': serializer.toJson<String>(balance),
      'currency': serializer.toJson<String>(currency),
      'userId': serializer.toJson<int>(userId),
    };
  }

  AccountItemsData copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> remoteId = const Value.absent(),
          String? name,
          String? balance,
          String? currency,
          int? userId}) =>
      AccountItemsData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        userId: userId ?? this.userId,
      );
  AccountItemsData copyWithCompanion(AccountItemsCompanion data) {
    return AccountItemsData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      name: data.name.present ? data.name.value : this.name,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountItemsData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, updatedAt, remoteId, name, balance, currency, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountItemsData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.name == this.name &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.userId == this.userId);
}

class AccountItemsCompanion extends UpdateCompanion<AccountItemsData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> remoteId;
  final Value<String> name;
  final Value<String> balance;
  final Value<String> currency;
  final Value<int> userId;
  const AccountItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.name = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.userId = const Value.absent(),
  });
  AccountItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    required String name,
    required String balance,
    required String currency,
    required int userId,
  })  : name = Value(name),
        balance = Value(balance),
        currency = Value(currency),
        userId = Value(userId);
  static Insertable<AccountItemsData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? remoteId,
    Expression<String>? name,
    Expression<String>? balance,
    Expression<String>? currency,
    Expression<int>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (name != null) 'name': name,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (userId != null) 'user_id': userId,
    });
  }

  AccountItemsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? remoteId,
      Value<String>? name,
      Value<String>? balance,
      Value<String>? currency,
      Value<int>? userId}) {
    return AccountItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (balance.present) {
      map['balance'] = Variable<String>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('name: $name, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }
}

class AccountEventItems extends Table
    with TableInfo<AccountEventItems, AccountEventItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AccountEventItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account_items (id)'));
  late final GeneratedColumn<int> accountRemoteId = GeneratedColumn<int>(
      'account_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        actionType,
        attempts,
        account,
        accountRemoteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_event_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {account},
      ];
  @override
  AccountEventItemsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountEventItemsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      accountRemoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_remote_id']),
    );
  }

  @override
  AccountEventItems createAlias(String alias) {
    return AccountEventItems(attachedDatabase, alias);
  }
}

class AccountEventItemsData extends DataClass
    implements Insertable<AccountEventItemsData> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String actionType;
  final int attempts;
  final int account;
  final int? accountRemoteId;
  const AccountEventItemsData(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.actionType,
      required this.attempts,
      required this.account,
      this.accountRemoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['action_type'] = Variable<String>(actionType);
    map['attempts'] = Variable<int>(attempts);
    map['account'] = Variable<int>(account);
    if (!nullToAbsent || accountRemoteId != null) {
      map['account_remote_id'] = Variable<int>(accountRemoteId);
    }
    return map;
  }

  AccountEventItemsCompanion toCompanion(bool nullToAbsent) {
    return AccountEventItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      actionType: Value(actionType),
      attempts: Value(attempts),
      account: Value(account),
      accountRemoteId: accountRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountRemoteId),
    );
  }

  factory AccountEventItemsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountEventItemsData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      actionType: serializer.fromJson<String>(json['actionType']),
      attempts: serializer.fromJson<int>(json['attempts']),
      account: serializer.fromJson<int>(json['account']),
      accountRemoteId: serializer.fromJson<int?>(json['accountRemoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'actionType': serializer.toJson<String>(actionType),
      'attempts': serializer.toJson<int>(attempts),
      'account': serializer.toJson<int>(account),
      'accountRemoteId': serializer.toJson<int?>(accountRemoteId),
    };
  }

  AccountEventItemsData copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? actionType,
          int? attempts,
          int? account,
          Value<int?> accountRemoteId = const Value.absent()}) =>
      AccountEventItemsData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        actionType: actionType ?? this.actionType,
        attempts: attempts ?? this.attempts,
        account: account ?? this.account,
        accountRemoteId: accountRemoteId.present
            ? accountRemoteId.value
            : this.accountRemoteId,
      );
  AccountEventItemsData copyWithCompanion(AccountEventItemsCompanion data) {
    return AccountEventItemsData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      account: data.account.present ? data.account.value : this.account,
      accountRemoteId: data.accountRemoteId.present
          ? data.accountRemoteId.value
          : this.accountRemoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountEventItemsData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('actionType: $actionType, ')
          ..write('attempts: $attempts, ')
          ..write('account: $account, ')
          ..write('accountRemoteId: $accountRemoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, createdAt, updatedAt, actionType, attempts, account, accountRemoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountEventItemsData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.actionType == this.actionType &&
          other.attempts == this.attempts &&
          other.account == this.account &&
          other.accountRemoteId == this.accountRemoteId);
}

class AccountEventItemsCompanion
    extends UpdateCompanion<AccountEventItemsData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> actionType;
  final Value<int> attempts;
  final Value<int> account;
  final Value<int?> accountRemoteId;
  const AccountEventItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.actionType = const Value.absent(),
    this.attempts = const Value.absent(),
    this.account = const Value.absent(),
    this.accountRemoteId = const Value.absent(),
  });
  AccountEventItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String actionType,
    this.attempts = const Value.absent(),
    required int account,
    this.accountRemoteId = const Value.absent(),
  })  : actionType = Value(actionType),
        account = Value(account);
  static Insertable<AccountEventItemsData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? actionType,
    Expression<int>? attempts,
    Expression<int>? account,
    Expression<int>? accountRemoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (actionType != null) 'action_type': actionType,
      if (attempts != null) 'attempts': attempts,
      if (account != null) 'account': account,
      if (accountRemoteId != null) 'account_remote_id': accountRemoteId,
    });
  }

  AccountEventItemsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? actionType,
      Value<int>? attempts,
      Value<int>? account,
      Value<int?>? accountRemoteId}) {
    return AccountEventItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      actionType: actionType ?? this.actionType,
      attempts: attempts ?? this.attempts,
      account: account ?? this.account,
      accountRemoteId: accountRemoteId ?? this.accountRemoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (accountRemoteId.present) {
      map['account_remote_id'] = Variable<int>(accountRemoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountEventItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('actionType: $actionType, ')
          ..write('attempts: $attempts, ')
          ..write('account: $account, ')
          ..write('accountRemoteId: $accountRemoteId')
          ..write(')'))
        .toString();
  }
}

class TransactionCategoryItems extends Table
    with TableInfo<TransactionCategoryItems, TransactionCategoryItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TransactionCategoryItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
      'is_income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_income" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji, isIncome];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_category_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionCategoryItemsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionCategoryItemsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      isIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_income'])!,
    );
  }

  @override
  TransactionCategoryItems createAlias(String alias) {
    return TransactionCategoryItems(attachedDatabase, alias);
  }
}

class TransactionCategoryItemsData extends DataClass
    implements Insertable<TransactionCategoryItemsData> {
  final int id;
  final String name;
  final String emoji;
  final bool isIncome;
  const TransactionCategoryItemsData(
      {required this.id,
      required this.name,
      required this.emoji,
      required this.isIncome});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['is_income'] = Variable<bool>(isIncome);
    return map;
  }

  TransactionCategoryItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionCategoryItemsCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      isIncome: Value(isIncome),
    );
  }

  factory TransactionCategoryItemsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCategoryItemsData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'isIncome': serializer.toJson<bool>(isIncome),
    };
  }

  TransactionCategoryItemsData copyWith(
          {int? id, String? name, String? emoji, bool? isIncome}) =>
      TransactionCategoryItemsData(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        isIncome: isIncome ?? this.isIncome,
      );
  TransactionCategoryItemsData copyWithCompanion(
      TransactionCategoryItemsCompanion data) {
    return TransactionCategoryItemsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCategoryItemsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('isIncome: $isIncome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji, isIncome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCategoryItemsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.isIncome == this.isIncome);
}

class TransactionCategoryItemsCompanion
    extends UpdateCompanion<TransactionCategoryItemsData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<bool> isIncome;
  const TransactionCategoryItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isIncome = const Value.absent(),
  });
  TransactionCategoryItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String emoji,
    required bool isIncome,
  })  : name = Value(name),
        emoji = Value(emoji),
        isIncome = Value(isIncome);
  static Insertable<TransactionCategoryItemsData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<bool>? isIncome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (isIncome != null) 'is_income': isIncome,
    });
  }

  TransactionCategoryItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? emoji,
      Value<bool>? isIncome}) {
    return TransactionCategoryItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCategoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('isIncome: $isIncome')
          ..write(')'))
        .toString();
  }
}

class TransactionItems extends Table
    with TableInfo<TransactionItems, TransactionItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TransactionItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<int> account = GeneratedColumn<int>(
      'account', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES account_items (id)'));
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transaction_category_items (id)'));
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        remoteId,
        account,
        category,
        amount,
        transactionDate,
        comment
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItemsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItemsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remote_id']),
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
    );
  }

  @override
  TransactionItems createAlias(String alias) {
    return TransactionItems(attachedDatabase, alias);
  }
}

class TransactionItemsData extends DataClass
    implements Insertable<TransactionItemsData> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? remoteId;
  final int account;
  final int category;
  final String amount;
  final DateTime transactionDate;
  final String? comment;
  const TransactionItemsData(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.remoteId,
      required this.account,
      required this.category,
      required this.amount,
      required this.transactionDate,
      this.comment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<int>(remoteId);
    }
    map['account'] = Variable<int>(account);
    map['category'] = Variable<int>(category);
    map['amount'] = Variable<String>(amount);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      account: Value(account),
      category: Value(category),
      amount: Value(amount),
      transactionDate: Value(transactionDate),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory TransactionItemsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItemsData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remoteId: serializer.fromJson<int?>(json['remoteId']),
      account: serializer.fromJson<int>(json['account']),
      category: serializer.fromJson<int>(json['category']),
      amount: serializer.fromJson<String>(json['amount']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remoteId': serializer.toJson<int?>(remoteId),
      'account': serializer.toJson<int>(account),
      'category': serializer.toJson<int>(category),
      'amount': serializer.toJson<String>(amount),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  TransactionItemsData copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<int?> remoteId = const Value.absent(),
          int? account,
          int? category,
          String? amount,
          DateTime? transactionDate,
          Value<String?> comment = const Value.absent()}) =>
      TransactionItemsData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        account: account ?? this.account,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        transactionDate: transactionDate ?? this.transactionDate,
        comment: comment.present ? comment.value : this.comment,
      );
  TransactionItemsData copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItemsData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      account: data.account.present ? data.account.value : this.account,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('account: $account, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, remoteId, account,
      category, amount, transactionDate, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItemsData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.account == this.account &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.transactionDate == this.transactionDate &&
          other.comment == this.comment);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItemsData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> remoteId;
  final Value<int> account;
  final Value<int> category;
  final Value<String> amount;
  final Value<DateTime> transactionDate;
  final Value<String?> comment;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.account = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.comment = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    required int account,
    required int category,
    required String amount,
    required DateTime transactionDate,
    this.comment = const Value.absent(),
  })  : account = Value(account),
        category = Value(category),
        amount = Value(amount),
        transactionDate = Value(transactionDate);
  static Insertable<TransactionItemsData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? remoteId,
    Expression<int>? account,
    Expression<int>? category,
    Expression<String>? amount,
    Expression<DateTime>? transactionDate,
    Expression<String>? comment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (account != null) 'account': account,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (comment != null) 'comment': comment,
    });
  }

  TransactionItemsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int?>? remoteId,
      Value<int>? account,
      Value<int>? category,
      Value<String>? amount,
      Value<DateTime>? transactionDate,
      Value<String?>? comment}) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      account: account ?? this.account,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      comment: comment ?? this.comment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (account.present) {
      map['account'] = Variable<int>(account.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('account: $account, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }
}

class TransactionEventItems extends Table
    with TableInfo<TransactionEventItems, TransactionEventItemsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TransactionEventItems(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> transaction = GeneratedColumn<int>(
      'transaction', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transaction_items (id)'));
  late final GeneratedColumn<int> transactionRemoteId = GeneratedColumn<int>(
      'transaction_remote_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        actionType,
        attempts,
        transaction,
        transactionRemoteId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_event_items';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {transaction},
      ];
  @override
  TransactionEventItemsData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEventItemsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      transaction: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction'])!,
      transactionRemoteId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}transaction_remote_id']),
    );
  }

  @override
  TransactionEventItems createAlias(String alias) {
    return TransactionEventItems(attachedDatabase, alias);
  }
}

class TransactionEventItemsData extends DataClass
    implements Insertable<TransactionEventItemsData> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String actionType;
  final int attempts;
  final int transaction;
  final int? transactionRemoteId;
  const TransactionEventItemsData(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.actionType,
      required this.attempts,
      required this.transaction,
      this.transactionRemoteId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['action_type'] = Variable<String>(actionType);
    map['attempts'] = Variable<int>(attempts);
    map['transaction'] = Variable<int>(transaction);
    if (!nullToAbsent || transactionRemoteId != null) {
      map['transaction_remote_id'] = Variable<int>(transactionRemoteId);
    }
    return map;
  }

  TransactionEventItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionEventItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      actionType: Value(actionType),
      attempts: Value(attempts),
      transaction: Value(transaction),
      transactionRemoteId: transactionRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionRemoteId),
    );
  }

  factory TransactionEventItemsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEventItemsData(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      actionType: serializer.fromJson<String>(json['actionType']),
      attempts: serializer.fromJson<int>(json['attempts']),
      transaction: serializer.fromJson<int>(json['transaction']),
      transactionRemoteId:
          serializer.fromJson<int?>(json['transactionRemoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'actionType': serializer.toJson<String>(actionType),
      'attempts': serializer.toJson<int>(attempts),
      'transaction': serializer.toJson<int>(transaction),
      'transactionRemoteId': serializer.toJson<int?>(transactionRemoteId),
    };
  }

  TransactionEventItemsData copyWith(
          {int? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? actionType,
          int? attempts,
          int? transaction,
          Value<int?> transactionRemoteId = const Value.absent()}) =>
      TransactionEventItemsData(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        actionType: actionType ?? this.actionType,
        attempts: attempts ?? this.attempts,
        transaction: transaction ?? this.transaction,
        transactionRemoteId: transactionRemoteId.present
            ? transactionRemoteId.value
            : this.transactionRemoteId,
      );
  TransactionEventItemsData copyWithCompanion(
      TransactionEventItemsCompanion data) {
    return TransactionEventItemsData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      transaction:
          data.transaction.present ? data.transaction.value : this.transaction,
      transactionRemoteId: data.transactionRemoteId.present
          ? data.transactionRemoteId.value
          : this.transactionRemoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEventItemsData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('actionType: $actionType, ')
          ..write('attempts: $attempts, ')
          ..write('transaction: $transaction, ')
          ..write('transactionRemoteId: $transactionRemoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, actionType,
      attempts, transaction, transactionRemoteId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEventItemsData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.actionType == this.actionType &&
          other.attempts == this.attempts &&
          other.transaction == this.transaction &&
          other.transactionRemoteId == this.transactionRemoteId);
}

class TransactionEventItemsCompanion
    extends UpdateCompanion<TransactionEventItemsData> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> actionType;
  final Value<int> attempts;
  final Value<int> transaction;
  final Value<int?> transactionRemoteId;
  const TransactionEventItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.actionType = const Value.absent(),
    this.attempts = const Value.absent(),
    this.transaction = const Value.absent(),
    this.transactionRemoteId = const Value.absent(),
  });
  TransactionEventItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String actionType,
    this.attempts = const Value.absent(),
    required int transaction,
    this.transactionRemoteId = const Value.absent(),
  })  : actionType = Value(actionType),
        transaction = Value(transaction);
  static Insertable<TransactionEventItemsData> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? actionType,
    Expression<int>? attempts,
    Expression<int>? transaction,
    Expression<int>? transactionRemoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (actionType != null) 'action_type': actionType,
      if (attempts != null) 'attempts': attempts,
      if (transaction != null) 'transaction': transaction,
      if (transactionRemoteId != null)
        'transaction_remote_id': transactionRemoteId,
    });
  }

  TransactionEventItemsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? actionType,
      Value<int>? attempts,
      Value<int>? transaction,
      Value<int?>? transactionRemoteId}) {
    return TransactionEventItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      actionType: actionType ?? this.actionType,
      attempts: attempts ?? this.attempts,
      transaction: transaction ?? this.transaction,
      transactionRemoteId: transactionRemoteId ?? this.transactionRemoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (transaction.present) {
      map['transaction'] = Variable<int>(transaction.value);
    }
    if (transactionRemoteId.present) {
      map['transaction_remote_id'] = Variable<int>(transactionRemoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEventItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('actionType: $actionType, ')
          ..write('attempts: $attempts, ')
          ..write('transaction: $transaction, ')
          ..write('transactionRemoteId: $transactionRemoteId')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV7 extends GeneratedDatabase {
  DatabaseAtV7(QueryExecutor e) : super(e);
  late final AccountItems accountItems = AccountItems(this);
  late final AccountEventItems accountEventItems = AccountEventItems(this);
  late final TransactionCategoryItems transactionCategoryItems =
      TransactionCategoryItems(this);
  late final TransactionItems transactionItems = TransactionItems(this);
  late final TransactionEventItems transactionEventItems =
      TransactionEventItems(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accountItems,
        accountEventItems,
        transactionCategoryItems,
        transactionItems,
        transactionEventItems
      ];
  @override
  int get schemaVersion => 7;
}
