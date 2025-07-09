import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pretty_chart/src/models/chart_item_data.dart';
import 'package:pretty_chart/src/utils/color_generator.dart';

const double _chartStrokeWidth = 8.0;
const double _innerDataPadding = 3.0;
const _animationDuration = Duration(milliseconds: 1000);

/// {@template AnimatedPieChart.class}
/// Виджет отображает анимированную диаграмму с круглыми секторами.
/// {@endtemplate}
class AnimatedPieChart extends StatefulWidget {
  /// {@macro AnimatedPieChart.class}
  const AnimatedPieChart(this.chartItems, {super.key, this.labelStyle, this.indicatorSize});

  final List<ChartItemData> chartItems;
  final double? indicatorSize;
  final TextStyle? labelStyle;

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin<AnimatedPieChart> {
  late List<ChartItemData> _currentChartItems;
  late final AnimationController _animationController;
  bool _hasUpdates = false;

  @override
  void initState() {
    super.initState();
    _currentChartItems = widget.chartItems;
    _animationController = AnimationController(vsync: this, duration: _animationDuration)
      ..addListener(_updateTransactionAnalysisData);
    WidgetsBinding.instance.addPostFrameCallback((_) => _doRotate());
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    final isListEquals = const ListEquality<ChartItemData>().equals(widget.chartItems, oldWidget.chartItems);
    if (!isListEquals) {
      _hasUpdates = true;
      _doRotate();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _doRotate() {
    _animationController
      ..reset()
      ..forward();
  }

  void _updateTransactionAnalysisData() {
    final currentValue = _animationController.value;
    if (currentValue < 0.5 || _currentChartItems == widget.chartItems) return;
    setState(() => _currentChartItems = widget.chartItems);
  }

  double _itemPercentage(ChartItemData item) {
    if (item.value == 0.0) return 0.0;

    return item.value / _currentChartItems.fold(0.0, (previousValue, element) => previousValue + element.value) * 100;
  }

  Color _getColor(int index) => ColorGenerator.getFixedColor(index);

  double _getChartOpacity() {
    if (!_hasUpdates) return 1.0;
    final value = _animationController.value;
    if (value <= 0.5) {
      return 1.0 - (value * 2);
    } else {
      return (value - 0.5) * 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double circleSize = MediaQuery.sizeOf(context).shortestSide * 0.4;
    final double squareSize = (circleSize - _chartStrokeWidth * 2) * 0.7071;
    final double offset = (circleSize - squareSize) / 2;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: SizedBox.square(
          dimension: circleSize,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Opacity(
                    opacity: _getChartOpacity(),
                    child: Transform.rotate(
                      angle: _animationController.value * 2 * math.pi,
                      child: child,
                    ),
                  ),
                  child: PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: null,
                      sections: List.generate(
                        _currentChartItems.length,
                        (index) {
                          final summaryItem = _currentChartItems[index];

                          return PieChartSectionData(
                            color: _getColor(index),
                            value: _itemPercentage(summaryItem),
                            showTitle: false,
                            radius: _chartStrokeWidth,
                          );
                        },
                      ),
                    ),
                    duration: Duration(milliseconds: (_animationDuration.inMilliseconds / 2).toInt()),
                  ),
                ),
              ),
              Positioned(
                left: offset,
                top: offset,
                width: squareSize,
                height: squareSize,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Opacity(opacity: _getChartOpacity(), child: child),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _innerDataPadding),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_currentChartItems.length, (index) {
                            final summaryItem = _currentChartItems[index];
                            return _Indicator(
                              key: ValueKey('Indicator at $index'),
                              color: _getColor(index),
                              text: '${_itemPercentage(summaryItem).toStringAsFixed(2)}% ${summaryItem.label}',
                              textStyle: widget.labelStyle ?? TextTheme.of(context).labelSmall?.copyWith(fontSize: 7.0),
                              size: widget.indicatorSize ?? 5.65,
                              isSquare: false,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textStyle,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
}
