import 'package:flutter/material.dart';
import 'package:ui_kit/src/text/text_style.dart';

/// {@template AppText.class}
/// All text implementations extends Theme of App
/// {@endtemplate}
class AppText extends StatelessWidget {
  /// {@macro AppText.class}
  const AppText(
    this.text,
    this.style, {
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
    super.key,
  });

  /// {@macro AppText.class}
  const AppText.displayLarge(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.displayLarge;

  /// {@macro AppText.class}
  const AppText.displayMedium(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.displayMedium;

  /// {@macro AppText.class}
  const AppText.displaySmall(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.displaySmall;

  /// {@macro AppText.class}
  const AppText.headlineLarge(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.headlineLarge;

  /// {@macro AppText.class}
  const AppText.headlineMedium(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.headlineMedium;

  /// {@macro AppText.class}
  const AppText.headlineSmall(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.headlineSmall;

  /// {@macro AppText.class}
  const AppText.titleLarge(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.titleLarge;

  /// {@macro AppText.class}
  const AppText.titleMedium(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.titleMedium;

  /// {@macro AppText.class}
  const AppText.titleSmall(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.titleSmall;

  /// {@macro AppText.class}
  const AppText.labelLarge(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.labelLarge;

  /// {@macro AppText.class}
  const AppText.labelMedium(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.labelMedium;

  /// {@macro AppText.class}
  const AppText.labelSmall(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.labelSmall;

  /// {@macro AppText.class}
  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.bodyLarge;

  /// {@macro AppText.class}
  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.bodyMedium;

  /// {@macro AppText.class}
  const AppText.bodySmall(
    this.text, {
    super.key,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
  }) : style = AppTextStyle.bodySmall;

  /// {@macro AppText.class}
  final String text;
  final AppTextStyle style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool? softWrap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        text,
        softWrap: softWrap,
        overflow: overflow,
        maxLines: maxLines,
        textAlign: textAlign,
        style: style.value,
        key: key,
      );
}
