import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template MainStackScreen.class}
/// MainStackScreen widget.
/// {@endtemplate}
@RoutePage()
class MainStackScreen extends StatelessWidget {
  /// {@macro MainStackScreen.class}
  const MainStackScreen({super.key});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
