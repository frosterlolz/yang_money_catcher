import 'package:flutter/material.dart';

abstract class ColorGenerator {
  /// Позволяет получить один из предустановленных цветов
  /// !!! Важно: цветов ограниченное количество, при передаче индекса
  /// выходящего за пределы списка будет взят цвет по "следующему кругу"
  static Color getFixedColor(int index) => _chartColors[index % _chartColors.length];
}

const List<Color> _chartColors = [
  Color(0xFF4CAF50), // зелёный
  Color(0xFFFF9800), // оранжевый
  Color(0xFF2196F3), // синий
  Color(0xFFE91E63), // розовый
  Color(0xFFFFEB3B), // жёлтый
  Color(0xFF9C27B0), // фиолетовый
  Color(0xFF00BCD4), // бирюзовый
  Color(0xFF795548), // коричневый
];
