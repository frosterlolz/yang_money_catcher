import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/colors/color_palette.dart';

//ignore_for_file: member-ordering

/// App color scheme.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  /// Base light theme of the app.
  const AppColorScheme.light()
      : primary = ColorPalette.ufoGreen,
        onPrimary = ColorPalette.white,
        secondary = ColorPalette.aeroBlue,
        onSecondary = ColorPalette.appBarFgColor,
        inactiveSecondary = ColorPalette.brightGray,
        subtitle = ColorPalette.subtitleGrey,
        onSubtitle = ColorPalette.bodyTextGrey,
        grabber = ColorPalette.grabberGrey,
        dividerColor = ColorPalette.lavenderGray,
        surface = ColorPalette.antiFlashWhite,
        onSurface = ColorPalette.eerieBlack,
        background = ColorPalette.snow,
        onBackground = ColorPalette.eerieBlack,
        error = ColorPalette.terraCotta,
        onError = ColorPalette.white,
        selectedItem = ColorPalette.ufoGreen,
        unselectedItem = ColorPalette.eerieBlack,
        labelTertiary = ColorPalette.arsenic;

  /// Dark theme of the app.
  const AppColorScheme.dark()
      : primary = ColorPalette.ufoGreen,
        onPrimary = ColorPalette.darkGrey,
        secondary = ColorPalette.appBarFgColor,
        onSecondary = ColorPalette.white,
        inactiveSecondary = ColorPalette.brightGray,
        subtitle = ColorPalette.brightGray,
        onSubtitle = ColorPalette.bodyTextGrey,
        grabber = ColorPalette.grabberGrey,
        dividerColor = ColorPalette.lavenderGray,
        surface = ColorPalette.oxfordBlue,
        onSurface = ColorPalette.darkGrey,
        background = ColorPalette.jaguar,
        onBackground = ColorPalette.darkGrey,
        error = ColorPalette.terraCotta,
        onError = ColorPalette.white,
        selectedItem = ColorPalette.white,
        unselectedItem = ColorPalette.subtitleGrey,
        labelTertiary = ColorPalette.arsenic;

  const AppColorScheme._({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.inactiveSecondary,
    required this.subtitle,
    required this.onSubtitle,
    required this.grabber,
    required this.dividerColor,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.selectedItem,
    required this.unselectedItem,
    required this.labelTertiary,
  });

  /// The base color for app.
  final Color primary;

  /// The color of the elements that appears on top of a [primary].
  final Color onPrimary;

  /// A secondary color for the app.
  ///
  /// Can be used as an accent color for buttons, switches, labels, icons, etc.
  final Color secondary;

  /// The color of the elements that appears on top of a [secondary].
  final Color onSecondary;

  /// The color of inactive icon (in buttons/switchers... etc)
  final Color inactiveSecondary;

  /// The color of grabber and rating bar
  final Color grabber;

  /// The color of divider
  final Color dividerColor;

  /// The color of subtitle body text
  final Color subtitle;

  /// The color of on subtitle body text
  final Color onSubtitle;

  /// Surface colors affect surfaces of components, such as cards, sheets, and menus.
  final Color surface;

  /// The color of the elements that appears on top of a [surface].
  final Color onSurface;

  /// The background color appears behind scrollable content.
  final Color background;

  /// The color of the elements that appears on top of a [background].
  final Color onBackground;

  /// Color for show errors.
  final Color error;

  /// The color of the elements that appears on top of a [error].
  final Color onError;

  /// Color for show selected items.
  final Color selectedItem;

  /// Color for show unselected items.
  final Color unselectedItem;

  /// Color for some icons and labels
  final Color labelTertiary;

  @override
  ThemeExtension<AppColorScheme> lerp(
    ThemeExtension<AppColorScheme>? other,
    double t,
  ) {
    if (other is! AppColorScheme) return this;

    return copyWith(
      primary: Color.lerp(primary, other.primary, t),
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t),
      inactiveSecondary: Color.lerp(inactiveSecondary, other.inactiveSecondary, t),
      subtitle: Color.lerp(subtitle, other.subtitle, t),
      onSubtitle: Color.lerp(onSubtitle, other.onSubtitle, t),
      grabber: Color.lerp(grabber, other.grabber, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      surface: Color.lerp(surface, other.surface, t),
      onSurface: Color.lerp(onSurface, other.onSurface, t),
      background: Color.lerp(background, other.background, t),
      onBackground: Color.lerp(onBackground, other.onBackground, t),
      error: Color.lerp(error, other.error, t),
      onError: Color.lerp(onError, other.onError, t),
      selectedItem: Color.lerp(selectedItem, other.selectedItem, t),
      unselectedItem: Color.lerp(unselectedItem, other.unselectedItem, t),
      labelTertiary: Color.lerp(labelTertiary, other.labelTertiary, t),
    );
  }

  /// Return color scheme for app from context
  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorScheme>() ?? _throwThemeExceptionFromFunc(context);

  @override
  // ignore: long-parameter-list
  ThemeExtension<AppColorScheme> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? inactiveSecondary,
    Color? subtitle,
    Color? onSubtitle,
    Color? grabber,
    Color? dividerColor,
    Color? surface,
    Color? onSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? selectedItem,
    Color? unselectedItem,
    Color? labelTertiary,
  }) =>
      AppColorScheme._(
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        secondary: secondary ?? this.secondary,
        onSecondary: onSecondary ?? this.onSecondary,
        inactiveSecondary: inactiveSecondary ?? this.inactiveSecondary,
        subtitle: subtitle ?? this.subtitle,
        onSubtitle: onSubtitle ?? this.onSubtitle,
        grabber: grabber ?? this.grabber,
        dividerColor: dividerColor ?? this.dividerColor,
        surface: surface ?? this.surface,
        onSurface: onSurface ?? this.onSurface,
        background: background ?? this.background,
        onBackground: onBackground ?? this.onBackground,
        error: error ?? this.error,
        onError: onError ?? this.onError,
        selectedItem: selectedItem ?? this.selectedItem,
        unselectedItem: unselectedItem ?? this.unselectedItem,
        labelTertiary: labelTertiary ?? this.labelTertiary,
      );
}

Never _throwThemeExceptionFromFunc(BuildContext context) => throw Exception('$AppColorScheme не найдена в $context');
