import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/text/text_style.dart';

/// App text style scheme.
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  AppTextTheme._({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  /// Base app text theme.
  static AppTextTheme effective = AppTextTheme._(
    displayLarge: AppTextStyle.displayLarge.value,
    displayMedium: AppTextStyle.displayMedium.value,
    displaySmall: AppTextStyle.displaySmall.value,
    headlineLarge: AppTextStyle.headlineLarge.value,
    headlineMedium: AppTextStyle.headlineMedium.value,
    headlineSmall: AppTextStyle.headlineSmall.value,
    titleLarge: AppTextStyle.titleLarge.value,
    titleMedium: AppTextStyle.titleMedium.value,
    titleSmall: AppTextStyle.titleSmall.value,
    labelLarge: AppTextStyle.labelLarge.value,
    labelMedium: AppTextStyle.labelMedium.value,
    labelSmall: AppTextStyle.labelSmall.value,
    bodyLarge: AppTextStyle.bodyLarge.value,
    bodyMedium: AppTextStyle.bodyMedium.value,
    bodySmall: AppTextStyle.bodySmall.value,
  );

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  static TextTheme textTheme({Color? displayColor, Color? bodyColor}) => TextTheme(
        displayLarge: AppTextTheme.effective.displayLarge.copyWith(color: displayColor),
        displayMedium: AppTextTheme.effective.displayMedium.copyWith(color: displayColor),
        displaySmall: AppTextTheme.effective.displaySmall.copyWith(color: displayColor),
        headlineLarge: AppTextTheme.effective.headlineLarge.copyWith(color: displayColor),
        headlineMedium: AppTextTheme.effective.headlineMedium.copyWith(color: displayColor),
        headlineSmall: AppTextTheme.effective.headlineSmall.copyWith(color: displayColor),
        titleLarge: AppTextTheme.effective.titleLarge.copyWith(color: displayColor),
        titleMedium: AppTextTheme.effective.titleMedium.copyWith(color: bodyColor),
        titleSmall: AppTextTheme.effective.titleSmall.copyWith(color: bodyColor),
        bodyLarge: AppTextTheme.effective.bodyLarge.copyWith(color: bodyColor),
        bodyMedium: AppTextTheme.effective.bodyMedium.copyWith(color: bodyColor),
        bodySmall: AppTextTheme.effective.bodySmall.copyWith(color: bodyColor),
      );

  /// Return text theme for app from context
  static AppTextTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTextTheme>() ?? _throwThemeExceptionFromFunc(context);

  @override
  ThemeExtension<AppTextTheme> copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
  }) =>
      AppTextTheme._(
        displayLarge: displayLarge ?? this.displayLarge,
        displayMedium: displayMedium ?? this.displayMedium,
        displaySmall: displaySmall ?? this.displaySmall,
        headlineLarge: headlineLarge ?? this.headlineLarge,
        headlineMedium: headlineMedium ?? this.headlineMedium,
        headlineSmall: headlineSmall ?? this.headlineSmall,
        titleLarge: titleLarge ?? this.titleLarge,
        titleMedium: titleMedium ?? this.titleMedium,
        titleSmall: titleSmall ?? this.titleSmall,
        labelLarge: labelLarge ?? this.labelLarge,
        labelMedium: labelMedium ?? this.labelMedium,
        labelSmall: labelSmall ?? this.labelSmall,
        bodyLarge: bodyLarge ?? this.bodyLarge,
        bodyMedium: bodyMedium ?? this.bodyMedium,
        bodySmall: bodySmall ?? this.bodySmall,
      );

  @override
  ThemeExtension<AppTextTheme> lerp(ThemeExtension<AppTextTheme>? other, double t) {
    if (other is! AppTextTheme) return this;
    return AppTextTheme._(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
    );
  }
}

Never _throwThemeExceptionFromFunc(BuildContext context) => throw Exception('$AppTextTheme не найдена в $context');
