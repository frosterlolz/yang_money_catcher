import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterX on WidgetTester {
  Future<Finder> asyncFinder({
    required Finder Function() finder,
    Duration limit = const Duration(seconds: 10),
    bool isEmptyFinder = false,
  }) async {
    final stopWatch = Stopwatch()..start();
    try {
      var res = finder();
      while (stopWatch.elapsed <= limit) {
        await pumpAndSettle(const Duration(milliseconds: 100));
        res = finder();
        final condition = isEmptyFinder ? res.evaluate().isEmpty : res.evaluate().isNotEmpty;
        if (condition) return res;
      }
      return res;
    } finally {
      stopWatch.stop();
    }
  }
}
