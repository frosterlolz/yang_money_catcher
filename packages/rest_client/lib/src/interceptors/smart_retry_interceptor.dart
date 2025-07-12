import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:rest_client/rest_client.dart';

const _effectiveRetryableStatuses = {500, 502, 503, 504, 408, 429};
const _effectiveRetriesCount = 3;
const _retryAfterHeaderKey = 'retry-after';
const _defaultDisableRetryKey = 'disable_retry';
const _attemptsExtraKey = 'retry_attempts_extra';

typedef LogReporter = void Function(String message, {Object? error, StackTrace? stackTrace});

class SmartRetryInterceptor extends Interceptor with RetryRequestMixin {
  const SmartRetryInterceptor({
    required this.dio,
    this.retriesCount = _effectiveRetriesCount,
    this.retryDelays,
    this.retryableStatusCodes = _effectiveRetryableStatuses,
    this.disableRetryKey = _defaultDisableRetryKey,
    this.logReporter,
  }) : assert(retriesCount >= 0, 'retriesCount must be >= 0');

  final Dio dio;
  final List<Duration>? retryDelays;
  final int retriesCount;
  final Set<int> retryableStatusCodes;
  final String disableRetryKey;
  final LogReporter? logReporter;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.disableRetry) {
      return super.onError(err, handler);
    }
    bool isRequestCancelled() => err.requestOptions.cancelToken?.isCancelled ?? false;

    final attempt = err.requestOptions.attempt + 1;
    final shouldRetry = attempt <= retriesCount && _shouldRetry(err, attempt);

    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt, headers: err.response?.statusCode == 429 ? err.response?.headers : null);
    logReporter?.call(
      'Trying to retry $attempt/$retriesCount'
      'wait ${delay.inMilliseconds} ms',
      error: err.error ?? err,
      stackTrace: err.stackTrace,
    );

    final originalOptions = err.requestOptions;
    final requestOptions = originalOptions.data is FormData ? _recreateOptions(originalOptions) : originalOptions;

    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (isRequestCancelled()) {
      logReporter?.call('Request was cancelled. Cancel retrying.');
      return handler.next(err);
    }

    try {
      final response = await retryRequest<dynamic>(original: requestOptions, retryClient: dio);

      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException error, int attempt) {
    try {
      bool shouldRetry;
      if (error.type == DioExceptionType.badResponse) {
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          shouldRetry = _isRetryable(statusCode);
        } else {
          shouldRetry = true;
        }
      } else {
        shouldRetry = error.type != DioExceptionType.cancel && error.error is! FormatException;
      }
      return shouldRetry;
    } on Object catch (e, s) {
      logReporter?.call('There was an exception in _shouldRetry: $e', error: e, stackTrace: s);
      rethrow;
    }
  }

  bool _isRetryable(int statusCode) => retryableStatusCodes.contains(statusCode);

  Duration _getDelay(int attempt, {Headers? headers}) {
    final retryAfterSeconds = headers == null ? null : _parseRetryAfterHeader(headers);
    if (retryAfterSeconds != null) {
      logReporter?.call('Applying Retry-After: $retryAfterSeconds seconds');
      return Duration(seconds: retryAfterSeconds);
    }
    final customDelays = retryDelays;
    if (customDelays == null) {
      return _calculateBackoff(attempt);
    }

    if (customDelays.isEmpty) return Duration.zero;

    final index = attempt - 1;
    return index < customDelays.length ? customDelays[index] : customDelays.last;
  }

  Duration _calculateBackoff(int attempt) {
    final baseDelayMs = 1000 * (1 << (attempt - 1)); // 1s, 2s, 4s...
    final jitterMs = Random().nextInt(300); // up to +300ms
    return Duration(milliseconds: baseDelayMs + jitterMs);
  }

  int? _parseRetryAfterHeader(Headers headers) {
    final value = headers.value(_retryAfterHeaderKey);
    return value == null ? null : int.tryParse(value);
  }

  RequestOptions _recreateOptions(RequestOptions options) {
    if (options.data is! FormData) {
      throw ArgumentError(
        'requestOptions.data is not FormData',
        'requestOptions',
      );
    }
    final formData = options.data as FormData;
    final newFormData = formData.clone();
    return options.copyWith(data: newFormData);
  }
}

extension RequestOptionsX on RequestOptions {
  int get attempt {
    final value = extra[_attemptsExtraKey];
    return value is int ? value : 0;
  }

  bool get disableRetry {
    final value = extra[_defaultDisableRetryKey];
    return value is bool ? value : false;
  }

  set disableRetry(bool value) => extra[_defaultDisableRetryKey] = value;

  set _attempt(int value) => extra[_attemptsExtraKey] = value;
}
