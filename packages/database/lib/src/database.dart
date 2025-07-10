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
            await m.addColumn(accountItems, accountItems.remoteId);
            await m.addColumn(accountEventItems, accountEventItems.accountRemoteId);
          },
        ),
      );

  @override
  int get schemaVersion => 3;
}
