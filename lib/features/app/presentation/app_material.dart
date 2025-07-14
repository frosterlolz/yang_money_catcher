import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:yang_money_catcher/features/navigation/app_router.dart';
import 'package:yang_money_catcher/features/navigation/service/root_route_observer.dart';
import 'package:yang_money_catcher/features/offline_mode/domain/bloc/offline_mode_bloc/offline_mode_bloc.dart';
import 'package:yang_money_catcher/features/offline_mode/presentation/widget/offline_app_bar.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/settings.dart';
import 'package:yang_money_catcher/l10n/localization.dart';
import 'package:yang_money_catcher/ui_kit/themes/app_theme.dart';

/// {@template AppMaterial.class}
/// AppMaterial widget.
/// {@endtemplate}
class AppMaterial extends StatefulWidget {
  /// {@macro AppMaterial.class}
  const AppMaterial({super.key});

  @override
  State<AppMaterial> createState() => _AppMaterialState();
}

class _AppMaterialState extends State<AppMaterial> {
  /// Позволяет избежать излишних перестроений дерева, а также
  /// служит для корректной работы с виджет-инспектором
  final GlobalKey _builderKey = GlobalKey(debugLabel: 'AppMaterial');
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    // TODO(frosterlolz): для соло локализации
    Intl.defaultLocale = 'ru';
  }

  @override
  Widget build(BuildContext context) => BlocSelector<SettingsBloc, SettingsState, Settings>(
        selector: (state) => state.settings,
        builder: (context, settings) {
          final themeMode = settings.themeConfig.themeMode;
          final seedColor = settings.themeConfig.seedColor;
          final locale = settings.locale;

          final lightTheme = AppThemeData.lightFromSeed(seedColor);
          final darkTheme = AppThemeData.darkFromSeed(seedColor);

          return MaterialApp.router(
            /// Localization
            localizationsDelegates: Localization.localizationDelegates,
            supportedLocales: Localization.supportedLocales,
            locale: locale,

            /// Theme
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,

            /// Navigation
            routerConfig: _appRouter.config(
              navigatorObservers: () => [RootRouteObserver()],
            ),
            debugShowCheckedModeBanner: kDebugMode,
            builder: (context, child) => MediaQuery(
              key: _builderKey,
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: BlocBuilder<OfflineModeBloc, OfflineModeState>(
                builder: (context, offlineModeState) {
                  final currentReason = offlineModeState.reason;

                  return Column(
                    children: [
                      OfflineAppBar(offlineModeReason: currentReason),
                      Expanded(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: currentReason.isOffline,
                          child: child ?? const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
}
