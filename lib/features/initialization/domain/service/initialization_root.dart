import 'dart:async';

import 'package:pretty_logger/pretty_logger.dart';
import 'package:yang_money_catcher/features/account/data/repository/mock_account_repository.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';
import 'package:yang_money_catcher/features/transactions/data/repository/mock_transactions_repository.dart';
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
        'Init root repositories': (d) {
          final transactionsLocalDataSource = TransactionsLocalDataSource();
          d
            ..accountRepository = MockAccountRepository()
            ..transactionsRepository = MockTransactionsRepository(transactionsLocalDataSource);
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
