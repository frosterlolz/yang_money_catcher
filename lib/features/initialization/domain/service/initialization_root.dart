import 'dart:async';

import 'package:database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:rest_client/rest_client.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:yang_money_catcher/core/config/env_constants.dart';
import 'package:yang_money_catcher/core/data/rest_client/dio_configurator.dart';
import 'package:yang_money_catcher/core/data/rest_client/interceptors/auth_interceptor.dart';
import 'package:yang_money_catcher/core/data/rest_client/interceptors/logging_interceptor.dart';
import 'package:yang_money_catcher/core/data/rest_client/transformers/worker_background_transformer.dart';
import 'package:yang_money_catcher/features/account/data/repository/account_repository_impl.dart';
import 'package:yang_money_catcher/features/account/data/source/local/account_events_sync_data_source_drift.dart';
import 'package:yang_money_catcher/features/account/data/source/local/accounts_local_data_source_drift.dart';
import 'package:yang_money_catcher/features/account/data/source/network/accounts_network_data_source_rest.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/transactions_repository_impl.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transaction_events_sync_data_source_drift.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source.dart';
import 'package:yang_money_catcher/features/transactions/data/source/local/transactions_local_data_source_drift.dart';
import 'package:yang_money_catcher/features/transactions/data/source/network/transactions_netrowk_data_source_rest.dart';

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
        'Init workers': (_) async {
          await workerManager.init();
        },
        'Prepare database': (d) async {
          final database = AppDatabase.defaults(name: 'yang_money_catcher_database');
          d.context['drift_database'] = database;
        },
        'Initialize rest client': (d) async {
          final dio = const DioConfigurator().create(
            url: EnvConstants.apiUrl,
            transformer: WorkerBackgroundTransformer(),
            interceptors: [
              AuthInterceptor(token: EnvConstants.authToken),
              if (kDebugMode) LoggingInterceptor(d.logger),
            ],
          );
          d.restClient = RestClientDio(dio: dio);
        },
        'Prepare accounts feature': (d) async {
          final database = d.context['drift_database']! as AppDatabase;
          final accountsDao = AccountsDao(database);
          final accountsLocalDataSource = AccountsLocalDataSource$Drift(accountsDao);
          final transactionsDao = TransactionsDao(database);
          final transactionsLocalDataSource = TransactionsLocalDataSource$Drift(transactionsDao);
          d.context['transactions_local_data_source'] = transactionsLocalDataSource;
          final accountsNetworkDataSource = AccountsNetworkDataSource$Rest(d.restClient);
          final accountEventsSyncDataSource = AccountEventsSyncDataSource$Drift(AccountEventsDao(database));
          final accountsRepository = AccountRepositoryImpl(
            accountsNetworkDataSource: accountsNetworkDataSource,
            accountsLocalStorage: accountsLocalDataSource,
            transactionsLocalStorage: transactionsLocalDataSource,
            accountEventsSyncDataSource: accountEventsSyncDataSource,
          );
          // TODO(frosterlolz): мок данные не треюбуются, БЭК подключен
          // await accountsRepository.generateMockData();
          d.accountRepository = accountsRepository;
        },
        'Prepare transactions feature': (d) async {
          final database = d.context['drift_database']! as AppDatabase;
          final transactionsLocalDataSource =
              d.context['transactions_local_data_source']! as TransactionsLocalDataSource;
          final transactionsNetworkDataSource = TransactionsNetworkDataSource$Rest(d.restClient);
          final transactionEventsDao = TransactionEventsDao(database);
          final transactionEventsSyncDataSource = TransactionEventsSyncDataSource$Drift(transactionEventsDao);
          final transactionsRepository = TransactionsRepositoryImpl(
            transactionsLocalDataSource: transactionsLocalDataSource,
            transactionsNetworkDataSource: transactionsNetworkDataSource,
            transactionsSyncDataSource: transactionEventsSyncDataSource,
          );
          // TODO(frosterlolz): мок данные не треюбуются, БЭК подключен
          // await transactionsRepository.fillTransactionCategories();
          // await transactionsRepository.generateMockData();
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
