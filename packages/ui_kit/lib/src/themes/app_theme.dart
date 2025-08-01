import 'package:flutter/material.dart';
import 'package:ui_kit/src/app_sizes.dart';
import 'package:ui_kit/src/colors/app_color_scheme.dart';
import 'package:ui_kit/src/layout/material_spacing.dart';
import 'package:ui_kit/src/text/text_extension.dart';

abstract class AppThemeData {
  static ThemeData lightFromSeed(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(brightness: Brightness.light, seedColor: seedColor, primary: seedColor);
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Set the predictive back transitions for Android.
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
      brightness: Brightness.light,
      radioTheme: RadioThemeData(
        fillColor: WidgetStateColor.resolveWith((states) => seedColor),
      ),
      unselectedWidgetColor: _lightColorScheme.secondary,
      bottomSheetTheme: BottomSheetThemeData(
        dragHandleColor: _lightColorScheme.grabber,
        dragHandleSize: const Size(45, 5),
      ),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: _textTheme.titleLarge.copyWith(color: colorScheme.onPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconSize: 15.56 * 2,
        sizeConstraints: BoxConstraints.tight(const Size.square(AppSizes.double56)),
        shape: const CircleBorder(),
      ),
      applyElevationOverlayColor: false,
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: colorScheme.outline,
        surfaceTintColor: colorScheme.onPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.double16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: _textTheme.titleMedium,
          shadowColor: Colors.transparent,
          elevation: 0,
          backgroundColor: seedColor,
          foregroundColor: _lightColorScheme.onPrimary,
        ),
      ),
      iconTheme: IconThemeData(
        color: _lightColorScheme.unselectedItem,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        labelStyle: _textTheme.bodyMedium.copyWith(color: _lightColorScheme.inactiveSecondary),
        border: const OutlineInputBorder(),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.double16))),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: _lightColorScheme.onSurface),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: _lightColorScheme.onSurface),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: _lightColorScheme.unselectedItem,
        textColor: _lightColorScheme.unselectedItem,
        contentPadding: const HorizontalSpacing.compact(),
        titleTextStyle: _textTheme.bodyLarge,
        subtitleTextStyle: _textTheme.bodyMedium,
        leadingAndTrailingTextStyle: _textTheme.bodyLarge,
      ),
      fontFamily: 'NunitoSans',
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: _lightColorScheme.surface,
        selectedItemColor: _lightColorScheme.unselectedItem,
        unselectedItemColor: _lightColorScheme.unselectedItem,
        selectedLabelStyle: _textTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: _textTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
        selectedIconTheme: const IconThemeData(size: AppSizes.double24),
        unselectedIconTheme: const IconThemeData(size: AppSizes.double24),
      ),
      textTheme: AppTextTheme.textTheme(),
      dividerTheme: DividerThemeData(
        color: _lightColorScheme.dividerColor,
        space: AppSizes.double1,
        thickness: AppSizes.double1,
      ),
      extensions: [_lightColorScheme, _textTheme],
    );
  }

  static ThemeData darkFromSeed(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, primary: seedColor, brightness: Brightness.dark);

    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Set the predictive back transitions for Android.
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      bottomSheetTheme: const BottomSheetThemeData(
        dragHandleSize: Size(45, 5),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: _textTheme.titleLarge.copyWith(color: colorScheme.onPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        iconSize: 15.56 * 2,
        sizeConstraints: BoxConstraints.tight(const Size.square(AppSizes.double56)),
        shape: const CircleBorder(),
      ),
      textTheme: AppTextTheme.textTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: _textTheme.titleMedium,
          shadowColor: Colors.transparent,
          elevation: 0,
          backgroundColor: seedColor,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.primaryContainer,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSizes.double16))),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: _darkColorScheme.onSurface),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: _darkColorScheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        labelStyle: _textTheme.bodyMedium,
        border: const OutlineInputBorder(),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const HorizontalSpacing.compact(),
        titleTextStyle: _textTheme.bodyLarge,
        subtitleTextStyle: _textTheme.bodyMedium,
        leadingAndTrailingTextStyle: _textTheme.bodyLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: _textTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: _textTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),
        selectedIconTheme: const IconThemeData(size: AppSizes.double24),
        unselectedIconTheme: const IconThemeData(size: AppSizes.double24),
      ),
      fontFamily: 'NunitoSans',
      dividerTheme: const DividerThemeData(
        space: AppSizes.double1,
        thickness: AppSizes.double1,
      ),
      extensions: [_darkColorScheme, _textTheme],
    );
  }

  static const _lightColorScheme = AppColorScheme.light();
  static const _darkColorScheme = AppColorScheme.dark();
  static final _textTheme = AppTextTheme.effective;
}
