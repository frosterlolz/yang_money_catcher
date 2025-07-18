import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:rest_client/rest_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yang_money_catcher/features/account/domain/repository/account_repository.dart';
import 'package:yang_money_catcher/features/offline_mode/domain/bloc/offline_mode_bloc/offline_mode_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/repository/settings_repository.dart';
import 'package:yang_money_catcher/features/transactions/domain/repository/transactions_repository.dart';

abstract interface class Dependencies {
  /// [PrettyLogger] instance, used to log messages.
  abstract final PrettyLogger logger;

  /// [SharedPreferencesAsync] instance, used to work with shared preferences.
  abstract final SharedPreferencesAsync sharedPreferences;

  /// [FlutterSecureStorage] instance, used to work with secure storage.
  abstract final FlutterSecureStorage secureStorage;

  /// [RestClient] instance, used to work with rest api.
  abstract final RestClient restClient;

  /// [SettingsRepository] instance, used to work with settings.
  abstract final SettingsRepository settingsRepository;

  /// [AccountRepository] instance, used to work with accounts.
  abstract final AccountRepository accountRepository;

  /// [TransactionsRepository] instance, used to work with transactions.
  abstract final TransactionsRepository transactionsRepository;

  /// [PinAuthenticationBloc] instance, used to work with pin code.
  abstract final PinAuthenticationBloc pinAuthenticationBloc;

  /// [SettingsBloc] instance, used to work with settings.
  abstract final SettingsBloc settingsBloc;

  /// [OfflineModeBloc] instance, used to indicate offline mode reason.
  abstract final OfflineModeBloc offlineModeBloc;
}

final class Mutable$Dependencies implements Dependencies {
  Mutable$Dependencies() : context = <String, Object?>{};

  /// Initialization context
  final Map<String, Object?> context;
  @override
  late PrettyLogger logger;
  @override
  late SharedPreferencesAsync sharedPreferences;
  @override
  late RestClient restClient;
  @override
  late SettingsRepository settingsRepository;
  @override
  late TransactionsRepository transactionsRepository;
  @override
  late AccountRepository accountRepository;
  @override
  late FlutterSecureStorage secureStorage;
  @override
  late PinAuthenticationBloc pinAuthenticationBloc;
  @override
  late SettingsBloc settingsBloc;
  @override
  late OfflineModeBloc offlineModeBloc;

  Dependencies freeze() => _Immutable$Dependencies(
        logger: logger,
        sharedPreferences: sharedPreferences,
        transactionsRepository: transactionsRepository,
        accountRepository: accountRepository,
        restClient: restClient,
        offlineModeBloc: offlineModeBloc,
        settingsRepository: settingsRepository,
        settingsBloc: settingsBloc,
        secureStorage: secureStorage,
        pinAuthenticationBloc: pinAuthenticationBloc,
      );
}

@immutable
final class _Immutable$Dependencies implements Dependencies {
  const _Immutable$Dependencies({
    required this.logger,
    required this.sharedPreferences,
    required this.transactionsRepository,
    required this.accountRepository,
    required this.restClient,
    required this.offlineModeBloc,
    required this.settingsRepository,
    required this.settingsBloc,
    required this.secureStorage,
    required this.pinAuthenticationBloc,
  });

  @override
  final PrettyLogger logger;
  @override
  final SharedPreferencesAsync sharedPreferences;
  @override
  final SettingsRepository settingsRepository;
  @override
  final TransactionsRepository transactionsRepository;
  @override
  final AccountRepository accountRepository;
  @override
  final FlutterSecureStorage secureStorage;
  @override
  final PinAuthenticationBloc pinAuthenticationBloc;
  @override
  final RestClient restClient;
  @override
  final SettingsBloc settingsBloc;
  @override
  final OfflineModeBloc offlineModeBloc;
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
