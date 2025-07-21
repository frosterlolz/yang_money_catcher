import 'package:flutter/material.dart';
import 'package:ui_kit/src/app_sizes.dart';

/// {@template TypedProgressIndicator.class}
/// Cконфигурированный прогресс индикатор
/// Чаще всего используется для отображения состояния процесса на кнопках
/// {@endtemplate}
class TypedProgressIndicator extends StatelessWidget {
  /// {@macro TypedProgressIndicator.class}
  const TypedProgressIndicator({
    super.key,
    this.dimension,
    this.strokeWidth,
    this.isCentered = true,
    this.indicatorColor,
  });

  const TypedProgressIndicator.small({
    super.key,
    this.dimension = AppSizes.double20,
    this.strokeWidth = AppSizes.double3,
    this.isCentered = true,
    this.indicatorColor,
  });

  final double? dimension;
  final double? strokeWidth;
  final bool isCentered;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox.square(
      dimension: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? AppSizes.double4,
        color: indicatorColor,
        value: null,
      ),
    );
    return isCentered ? Center(child: indicator) : indicator;
  }
}
