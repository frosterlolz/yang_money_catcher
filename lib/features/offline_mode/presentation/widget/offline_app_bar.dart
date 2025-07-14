import 'package:flutter/material.dart';
import 'package:yang_money_catcher/core/data/rest_client/interceptors/offline_mode_check_interceptor.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

class OfflineAppBar extends StatelessWidget {
  const OfflineAppBar({required this.offlineModeReason, super.key});

  final OfflineModeReason offlineModeReason;

  bool get _isVisible => offlineModeReason.isOffline;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final colorScheme = AppColorScheme.of(context);

    return ColoredBox(
      color: offlineModeReason.isOffline ? colorScheme.errorContainer : colorScheme.primary,
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
                  style: TextTheme.of(context).bodyLarge?.copyWith(
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
