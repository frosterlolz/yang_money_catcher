import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pretty_chart/pretty_chart.dart';
import 'package:pretty_chart/src/utils/color_generator.dart';

typedef ColorBuilder = Color Function(ChartItemData item);

/// {@template AnimatedBarChart.class}
/// AnimatedBarChart widget.
/// {@endtemplate}
class AnimatedBarChart extends StatefulWidget {
  /// {@macro AnimatedBarChart.class}
  const AnimatedBarChart(this.items, {this.labelStyle, super.key, this.columnColorBuilder});

  final List<ChartItemData> items;
  final TextStyle? labelStyle;
  final ColorBuilder? columnColorBuilder;

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.blueGrey,
                            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final itemTooltipLabel = widget.items[groupIndex].tooltipLabel;
                              if (itemTooltipLabel == null) return null;
                              return BarTooltipItem(
                                itemTooltipLabel,
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              );
                            },
                          ),
                          touchCallback: (FlTouchEvent event, barTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  barTouchResponse == null ||
                                  barTouchResponse.spot == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                            });
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => SideTitleWidget(
                                meta: meta,
                                space: 4.0,
                                child: Text(
                                  widget.items[value.toInt()].label,
                                  style: widget.labelStyle ?? const TextStyle(color: Colors.black, fontSize: 9),
                                ),
                              ),
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(widget.items.length, (index) {
                          final item = widget.items[index];
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                fromY: item.value.abs(),
                                toY: 0,
                                color: widget.columnColorBuilder?.call(item) ?? ColorGenerator.getFixedColor(index),
                                width: 6.0,
                                borderSide: BorderSide.none,
                              ),
                            ],
                          );
                        }),
                        gridData: const FlGridData(show: false),
                      ),
                      duration: animDuration,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
