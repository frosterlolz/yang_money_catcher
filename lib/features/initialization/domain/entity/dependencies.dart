import 'package:meta/meta.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

abstract interface class Dependencies {
  /// [PrettyLogger] instance, used to log messages.
  abstract final PrettyLogger logger;

  /// [AccountRepository] instance, used to work with accounts.
  abstract final AccountRepository accountRepository;

  /// [TransactionsRepository] instance, used to work with transactions.
  abstract final TransactionsRepository transactionsRepository;
}

final class Mutable$Dependencies implements Dependencies {
  Mutable$Dependencies() : context = <String, Object?>{};

  /// Initialization context
  final Map<String, Object?> context;
  @override
  late PrettyLogger logger;
  @override
  late TransactionsRepository transactionsRepository;
  @override
  late AccountRepository accountRepository;

  Dependencies freeze() => _Immutable$Dependencies(
        logger: logger,
        transactionsRepository: transactionsRepository,
        accountRepository: accountRepository,
      );
}

@immutable
final class _Immutable$Dependencies implements Dependencies {
  const _Immutable$Dependencies({
    required this.logger,
    required this.transactionsRepository,
    required this.accountRepository,
  });

  @override
  final PrettyLogger logger;
  @override
  final TransactionsRepository transactionsRepository;
  @override
  final AccountRepository accountRepository;
}

final class InitializationResult {
  const InitializationResult({
    required this.dependencies,
    required this.msSpent,
  });

  /// Result [Dependencies] after initialization
  final Dependencies dependencies;

  /// Time spent on initialization
  final int msSpent;

  @override
  String toString() => '$InitializationResult('
      'dependencies: $dependencies, '
      'msSpent: $msSpent'
      ')';
}

/// {@template testing_dependencies_container}
/// A special version of [Dependencies] that is used in tests.
///
/// In order to use [Dependencies] in tests, it is needed to
/// extend this class and provide the dependencies that are needed for the test.
/// {@endtemplate}
base class TestDependenciesContainer implements Dependencies {
  /// {@macro testing_dependencies_container}
  const TestDependenciesContainer();

  @override
  Object noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'The test tries to access ${invocation.memberName} dependency, but '
      'it was not provided. Please provide the dependency in the test. '
      'You can do it by extending this class and providing the dependency.',
    );
  }
}
