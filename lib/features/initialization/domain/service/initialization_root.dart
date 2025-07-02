import 'dart:async';

import 'package:database/database.dart';
import 'package:drift/drift.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:yang_money_catcher/features/account/data/repository/account_repository_impl.dart';
import 'package:yang_money_catcher/features/account/data/source/local/acounts_drift_storage.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';
import 'package:yang_money_catcher/features/transaction_categories/data/source/mock_transaction_categories.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/mock_transactions_repository.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_drift_storage.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';

typedef InitializationStep = FutureOr<void> Function(Mutable$Dependencies dependencies);

/// {@template composition_root}
/// A place where all dependencies are initialized.
/// {@endtemplate}
///
/// {@template composition_process}
/// Composition of dependencies is a process of creating and configuring
/// instances of classes that are required for the application to work.
///
/// It is a good practice to keep all dependencies in one place to make it
/// easier to manage them and to ensure that they are initialized only once.
/// {@endtemplate}
final class InitializationRoot {
  /// {@macro composition_root}
  const InitializationRoot(this.logger);

  final PrettyLogger logger;

  /// Preparing initialization steps [InitializationStep]
  Map<String, InitializationStep> _prepareInitializationSteps() => {
        'Init logger': (d) async => d.logger = logger,
        'Prepare database': (d) async {
          final database = AppDatabase.defaults(name: 'yang_money_catcher_database');
          d.context['drift_database'] = database;
        },
        'Prepare accounts feature': (d) async {
          final database = d.context['drift_database']! as AppDatabase;
          final accountsLocalDataSource = AccountsDriftStorage(database);
          final transactionsDao = TransactionsDao(database);
          final transactionsLocalDataSource = TransactionsDriftStorage(transactionsDao);
          d.context['transactions_local_data_source'] = transactionsLocalDataSource;
          final accountsRepository = AccountRepositoryImpl(
            accountsLocalStorage: accountsLocalDataSource,
            transactionsLocalStorage: transactionsLocalDataSource,
          );
          await accountsRepository.generateMockData();
          d.accountRepository = accountsRepository;
        },
        'Prepare transactions feature': (d) async {
          final database = d.context['drift_database']! as AppDatabase;
          // TODO(frosterlolz): вынести
          final transactionCategoriesCount = await database.transactionCategoryItems.count().getSingle();
          // Категории не заполнены
          if (transactionCategoriesCount == 0) {
            final transactionCategories = transactionCategoriesJson.map(TransactionCategory.fromJson);
            final rows = transactionCategories.map(
              (e) => TransactionCategoryItemsCompanion.insert(
                id: Value(e.id),
                name: e.name,
                emoji: e.emoji,
                isIncome: e.isIncome,
              ),
            );
            await database.transactionCategoryItems.insertAll(rows);
          }

          final transactionsLocalDataSource =
              d.context['transactions_local_data_source']! as TransactionsLocalDataSource;
          final transactionsRepository = TransactionsRepositoryImpl(transactionsLocalDataSource);
          await transactionsRepository.generateMockData();
          d.transactionsRepository = transactionsRepository;
        },
      };

  /// Composes dependencies and returns result of composition.
  Future<InitializationResult> compose() async {
    final dependencies = Mutable$Dependencies();
    final initializationSteps = _prepareInitializationSteps();
    final totalSteps = initializationSteps.length;
    int currentStep = 0;
    final stopwatch = Stopwatch()..start();
    for (final step in initializationSteps.entries) {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      // LOG
      logger.info(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"',
      );
      await step.value(dependencies);
    }

    stopwatch.stop();
    final result = InitializationResult(
      // Important to freeze!!!
      dependencies: dependencies.freeze(),
      msSpent: stopwatch.elapsedMilliseconds,
    );

    logger.info('Application starts at ${result.msSpent} ms');
    return result;
  }
}
