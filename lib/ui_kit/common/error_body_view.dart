import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';

/// {@template ErrorBodyView.class}
/// Типовой виджет для отображения тела экрана с ошибкой
/// {@endtemplate}
class ErrorBodyView extends StatelessWidget {
  /// {@macro ErrorBodyView.class}
  const ErrorBodyView({
    super.key,
    this.title,
    this.description,
    required this.onRetryTap,
  });

  factory ErrorBodyView.fromError(Object error, {required VoidCallback onRetryTap}) {
    // TODO(frosterlolz): описать текст ошибок под разные виды исключений
    final String? errorText = switch (error) {
      _ => null,
    };
    return ErrorBodyView(
      title: errorText,
      description: null,
      onRetryTap: onRetryTap,
    );
  }

  final String? title;
  final String? description;
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
            Text(title ?? context.l10n.somethingWentWrong, textAlign: TextAlign.center, style: textTheme.titleMedium),
            Text(description ?? context.l10n.tryItAgain, textAlign: TextAlign.center, style: textTheme.bodyMedium),
            const Spacer(),
            ElevatedButton(onPressed: onRetryTap, child: Text(context.l10n.retry)),
            const SizedBox(height: AppSizes.double10),
          ],
        ),
      ),
    );
  }
}
