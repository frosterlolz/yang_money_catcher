import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:yang_money_catcher/core/assets/res/app_images.dart';

const _double300 = 300.0;
const _double500 = 500.0;
const _maxImageHeight = 80.0;

void main() {
  testGoldens('Images golden test', (tester) async {
    await loadAppFonts();
    final builder = GoldenBuilder.column(
      wrap: (child) => Align(alignment: Alignment.centerLeft, child: child),
    );

    for (final imagePath in AppImages.values) {
      builder.addScenario(
        imagePath,
        Image.asset(imagePath, fit: BoxFit.contain, height: _maxImageHeight),
      );
    }

    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(),
      surfaceSize: Size(_double500, AppImages.values.length * _double300),
    );

    await screenMatchesGolden(tester, 'images');
  });
}
