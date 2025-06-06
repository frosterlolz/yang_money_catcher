import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template MainScreen.class}
/// Главный экран после запуска приложения.
/// Содерржит в себе нижнюю навигационный бар
/// {@endtemplate}
@RoutePage()
class MainScreen extends StatelessWidget {
  /// {@macro MainScreen.class}
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.l10n;
    const bottomRoutes = [
      ExpensesRoute(),
      IncomeRoute(),
      AccountRoute(),
      TransactionCategoriesRoute(),
      SettingsRoute(),
    ];

    // TODO(frosterlolz): заменить иконки
    final bottomItems = <String, IconData>{
      localizations.expenses: Icons.abc,
      localizations.income: Icons.abc,
      localizations.account: Icons.abc,
      localizations.articles: Icons.abc,
      localizations.settings: Icons.abc,
    };

    return AutoTabsRouter(
      routes: bottomRoutes,
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              iconSize: 30,
              currentIndex: tabsRouter.activeIndex,
              onTap: tabsRouter.setActiveIndex,
              items: List.generate(
                bottomItems.length,
                (index) {
                  final bottomBarEntry = bottomItems.entries.elementAt(index);
                  return BottomNavigationBarItem(
                    label: bottomBarEntry.key,
                    icon: Icon(bottomBarEntry.value),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
