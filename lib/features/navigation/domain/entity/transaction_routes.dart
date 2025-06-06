import 'package:auto_route/auto_route.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';

final expensesRoute = AutoRoute(page: ExpensesRoute.page, initial: true);

final incomeRoute = AutoRoute(page: IncomeRoute.page);
