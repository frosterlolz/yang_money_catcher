import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

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
    final colorScheme = AppColorScheme.of(context);
    final localizations = context.l10n;
    const bottomRoutes = [
      ExpensesRoute(),
      IncomeRoute(),
      AccountRoute(),
      TransactionCategoriesRoute(),
      SettingsRoute(),
    ];

    final bottomItems = <String, String>{
      localizations.expenses: SvgIcons.graphDown,
      localizations.income: SvgIcons.graphUp,
      localizations.account: SvgIcons.calculator,
      localizations.articles: SvgIcons.articles,
      localizations.settings: SvgIcons.settings,
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
                  final isSelected = index == tabsRouter.activeIndex;
                  return BottomNavigationBarItem(
                    label: bottomBarEntry.key,
                    icon: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.secondary : null,
                        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.double16)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.double20, vertical: AppSizes.double4),
                        child: SvgPicture.asset(
                          bottomBarEntry.value,
                          colorFilter: ColorFilter.mode(
                            isSelected ? colorScheme.primary : colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
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
