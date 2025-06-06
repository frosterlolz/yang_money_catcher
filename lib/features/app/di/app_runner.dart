import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:yang_money_catcher/features/app/presentation/app.dart';
import 'package:yang_money_catcher/features/initialization/domain/service/initialization_root.dart';
import 'package:yang_money_catcher/features/initialization/presentation/initialization_failed_app.dart';

final class AppRunner {
  const AppRunner();

  Future<void> initializeAndRun(PrettyLogger logger) async {
    final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();

    FlutterError.onError = logger.logFlutterError;
    WidgetsBinding.instance.platformDispatcher.onError = logger.logPlatformDispatcherError;

    final initializationRoot = InitializationRoot(logger);

    Future<void> initializeAndRun() async {
      try {
        final result = await initializationRoot.compose();
        runApp(App(result));
      } on Object catch (e, s) {
        logger.error('App initialization failed', error: e, stackTrace: s);
        runApp(
          InitializationFailedApp(
            error: e,
            stackTrace: s,
            retryInitialization: initializeAndRun,
          ),
        );
      }
    }

    try {
      await initializeAndRun().timeout(const Duration(minutes: 2));
    } finally {
      binding.addPostFrameCallback((_) {
        binding.allowFirstFrame();
      });
    }
  }
}
