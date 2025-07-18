import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';

/// {@template MainScreen.class}
/// Главный экран после запуска приложения.
/// Содерржит в себе нижнюю навигационный бар
/// {@endtemplate}
@RoutePage()
class MainScreen extends StatelessWidget {
  /// {@macro MainScreen.class}
  const MainScreen({super.key});

  void _onTabChanged(BuildContext context, {required int index, required TabsRouter tabRouter}) {
    final currentIndex = tabRouter.activeIndex;
    if (currentIndex != index) {
      context.read<SettingsBloc>().state.settings.hapticType.play();
    }
    tabRouter.setActiveIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

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
            child: BlocSelector<SettingsBloc, SettingsState, Color>(
              selector: (state) => state.settings.themeConfig.seedColor,
              builder: (context, seedColor) => BottomNavigationBar(
                iconSize: 30,
                currentIndex: tabsRouter.activeIndex,
                onTap: (index) => _onTabChanged(context, index: index, tabRouter: tabsRouter),
                items: List.generate(
                  bottomItems.length,
                  (index) {
                    final bottomBarEntry = bottomItems.entries.elementAt(index);
                    final isSelected = index == tabsRouter.activeIndex;
                    return BottomNavigationBarItem(
                      label: bottomBarEntry.key,
                      icon: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primaryContainer : null,
                          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.double16)),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: AppSizes.double20, vertical: AppSizes.double4),
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
          ),
        );
      },
    );
  }
}
