import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';

Future<T?> showItemSelectorModalBottomSheet<T>(
  BuildContext context, {
  String? titleText,
  required Widget body,
}) =>
    showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.double16))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (context) => _ItemSelectorSheet(body),
    );

/// {@template _ItemSelectorSheet.class}
/// Типизированный боттомшит, предназначенный для отображения списка элементов
/// {@endtemplate}
class _ItemSelectorSheet extends StatelessWidget {
  /// {@macro _ItemSelectorSheet.class}
  const _ItemSelectorSheet(this.body);

  final Widget body;

  // TODO(frosterlolz): актуализировать дизайн
  @override
  Widget build(BuildContext context) => body;
}
