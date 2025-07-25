import 'package:flutter/material.dart';
import 'package:ui_kit/src/colors/colors.dart';

/// {@template ColorSchemeScreen.class}
/// ColorSchemeScreen widget.
/// {@endtemplate}
class ColorSchemeScreen extends StatelessWidget {
  /// {@macro ColorSchemeScreen.class}
  const ColorSchemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final appColorScheme = AppColorScheme.of(context);

    final Map<String, Color> colors = {
      '[ext]primaryDefault': appColorScheme.primary,
      '[ext]secondaryDefault': appColorScheme.secondary,
      '[ext]background': appColorScheme.background,
      'primary': colorScheme.primary,
      'onPrimary': colorScheme.onPrimary,
      'primaryContainer': colorScheme.primaryContainer,
      'onPrimaryContainer': colorScheme.onPrimaryContainer,
      'secondary': colorScheme.secondary,
      'onSecondary': colorScheme.onSecondary,
      'secondaryContainer': colorScheme.secondaryContainer,
      'onSecondaryContainer': colorScheme.onSecondaryContainer,
      'tertiary': colorScheme.tertiary,
      'onTertiary': colorScheme.onTertiary,
      'tertiaryContainer': colorScheme.tertiaryContainer,
      'onTertiaryContainer': colorScheme.onTertiaryContainer,
      'error': colorScheme.error,
      'onError': colorScheme.onError,
      'errorContainer': colorScheme.errorContainer,
      'onErrorContainer': colorScheme.onErrorContainer,
      'surface': colorScheme.surface,
      'onSurface': colorScheme.onSurface,
      'surfaceVariant': colorScheme.surfaceContainerHighest,
      'onSurfaceVariant': colorScheme.onSurfaceVariant,
      'outline': colorScheme.outline,
      'outlineVariant': colorScheme.outlineVariant,
      'shadow': colorScheme.shadow,
      'scrim': colorScheme.scrim,
      'inverseSurface': colorScheme.inverseSurface,
      'onInverseSurface': colorScheme.onInverseSurface,
      'inversePrimary': colorScheme.inversePrimary,
      'surfaceTint': colorScheme.surfaceTint,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorPalette Screen'),
      ),
      body: ListView.builder(
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final entry = colors.entries.toList()[index];
          return ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: entry.value,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(entry.key),
            trailing: Text('#${entry.value.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}'),
          );
        },
      ),
    );
  }
}
