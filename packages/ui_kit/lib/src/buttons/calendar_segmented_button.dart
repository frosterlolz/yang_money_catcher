import 'package:flutter/material.dart';

enum CalendarValues { day, week, month, year }

/// {@template CalendarSegmentedButton.class}
/// CalendarSegmentedButton widget.
/// {@endtemplate}
class CalendarSegmentedButton extends StatelessWidget {
  /// {@macro CalendarSegmentedButton.class}
  const CalendarSegmentedButton({
    super.key,
    required this.selected,
    required this.values,
    required this.onChanged,
    required this.titleBuilder,
  });

  final CalendarValues selected;
  final List<CalendarValues> values;
  final ValueChanged<CalendarValues> onChanged;
  final String Function(CalendarValues value) titleBuilder;

  void _onSelectionChanged(Set<CalendarValues> calendarValues) {
    final selectedValue = calendarValues.firstOrNull;
    if (selectedValue == null || selectedValue == selected) return;
    onChanged(selectedValue);
  }

  @override
  Widget build(BuildContext context) => SegmentedButton(
        segments: values
            .map(
              (calendarValue) => ButtonSegment(
                value: calendarValue,
                label: Text(titleBuilder.call(calendarValue)),
                icon: const Icon(Icons.done, color: Colors.transparent),
              ),
            )
            .toList(),
        selectedIcon: const Icon(Icons.done),
        selected: {selected},
        onSelectionChanged: _onSelectionChanged,
      );
}
