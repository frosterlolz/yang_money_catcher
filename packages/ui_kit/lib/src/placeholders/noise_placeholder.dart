import 'dart:math';

import 'package:flutter/material.dart';

/// {@template NoisePlaceholder.class}
/// NoisePlaceholder widget.
/// {@endtemplate}
class NoisePlaceholder extends StatefulWidget {
  /// {@macro NoisePlaceholder.class}
  const NoisePlaceholder({super.key, this.size});

  final Size? size;

  @override
  State<NoisePlaceholder> createState() => _NoisePlaceholderState();
}

class _NoisePlaceholderState extends State<NoisePlaceholder> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<int> _noiseValues;
  static const int noiseCount = 200;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _noiseValues = List.generate(noiseCount, (_) => _random.nextInt(256));
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(_updateNoise)
      ..repeat();
  }

  void _updateNoise() {
    for (int i = 0; i < noiseCount; i++) {
      final int change = _random.nextInt(20) - 10;
      final int newVal = (_noiseValues[i] + change).clamp(0, 255);
      _noiseValues[i] = newVal;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(
          painter: _NoisePainter(_noiseValues),
          size: widget.size ?? const Size(double.infinity, 30),
        ),
      );
}

class _NoisePainter extends CustomPainter {
  _NoisePainter(this.noiseValues);

  final List<int> noiseValues;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pointCount = noiseValues.length;
    final spacing = size.width / pointCount;

    for (int i = 0; i < pointCount; i++) {
      final alpha = noiseValues[i];
      paint.color = Colors.grey.withAlpha(alpha);
      final x = spacing * i;
      final y = size.height / 2;

      // Рисуем вертикальную линию или маленькую точку
      canvas.drawLine(Offset(x, y - 10), Offset(x, y + 10), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => true;
}
