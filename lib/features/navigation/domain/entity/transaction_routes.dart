import 'package:auto_route/auto_route.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';

final expensesRoute = AutoRoute(
  page: const EmptyShellRoute('ExpensesTabRoute').page,
  children: [
    AutoRoute(page: ExpensesRoute.page, initial: true),
    AutoRoute(page: TransactionsHistoryRoute.page),
    AutoRoute(page: TransactionsAnalyzeRoute.page),
  ],
  initial: true,
);

final incomeRoute = AutoRoute(
  page: const EmptyShellRoute('IncomeTabRoute').page,
  children: [
    AutoRoute(page: IncomeRoute.page, initial: true),
    AutoRoute(page: TransactionsHistoryRoute.page),
    AutoRoute(page: TransactionsAnalyzeRoute.page),
  ],
);
