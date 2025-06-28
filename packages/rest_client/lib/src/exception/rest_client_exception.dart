import 'package:flutter/foundation.dart';
import 'package:rest_client/rest_client.dart';

/// {@template rest_client_exception}
/// Base class for all rest client exceptions
/// {@endtemplate}
@immutable
sealed class RestClientException implements Exception {
  /// {@macro network_exception}
  const RestClientException({required this.message, this.statusCode, this.cause});

  /// Message of the exception
  final String message;

  /// The status code of the response (if any)
  final int? statusCode;

  /// The cause of the exception
  ///
  /// It is the exception that caused this exception to be thrown.
  ///
  /// If the exception is not caused by another exception, this field is `null`.
  final Object? cause;

  @override
  String toString() => message;
}

/// {@template client_exception}
/// [ClientException] is thrown if something went wrong on client side
/// {@endtemplate}
final class ClientException extends RestClientException {
  /// {@macro client_exception}
  const ClientException({
    required super.message,
    super.statusCode,
    super.cause,
  });

  @override
  String toString() => 'ClientException('
      'message: $message, '
      'statusCode: $statusCode, '
      'cause: $cause'
      ')';
}

/// {@template structured_backend_exception}
/// Exception that is used for structured backend errors
///
/// [error] is a map that contains the error details
///
/// This exception is raised by [RestClientBase] when the response contains
/// 'error' field like the following:
/// ```json
/// {
///  "error": {
///   "message": "Some error message",
///   "code": 123
/// }
/// ```
///
/// This class exists to make handling of structured errors easier.
/// Basically, in data providers that use [RestClientBase], you can catch
/// this exception and convert it to a system-wide error. For example,
/// if backend returns an error with code 123 that means that the action
/// is not allowed, you can convert this exception to a NotAllowedException
/// and rethrow. This way, the rest of the application does not need to know
/// about the structure of the error and should only handle system-wide
/// exceptions.
/// {@endtemplate}
final class StructuredBackendException extends RestClientException {
  /// {@macro structured_backend_exception}
  const StructuredBackendException({required this.error, super.statusCode})
      : super(message: 'Backend returned structured error');

  /// The error returned by the backend
  final JsonMap error;

  String? get errorMessage => error['message'] as String?;

  @override
  String toString() => 'StructuredBackendException('
      'message: $message, '
      'error: $error, '
      'statusCode: $statusCode, '
      ')';
}

/// {@template connection_exception}
/// [ConnectionException] is thrown if there are problems with the connection
/// {@endtemplate}
final class ConnectionException extends RestClientException {
  /// {@macro connection_exception}
  const ConnectionException({required super.message, super.statusCode, super.cause});

  @override
  String toString() => 'ConnectionException('
      'message: $message, '
      'statusCode: $statusCode, '
      'cause: $cause'
      ')';
}
