import 'package:flutter/cupertino.dart';

@immutable
class ChartItemData {
  const ChartItemData({
    required this.id,
    required this.value,
    required this.label,
    this.tooltipLabel,
  });

  final int id;
  final double value;
  final String label;
  final String? tooltipLabel;

  bool get isNegative => value < 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartItemData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          label == other.label &&
          tooltipLabel == other.tooltipLabel;

  @override
  int get hashCode => Object.hash(id, value, label, tooltipLabel);

  ChartItemData copyWith({
    int? id,
    double? value,
    String? label,
    String? tooltipLabel,
  }) =>
      ChartItemData(
        id: id ?? this.id,
        value: value ?? this.value,
        label: label ?? this.label,
        tooltipLabel: tooltipLabel ?? this.tooltipLabel,
      );
}
