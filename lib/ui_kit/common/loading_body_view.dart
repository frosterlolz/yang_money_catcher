import 'package:flutter/material.dart';

/// {@template LoadingBodyView.class}
/// Типовой виджет для отображения тела экрана с загрузкой
/// {@endtemplate}
class LoadingBodyView extends StatelessWidget {
  /// {@macro LoadingBodyView.class}
  const LoadingBodyView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
