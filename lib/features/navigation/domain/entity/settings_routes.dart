import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';

final settingsRoutes = AutoRoute(page: SettingsRoute.page);

final hapticSettingsRoute = AutoRoute(page: HapticSettingsRoute.page);

final languageSettingsRoute = CustomRoute<dynamic>(
  page: LanguageSettingsRoute.page,
  customRouteBuilder: <T>(_, Widget child, AutoRoutePage<T> page) => PageRouteBuilder<T>(
    fullscreenDialog: page.fullscreenDialog,
    transitionsBuilder: TransitionsBuilders.slideBottom,
    // this is important
    settings: page,
    pageBuilder: (_, __, ___) => child,
  ),
);
