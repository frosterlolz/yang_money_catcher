import 'dart:ui' show Color;

extension ColorX on Color {
  int toARGB32() => _floatToInt8(a) << 24 | _floatToInt8(r) << 16 | _floatToInt8(g) << 8 | _floatToInt8(b) << 0;

  static int _floatToInt8(double x) => (x * 255.0).round() & 0xff;
}
