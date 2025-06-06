import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/initialization/domain/entity/dependencies.dart';

class DependenciesScope extends InheritedWidget {
  const DependenciesScope({
    required super.child,
    required this.dependencies,
    super.key,
  });

  /// Container with dependencies.
  final Dependencies dependencies;

  /// Get the dependencies from the [context].
  static Dependencies of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DependenciesScope>()?.dependencies ??
      (throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a $Dependencies of the exact type',
        'out_of_scope',
      ));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Dependencies>('dependencies', dependencies),
    );
  }

  @override
  bool updateShouldNotify(DependenciesScope oldWidget) => false;
}
