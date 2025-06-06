import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// {@template BalanceScreen.class}
/// Экран отображения баланса, валюты, а также движений по счету
/// {@endtemplate}
@RoutePage()
class BalanceScreen extends StatelessWidget {
  /// {@macro BalanceScreen.class}
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: Text('Счет'));
}
