import 'package:database/src/features/accounts/accounts.dart';
import 'package:database/src/features/transactions/transactions.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// {@template database}
/// The drift-managed database configuration
/// {@endtemplate}
@DriftDatabase(tables: [AccountItems, AccountEventItems, TransactionItems, TransactionCategoryItems])
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
  int get schemaVersion => 1;
}
