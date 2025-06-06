import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template AccountScreen.class}
/// Экран отображения баланса, валюты, а также движений по счету
/// {@endtemplate}
@RoutePage()
class AccountScreen extends StatelessWidget {
  /// {@macro AccountScreen.class}
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Счет'));
}
