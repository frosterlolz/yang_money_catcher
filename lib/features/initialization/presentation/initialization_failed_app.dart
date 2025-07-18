import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rest_client/rest_client.dart';
import 'package:yang_money_catcher/core/utils/extensions/value_notifier_x.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/l10n/localization.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/color_palette.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';
import 'package:yang_money_catcher/ui_kit/text/text_style.dart';

/// {@template initialization_failed_screen}
/// InitializationFailedScreen widget
/// {@endtemplate}
class InitializationFailedApp extends StatefulWidget {
  /// {@macro initialization_failed_screen}
  const InitializationFailedApp({
    required this.error,
    required this.stackTrace,
    this.retryInitialization,
    super.key,
  });

  /// The error that caused the initialization to fail.
  final Object error;

  /// The stack trace of the error that caused the initialization to fail.
  final StackTrace stackTrace;

  /// The callback that will be called when the retry button is pressed.
  ///
  /// If null, the retry button will not be shown.
  final Future<void> Function()? retryInitialization;

  @override
  State<InitializationFailedApp> createState() => _InitializationFailedAppState();
}

class _InitializationFailedAppState extends State<InitializationFailedApp> {
  /// Whether the initialization is in progress.
  final _inProgress = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _inProgress.dispose();
    super.dispose();
  }

  Future<void> _retryInitialization() async {
    if (_inProgress.value) {
      return;
    }
    _inProgress.emit(true);
    try {
      await widget.retryInitialization!().timeout(
        const Duration(seconds: 30),
      );
    } finally {
      _inProgress.emit(false);
    }
  }

  Future<void> _onCopyErrorTap(BuildContext context) async {
    final copiedErrorData = '${widget.error}\n${widget.stackTrace}';
    await Clipboard.setData(ClipboardData(text: copiedErrorData));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        locale: Localization.current?.locale,
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        builder: (context, _) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Scaffold(
            backgroundColor: ColorPalette.white,
            body: Padding(
              padding: const HorizontalSpacing.compact(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                          const FractionallySizedBox(
                            widthFactor: 0.4,
                            child: FlutterLogo(),
                          ),
                          const SizedBox(height: AppSizes.double28),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.appCurrentlyUnavailable,
                                style: AppTextStyle.medium20.value,
                              ),
                              const SizedBox(height: 19.0),
                              Text(
                                switch (widget.error) {
                                  ClientException(:final statusCode) when statusCode == 401 =>
                                    context.l10n.pleaseProvideCorrectToken,
                                  _ => context.l10n.mayBeFailTryItLater,
                                },
                                style: AppTextStyle.regular16.value,
                              ),
                              if (kDebugMode)
                                GestureDetector(
                                  onDoubleTap: () => _onCopyErrorTap(context),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 20,
                                      children: [
                                        Text(widget.error.toString()),
                                        Text(widget.stackTrace.toString()),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: kBottomNavigationBarHeight),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.retryInitialization != null)
                    SafeArea(
                      top: false,
                      child: FilledButton(
                        onPressed: _retryInitialization,
                        style: FilledButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          backgroundColor: ColorPalette.ufoGreen,
                          foregroundColor: ColorPalette.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          textStyle: AppTextStyle.medium15.value,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _inProgress,
                          builder: (context, v, _) {
                            if (v) {
                              return const Center(child: CircularProgressIndicator.adaptive());
                            }
                            return Text(context.l10n.reload);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
