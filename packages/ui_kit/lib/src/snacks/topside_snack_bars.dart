import 'package:flutter/material.dart';
import 'package:ui_kit/src/app_sizes.dart';

/// {@template TopSideSnackBars.class}
/// Снекбары, отображаемые с нижней стороны экрана, стилизованы по дизайну.
/// {@endtemplate}
abstract class BottomSideSnackBars {
  /// {@macro TopSideSnackBars.class}
  const BottomSideSnackBars._();

  static SnackBar success(BuildContext context, {required String message, VoidCallback? onTap}) {
    final colorScheme = ColorScheme.of(context);
    final backgroundColor = colorScheme.primaryContainer;
    final foregroundColor = colorScheme.onPrimaryContainer;

    return SnackBar(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      dismissDirection: DismissDirection.down,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.fixed,
      content: GestureDetector(
        onTap: onTap,
        child: _TypedSnackBarContent(
          icon: SizedBox.square(
            dimension: 24.0,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.5, color: foregroundColor)),
              child: Icon(Icons.done_outlined, color: foregroundColor, size: 15.0),
            ),
          ),
          message: message,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }

  static SnackBar error(BuildContext context, {required String titleText, VoidCallback? onTap}) {
    final colorScheme = ColorScheme.of(context);
    final backgroundColor = colorScheme.error;
    final foregroundColor = colorScheme.onError;

    return SnackBar(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
      dismissDirection: DismissDirection.down,
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.fixed,
      content: GestureDetector(
        onTap: onTap,
        child: _TypedSnackBarContent(
          icon: Icon(Icons.error_outline, color: foregroundColor, size: 24.0),
          message: titleText,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}

/// {@template _TypedSnackBarContent.class}
/// Основной виджет для размещения контента внутри снекбара
/// {@endtemplate}
class _TypedSnackBarContent extends StatelessWidget {
  /// {@macro _TypedSnackBarContent.class}
  const _TypedSnackBarContent({required this.icon, required this.message, required this.foregroundColor});

  final Widget icon;
  final String message;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      spacing: AppSizes.double16,
      children: [
        icon,
        Expanded(
          child: Text(
            message,
            style: textTheme.bodyMedium?.copyWith(color: foregroundColor),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
