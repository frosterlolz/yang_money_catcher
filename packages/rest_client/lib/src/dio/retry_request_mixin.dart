import 'package:dio/dio.dart';
import 'package:rest_client/src/dio/dio_x.dart';

/// A mixin that provides a method to retry a request.
mixin class RetryRequestMixin {
  /// Retry the request
  Future<Response<R>> retryRequest<R>({
    required RequestOptions original,
    required Dio retryClient,
    Map<String, dynamic>? headers,
  }) {
    final effectiveHeaders = headers ?? Map<String, dynamic>.from(original.headers);

    return retryClient.request<R>(
      original.fullPath,
      cancelToken: original.cancelToken,
      data: original.data,
      onReceiveProgress: original.onReceiveProgress,
      onSendProgress: original.onSendProgress,
      queryParameters: original.queryParameters,
      options: Options(
        method: original.method,
        sendTimeout: original.sendTimeout,
        receiveTimeout: original.receiveTimeout,
        extra: original.extra,
        headers: effectiveHeaders,
        responseType: original.responseType,
        contentType: original.contentType,
        validateStatus: original.validateStatus,
        receiveDataWhenStatusError: original.receiveDataWhenStatusError,
        followRedirects: original.followRedirects,
        maxRedirects: original.maxRedirects,
        requestEncoder: original.requestEncoder,
        responseDecoder: original.responseDecoder,
        listFormat: original.listFormat,
      ),
    );
  }
}
