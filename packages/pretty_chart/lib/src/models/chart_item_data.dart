import 'package:flutter/cupertino.dart';

@immutable
class ChartItemData {
  const ChartItemData({
    required this.id,
    required this.value,
    required this.label,
  });

  final int id;
  final double value;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartItemData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          label == other.label;

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ label.hashCode;
}
