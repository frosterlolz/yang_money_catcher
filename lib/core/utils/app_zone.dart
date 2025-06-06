import 'dart:async';

import 'package:pretty_logger/pretty_logger.dart';

void appZone(FutureOr<void> Function(PrettyLogger logger) fn) {
  final logger = DefaultLogger();
  runWithLogger(
    logger,
    () => runZonedGuarded(
      () => fn(logger),
      logger.logZoneError,
    ),
  );
}
