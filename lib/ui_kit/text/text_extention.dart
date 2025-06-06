import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/text/text_style.dart';

/// App text style scheme.
// ignore_for_file: prefer-match-file-name
// ignore_for_file: member-ordering

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  AppTextTheme._({
    required this.regular11,
    required this.regular12,
    required this.regular13,
    required this.regular14,
    required this.regular15,
    required this.regular16,
    required this.regular18,
    required this.regular20,
    required this.medium11,
    required this.medium12,
    required this.medium13,
    required this.medium14,
    required this.medium15,
    required this.medium16,
    required this.medium18,
    required this.medium20,
    required this.bold10,
    required this.bold11,
    required this.bold13,
    required this.bold14,
    required this.bold16,
  });

  /// Base app text theme.
  AppTextTheme.base()
      : regular11 = AppTextStyle.regular11.value,
        regular12 = AppTextStyle.regular12.value,
        regular13 = AppTextStyle.regular13.value,
        regular14 = AppTextStyle.regular14.value,
        regular15 = AppTextStyle.regular15.value,
        regular16 = AppTextStyle.regular16.value,
        regular18 = AppTextStyle.regular18.value,
        regular20 = AppTextStyle.regular20.value,
        medium11 = AppTextStyle.medium11.value,
        medium12 = AppTextStyle.medium12.value,
        medium13 = AppTextStyle.medium13.value,
        medium14 = AppTextStyle.medium14.value,
        medium15 = AppTextStyle.medium15.value,
        medium16 = AppTextStyle.medium16.value,
        medium18 = AppTextStyle.medium18.value,
        medium20 = AppTextStyle.medium20.value,
        bold10 = AppTextStyle.bold10.value,
        bold11 = AppTextStyle.bold11.value,
        bold13 = AppTextStyle.bold13.value,
        bold14 = AppTextStyle.bold14.value,
        bold16 = AppTextStyle.bold16.value;

  /// Text style 11_140.
  final TextStyle regular11;

  /// Text style 12_140.
  final TextStyle regular12;

  /// Text style 13_140.
  final TextStyle regular13;

  /// Text style 14_140.
  final TextStyle regular14;

  /// Text style 15_140.
  final TextStyle regular15;

  /// Text style 16_124.
  final TextStyle regular16;

  /// Text style 18_124.
  final TextStyle regular18;

  /// Text style 20_124
  final TextStyle regular20;

  /// Text style 11_140.
  final TextStyle medium11;

  /// Text style 12_140.
  final TextStyle medium12;

  /// Text style 14_140_500.
  final TextStyle medium13;

  /// Text style 14_140_500.
  final TextStyle medium14;

  /// Text style 15_140_500.
  final TextStyle medium15;

  /// Text style 16_124_500.
  final TextStyle medium16;

  /// Text style 16_124_500.
  final TextStyle medium18;

  /// Text style 20_124_500.
  final TextStyle medium20;

  /// Text style 10_140_700.
  final TextStyle bold10;

  /// Text style 11_140_700.
  final TextStyle bold11;

  /// Text style 14_140_700.
  final TextStyle bold13;

  /// Text style 14_140_700.
  final TextStyle bold14;

  /// Text style 16_124_700.
  final TextStyle bold16;

  @override
  ThemeExtension<AppTextTheme> lerp(
    ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other is! AppTextTheme) {
      return this;
    }

    return copyWith(
      regular11: TextStyle.lerp(regular11, other.regular11, t),
      regular12: TextStyle.lerp(regular12, other.regular12, t),
      regular13: TextStyle.lerp(regular13, other.regular13, t),
      regular14: TextStyle.lerp(regular14, other.regular14, t),
      regular15: TextStyle.lerp(regular15, other.regular15, t),
      regular16: TextStyle.lerp(regular16, other.regular16, t),
      regular18: TextStyle.lerp(regular18, other.regular18, t),
      regular20: TextStyle.lerp(regular20, other.regular20, t),
      medium11: TextStyle.lerp(medium11, other.regular20, t),
      medium12: TextStyle.lerp(medium12, other.medium12, t),
      medium13: TextStyle.lerp(medium13, other.medium13, t),
      medium14: TextStyle.lerp(medium14, other.medium14, t),
      medium15: TextStyle.lerp(medium15, other.medium15, t),
      medium16: TextStyle.lerp(medium16, other.medium16, t),
      medium18: TextStyle.lerp(medium16, other.medium18, t),
      medium20: TextStyle.lerp(medium20, other.medium20, t),
      bold10: TextStyle.lerp(bold10, other.bold10, t),
      bold11: TextStyle.lerp(bold11, other.bold11, t),
      bold13: TextStyle.lerp(bold13, other.bold13, t),
      bold14: TextStyle.lerp(bold14, other.bold14, t),
      bold16: TextStyle.lerp(bold16, other.bold16, t),
    );
  }

  /// Return text theme for app from context
  static AppTextTheme of(BuildContext context) =>
      Theme.of(context).extension<AppTextTheme>() ?? _throwThemeExceptionFromFunc(context);

  /// @nodoc
  @override
  // ignore: long-parameter-list
  ThemeExtension<AppTextTheme> copyWith({
    TextStyle? regular11,
    TextStyle? regular12,
    TextStyle? regular13,
    TextStyle? regular14,
    TextStyle? regular15,
    TextStyle? regular16,
    TextStyle? regular18,
    TextStyle? regular20,
    TextStyle? medium11,
    TextStyle? medium12,
    TextStyle? medium13,
    TextStyle? medium14,
    TextStyle? medium15,
    TextStyle? medium16,
    TextStyle? medium18,
    TextStyle? medium20,
    TextStyle? bold10,
    TextStyle? bold11,
    TextStyle? bold13,
    TextStyle? bold14,
    TextStyle? bold16,
  }) =>
      AppTextTheme._(
        regular11: regular11 ?? this.regular11,
        regular12: regular12 ?? this.regular12,
        regular13: regular13 ?? this.regular13,
        regular14: regular14 ?? this.regular14,
        regular15: regular15 ?? this.regular15,
        regular16: regular16 ?? this.regular16,
        regular18: regular18 ?? this.regular18,
        regular20: regular20 ?? this.regular20,
        medium11: medium11 ?? this.medium11,
        medium12: medium12 ?? this.medium12,
        medium13: medium13 ?? this.medium13,
        medium14: medium14 ?? this.medium14,
        medium15: medium15 ?? this.medium15,
        medium16: medium16 ?? this.medium16,
        medium18: medium18 ?? this.medium18,
        medium20: medium20 ?? this.medium20,
        bold10: bold10 ?? this.bold10,
        bold11: bold11 ?? this.bold11,
        bold13: bold13 ?? this.bold13,
        bold14: bold14 ?? this.bold14,
        bold16: bold16 ?? this.bold16,
      );
}

Never _throwThemeExceptionFromFunc(BuildContext context) => throw Exception('$AppTextTheme не найдена в $context');
