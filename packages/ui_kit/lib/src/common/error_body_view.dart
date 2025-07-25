import 'package:flutter/material.dart';
import 'package:ui_kit/src/app_sizes.dart';
import 'package:ui_kit/src/layout/material_spacing.dart';

/// {@template ErrorBodyView.class}
/// Типовой виджет для отображения тела экрана с ошибкой
/// {@endtemplate}
class ErrorBodyView extends StatelessWidget {
  /// {@macro ErrorBodyView.class}
  const ErrorBodyView({
    super.key,
    required this.title,
    required this.description,
    required this.retryButtonText,
    required this.onRetryTap,
  });

  final String title;
  final String description;
  final String retryButtonText;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const HorizontalSpacing.compact(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.0,
          children: [
            const Spacer(),
            Text(title, textAlign: TextAlign.center, style: textTheme.titleMedium),
            Text(description, textAlign: TextAlign.center, style: textTheme.bodyMedium),
            const Spacer(),
            ElevatedButton(onPressed: onRetryTap, child: Text(retryButtonText)),
            const SizedBox(height: AppSizes.double10),
          ],
        ),
      ),
    );
  }
}
