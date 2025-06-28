import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

/// {@template TransactionsHistoryScreen.class}
/// TransactionsHistoryScreen widget.
/// {@endtemplate}
@RoutePage()
class TransactionsHistoryScreen extends StatelessWidget {
  /// {@macro TransactionsHistoryScreen.class}
  const TransactionsHistoryScreen({super.key, required this.isIncome});

  final bool isIncome;

  @override
  Widget build(BuildContext context) => const Placeholder();
}
