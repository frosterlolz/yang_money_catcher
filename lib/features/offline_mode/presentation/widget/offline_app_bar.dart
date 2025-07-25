import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/core/data/rest_client/interceptors/offline_mode_check_interceptor.dart';

class OfflineAppBar extends StatelessWidget {
  const OfflineAppBar({required this.offlineModeReason, super.key});

  final OfflineModeReason offlineModeReason;

  bool get _isVisible => offlineModeReason.isOffline;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return ColoredBox(
      color: offlineModeReason.isOffline ? colorScheme.error : colorScheme.primary,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SizedBox.fromSize(
          size: Size.fromHeight(_isVisible ? kToolbarHeight + statusBarHeight : 0.0),
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  context.l10n.offlineModeReason(offlineModeReason.name),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: offlineModeReason.isOffline ? colorScheme.onError : colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
