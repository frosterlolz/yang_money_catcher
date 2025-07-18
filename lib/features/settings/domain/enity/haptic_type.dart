import 'package:flutter/services.dart';

enum HapticType { light, medium, heavy, selection, vibrate }

extension HapticTypeExt on HapticType {
  Future<void> play() async => switch (this) {
        HapticType.light => HapticFeedback.lightImpact,
        HapticType.medium => HapticFeedback.mediumImpact,
        HapticType.heavy => HapticFeedback.heavyImpact,
        HapticType.selection => HapticFeedback.selectionClick,
        HapticType.vibrate => HapticFeedback.vibrate,
      }
          .call();
}
