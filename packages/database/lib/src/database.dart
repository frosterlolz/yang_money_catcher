import 'package:database/src/database.steps.dart';
import 'package:database/src/features/accounts/accounts.dart';
import 'package:database/src/features/transactions/transactions.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// {@template database}
/// The drift-managed database configuration
/// {@endtemplate}
@DriftDatabase(
  tables: [
    AccountItems,
    AccountEventItems,
    TransactionItems,
    TransactionEventItems,
    TransactionCategoryItems,
  ],
  daos: [
    AccountsDao,
    AccountEventsDao,
    TransactionsDao,
    TransactionEventsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// {@macro database}
  AppDatabase(super.e);

  /// {@macro database}
  AppDatabase.defaults({required String name})
      : super(
          driftDatabase(
            name: name,
            native: const DriftNativeOptions(shareAcrossIsolates: true),
          ),
        );

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            await m.createTable(accountEventItems);
          },
          from2To3: (m, schema) async {
            await m.addColumn(schema.accountItems, schema.accountItems.remoteId);
            await m.addColumn(schema.accountEventItems, schema.accountEventItems.accountRemoteId);
          },
          from3To4: (Migrator m, Schema4 schema) async {
            await m.addColumn(schema.transactionItems, schema.transactionItems.remoteId);
            await m.createTable(schema.transactionEventItems);
          },
          from4To5: (Migrator m, Schema5 schema) async {
            // Очистка таблиц через SQL (удаляем все записи, сохраняя структуру)
            await customStatement('DELETE FROM ${schema.accountItems.actualTableName};');
            await customStatement('DELETE FROM ${schema.transactionItems.actualTableName};');

            // Создаём уникальный индекс на remoteId
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_account_remote_id ON ${schema.accountItems.actualTableName}(${schema.accountItems.remoteId.name});',
            );
          },
          from5To6: (Migrator m, Schema6 schema) async {
            await m.deleteTable(schema.accountItems.actualTableName);
            await m.deleteTable(schema.transactionItems.actualTableName);
            await m.createTable(schema.accountItems);
            await m.createTable(schema.transactionItems);
          },
          from6To7: (Migrator m, Schema7 schema) async {
            await m.addColumn(accountEventItems, accountEventItems.attempts);
            await m.addColumn(transactionEventItems, transactionEventItems.attempts);
          },
        ),
      );

  @override
  int get schemaVersion => 7;
}
