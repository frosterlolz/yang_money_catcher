import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:yang_money_catcher/ui_kit/buttons/calendar_segmented_button.dart';

const _double300 = 300.0;
const _double500 = 500.0;

void main() {
  testGoldens('CalendarSegmentedButton golden', (tester) async {
    await loadAppFonts();
    final builder = GoldenBuilder.column(
      wrap: (child) => Center(child: child),
    );

    for (final value in CalendarValues.values) {
      builder.addScenario(
        'selected: ${value.name}',
        CalendarSegmentedButton(
          selected: value,
          values: CalendarValues.values,
          onChanged: (_) {},
          titleBuilder: (v) => v.name.toUpperCase(),
        ),
      );
    }

    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(),
      surfaceSize: Size(_double500, CalendarValues.values.length * _double300),
    );

    await screenMatchesGolden(tester, 'calendar_segmented_button');
  });
}
