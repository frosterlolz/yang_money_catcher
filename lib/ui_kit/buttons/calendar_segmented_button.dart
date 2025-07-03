import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

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
  });

  final CalendarValues selected;
  final List<CalendarValues> values;
  final ValueChanged<CalendarValues> onChanged;

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
                label: Text(context.l10n.selectByCalendarValue(calendarValue.name)),
                icon: const Icon(Icons.done, color: Colors.transparent),
              ),
            )
            .toList(),
        selectedIcon: const Icon(Icons.done),
        selected: {selected},
        onSelectionChanged: _onSelectionChanged,
      );
}
