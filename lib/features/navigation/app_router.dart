import 'package:auto_route/auto_route.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/navigation/domain/entity/entity.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
// ignore_for_file: prefer-match-file-name
class AppRouter extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      path: '/',
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
    RedirectRoute(path: '*', redirectTo: '/'),
  ];
}
