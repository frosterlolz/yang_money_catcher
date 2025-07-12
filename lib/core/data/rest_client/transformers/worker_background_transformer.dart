import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';

/// [Transformer] used worker_manager to decode JSON for [Dio] response.
///
/// [BackgroundTransformer] will do the deserialization of JSON in
/// a background isolate if possible.
class WorkerBackgroundTransformer extends SyncTransformer {
  WorkerBackgroundTransformer() : super(jsonDecodeCallback: _decodeJson);
}

FutureOr<Object?> _decodeJson(String text) async {
  // Taken from https://github.com/flutter/flutter/blob/135454af32477f815a7525073027a3ff9eff1bfd/packages/flutter/lib/src/services/asset_bundle.dart#L87-L93
  // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs
  // on a Pixel 4.
  if (text.codeUnits.length < 50 * 1024) {
    return jsonDecode(text);
  }
  // For strings larger than 50 KB, run the computation in an isolate to
  // avoid causing main thread jank.
  final res = workerManager.execute<Object?>(() => jsonDecode(text));
  return res.future;
}
