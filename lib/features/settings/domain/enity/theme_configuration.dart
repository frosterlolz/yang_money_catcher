import 'package:flutter/material.dart' show Color, ThemeMode, immutable;

@immutable
class ThemeConfiguration {
  const ThemeConfiguration({
    required this.themeMode,
    required this.seedColor,
  });

  final ThemeMode themeMode;
  final Color seedColor;

  ThemeConfiguration copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
  }) =>
      ThemeConfiguration(
        themeMode: themeMode ?? this.themeMode,
        seedColor: seedColor ?? this.seedColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeConfiguration &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          seedColor == other.seedColor;

  @override
  int get hashCode => themeMode.hashCode ^ seedColor.hashCode;
}
