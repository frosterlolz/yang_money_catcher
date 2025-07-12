import 'package:dio/dio.dart';

extension DioRequestX on RequestOptions {
  /// Get path with baseUrl, (if needed)
  String get fullPath {
    String url = path;
    if (!url.startsWith(RegExp(r'https?:'))) {
      url = baseUrl + url;
      final s = url.split(':/');
      if (s.length == 2) {
        url = '${s[0]}:/${s[1].replaceAll('//', '/')}';
      }
    }

    return url;
  }
}
