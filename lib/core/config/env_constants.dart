const _environment = 'ENVIRONMENT';
const _baseUrl = 'BASE_URL';
const _apiEndpoint = 'api/v1';
const _authKey = 'AUTH_TOKEN';
const _syncAttempts = 'SYNC_ATTEMPTS';
const _skipAuth = 'SKIP_AUTH';
const _useMocks = 'USE_MOCKS';

abstract final class EnvConstants {
  const EnvConstants();

  // --- ENVIRONMENT --- //

  /// Environment flavor.
  /// e.g. dev, prod
  static final EnvironmentFlavor environment =
      EnvironmentFlavor.from(const String.fromEnvironment(_environment, defaultValue: 'dev'));

  // --- API --- //

  static const String baseUrl = String.fromEnvironment(_baseUrl);
  static const String apiUrl = '$baseUrl/$_apiEndpoint';
  static const String authToken = String.fromEnvironment(_authKey);

  // --- DATABASE CONSTANTS --- //

  static const int maxSyncActionAttempts = int.fromEnvironment(_syncAttempts, defaultValue: 3);

  // --- CORE SETTINGS --- //

  /// if true -> PinAuthenticationStatus will be true at startup
  static const bool skipAuthentication = bool.fromEnvironment(_skipAuth, defaultValue: false);

  /// if true -> will used mock repositories
  static const bool useMocks = bool.fromEnvironment(_useMocks, defaultValue: false);
}

/// Environment flavor.
/// e.g. development, staging, production
enum EnvironmentFlavor {
  /// Development
  dev('dev'),

  /// Production
  prod('prod');

  /// Create environment flavor.
  const EnvironmentFlavor(this.value);

  /// Create environment flavor from string.
  factory EnvironmentFlavor.from(String? value) => switch (value?.trim().toLowerCase()) {
        'development' || 'debug' || 'develop' || 'dev' => dev,
        'production' || 'release' || 'prod' || 'prd' => prod,
        _ => const bool.fromEnvironment('dart.vm.product') ? prod : dev,
      };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == dev;

  /// Whether the environment is production.
  bool get isProduction => this == prod;
}
