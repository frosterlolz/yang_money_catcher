import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template SettingsScreen.class}
/// Экран отображения настроек
/// {@endtemplate}
@RoutePage()
class SettingsScreen extends StatelessWidget {
  /// {@macro SettingsScreen.class}
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Настройки'));
}
