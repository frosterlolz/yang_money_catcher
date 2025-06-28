import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';
import 'package:yang_money_catcher/ui_kit/text/text_extention.dart';

enum AppTheme { light, dark }

// TODO(frosterlolz): сконфигурировать тему заново!

abstract class AppThemeData {
  static final light = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        // Set the predictive back transitions for Android.
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
    brightness: Brightness.light,
    radioTheme: RadioThemeData(
      fillColor: WidgetStateColor.resolveWith((states) => _lightColorScheme.primary),
    ),
    unselectedWidgetColor: _lightColorScheme.secondary,
    bottomSheetTheme: BottomSheetThemeData(
      dragHandleColor: _lightColorScheme.grabber,
      dragHandleSize: const Size(45, 5),
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: _lightColorScheme.primary,
      onPrimary: _lightColorScheme.onPrimary,
      secondary: _lightColorScheme.secondary,
      onSecondary: _lightColorScheme.onSecondary,
      error: _lightColorScheme.error,
      onError: _lightColorScheme.onError,
      // surface: _lightColorScheme.background,
      // onSurface: _lightColorScheme.onBackground,
      // background: _lightColorScheme.background,
      surface: _lightColorScheme.surface,
      onSurface: _lightColorScheme.onSurface,
    ),
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: _lightColorScheme.primary,
      titleTextStyle: _textTheme.regular20.copyWith(color: _lightColorScheme.onSecondary),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      iconSize: 15.56 * 2,
      sizeConstraints: BoxConstraints.tight(const Size.square(AppSizes.double56)),
      shape: const CircleBorder(),
    ),
    applyElevationOverlayColor: false,
    badgeTheme: BadgeThemeData(
      backgroundColor: _lightColorScheme.onError,
      textColor: _lightColorScheme.onPrimary,
    ),
    cardColor: _lightColorScheme.onPrimary,
    cardTheme: CardTheme(
      surfaceTintColor: _lightColorScheme.onPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: _textTheme.medium16,
        shadowColor: Colors.transparent,
        elevation: 0,
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
      ),
    ),
    iconTheme: IconThemeData(
      color: _lightColorScheme.unselectedItem,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      labelStyle: _textTheme.regular14.copyWith(
        color: _lightColorScheme.inactiveSecondary,
      ),
      border: InputBorder.none,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _lightColorScheme.unselectedItem,
      textColor: _lightColorScheme.unselectedItem,
      contentPadding: const HorizontalSpacing.compact(),
      titleTextStyle: _textTheme.regular16,
      subtitleTextStyle: _textTheme.regular14,
      leadingAndTrailingTextStyle: _textTheme.regular16,
    ),
    fontFamily: 'NunitoSans',
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _lightColorScheme.unselectedItem,
      unselectedItemColor: _lightColorScheme.unselectedItem,
      selectedLabelStyle: _textTheme.semiBold12,
      unselectedLabelStyle: _textTheme.semiBold12,
      selectedIconTheme: const IconThemeData(size: AppSizes.double24),
      unselectedIconTheme: const IconThemeData(size: AppSizes.double24),
    ),
    dividerTheme:
        DividerThemeData(color: _lightColorScheme.dividerColor, space: AppSizes.double1, thickness: AppSizes.double1),
    extensions: [_lightColorScheme, _textTheme],
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _darkColorScheme.onPrimary,
      foregroundColor: _darkColorScheme.onSecondary,
      centerTitle: false,
      titleTextStyle: _textTheme.medium20.copyWith(
        color: _darkColorScheme.onSecondary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: _darkColorScheme.onPrimary,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _darkColorScheme.selectedItem,
      unselectedItemColor: _darkColorScheme.unselectedItem,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: _darkColorScheme.primary,
      onPrimary: _darkColorScheme.onPrimary,
      secondary: _darkColorScheme.secondary,
      onSecondary: _darkColorScheme.onSecondary,
      error: _darkColorScheme.error,
      onError: _darkColorScheme.onError,
      // background: _darkColorScheme.background,
      // onBackground: _darkColorScheme.onBackground,
      surface: _darkColorScheme.surface,
      onSurface: _darkColorScheme.onSurface,
    ),
    scaffoldBackgroundColor: _darkColorScheme.background,
    fontFamily: 'NunitoSans',
    dividerColor: _lightColorScheme.dividerColor,
    extensions: [_darkColorScheme, _textTheme],
  );

  static const _lightColorScheme = AppColorScheme.light();
  static const _darkColorScheme = AppColorScheme.dark();
  static final _textTheme = AppTextTheme.base();
}
