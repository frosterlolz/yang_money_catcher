import 'package:auto_route/auto_route.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';

final pinSettingsRoutes = AutoRoute(
  page: PinSettingsStackRoute.page,
  children: [
    AutoRoute(page: PinSettingsVerificationRoute.page),
    AutoRoute(page: PinSettingsRoute.page),
    AutoRoute(page: PinSettingsPreviewRoute.page),
    AutoRoute(page: PinAuthenticationRoute.page),
  ],
);
