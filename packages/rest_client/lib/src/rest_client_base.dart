import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rest_client/rest_client.dart';

/// {@macro rest_client}
@immutable
abstract base class RestClientBase implements RestClient {
  /// {@macro rest_client}
  RestClientBase({required String baseUrl}) : baseUri = Uri.parse(baseUrl);

  /// The base url for the client
  final Uri baseUri;

  static final _jsonUTF8 = json.fuse(utf8);

  /// Sends a request to the server
  Future<JsonMap?> send({
    required String path,
    required String method,
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  });

  @override
  Future<JsonMap?> get(
    String path, {
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) =>
      send(path: path, method: 'GET', headers: headers, extra: extra, queryParams: queryParams);

  @override
  Future<JsonMap?> post(
    String path, {
    required Object body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) =>
      send(path: path, method: 'POST', body: body, headers: headers, extra: extra, queryParams: queryParams);

  @override
  Future<JsonMap?> put(
    String path, {
    JsonMap? body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) =>
      send(path: path, method: 'PUT', body: body, headers: headers, extra: extra, queryParams: queryParams);

  @override
  Future<JsonMap?> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) =>
      send(path: path, method: 'DELETE', headers: headers, extra: extra, queryParams: queryParams, body: body);

  @override
  Future<JsonMap?> patch(
    String path, {
    required JsonMap body,
    Map<String, String>? headers,
    Map<String, Object>? extra,
    JsonMap? queryParams,
  }) =>
      send(path: path, method: 'PATCH', body: body, headers: headers, extra: extra, queryParams: queryParams);

  /// Encodes [body] to JSON and then to UTF8
  @protected
  @visibleForTesting
  List<int> encodeBody(JsonMap body) {
    try {
      return _jsonUTF8.encode(body);
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        ClientException(message: 'Error occured during encoding $e'),
        stackTrace,
      );
    }
  }

  /// Decodes [body] from JSON \ UTF8
  @protected
  @visibleForTesting
  FutureOr<JsonMap?> decodeResponse(Object? body, {int? statusCode}) async {
    if (body == null) return null;
    try {
      final decodedBody = switch (body) {
        final JsonMap data => data,
        final String data => await _decodeString(data),
        final List<int> data => await _decodeBytes(data),
        final JsonList data => {'data': data},
        _ => null,
      };

      if (decodedBody case {'error': final JsonMap error}) {
        throw StructuredBackendException(error: error, statusCode: statusCode);
      }
      if (decodedBody case {'data': final JsonMap data}) {
        return data;
      }

      return decodedBody;
    } on RestClientException {
      rethrow;
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        ClientException(message: 'Error occured during decoding', statusCode: statusCode, cause: e),
        stackTrace,
      );
    }
  }

  /// Decodes a [String] to a [JsonMap]
  Future<JsonMap?> _decodeString(String stringBody) async {
    if (stringBody.isEmpty) return null;

    if (stringBody.length > 1000) {
      return (await compute(
        json.decode,
        stringBody,
        debugLabel: kDebugMode ? 'Decode String Compute' : null,
      )) as JsonMap;
    }

    return json.decode(stringBody) as JsonMap;
  }

  /// Decodes a [List<int>] to a [JsonMap]
  Future<JsonMap?> _decodeBytes(List<int> bytesBody) async {
    if (bytesBody.isEmpty) return null;

    if (bytesBody.length > 1000) {
      return (await compute(
        _jsonUTF8.decode,
        bytesBody,
        debugLabel: kDebugMode ? 'Decode Bytes Compute' : null,
      ))! as JsonMap;
    }

    return _jsonUTF8.decode(bytesBody)! as JsonMap;
  }
}
