import 'package:auto_route/auto_route.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/navigation/domain/entity/entity.dart';
import 'package:yang_money_catcher/features/navigation/domain/entity/pin_settings_routes.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
// ignore_for_file: prefer-match-file-name
class AppRouter extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      path: '/',
      initial: true,
      page: PinAuthenticationStackRoute.page,
      children: [
        AutoRoute(page: PinAuthenticationRoute.page),
        AutoRoute(
          path: '',
          page: MainStackRoute.page,
          children: [
            AutoRoute(
              path: '',
              page: MainRoute.page,
              children: [
                expensesRoute,
                incomeRoute,
                balanceRoute,
                transactionCategoriesRoute,
                settingsRoutes,
              ],
            ),
            hapticSettingsRoute,
            pinSettingsRoutes,
          ],
        ),
      ],
    ),
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
