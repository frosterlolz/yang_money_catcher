import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/core/utils/extensions/num_x.dart';
import 'package:yang_money_catcher/features/transactions/presentation/models/transactions_analysis_summery.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';

const double _chartStrokeWidth = 8.0;
const _animationDuration = Duration(milliseconds: 1000);

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

/// {@template TransactionsAnalyzePieChart.class}
/// TransactionsAnalyzePieChart widget.
/// {@endtemplate}
class TransactionsAnalyzePieChart extends StatefulWidget {
  /// {@macro TransactionsAnalyzePieChart.class}
  const TransactionsAnalyzePieChart(this.transactionAnalysisSummery, {super.key});

  final TransactionsAnalysisSummery transactionAnalysisSummery;

  @override
  State<TransactionsAnalyzePieChart> createState() => _TransactionsAnalyzePieChartState();
}

class _TransactionsAnalyzePieChartState extends State<TransactionsAnalyzePieChart>
    with SingleTickerProviderStateMixin<TransactionsAnalyzePieChart> {
  late TransactionsAnalysisSummery _currentTransactionAnalysisSummery;
  late final AnimationController _animationController;
  bool _hasUpdates = false;

  @override
  void initState() {
    super.initState();
    _currentTransactionAnalysisSummery = widget.transactionAnalysisSummery;
    _animationController = AnimationController(vsync: this, duration: _animationDuration)
      ..addListener(_updateTransactionAnalysisData);
    WidgetsBinding.instance.addPostFrameCallback((_) => _doRotate());
  }

  @override
  void didUpdateWidget(covariant TransactionsAnalyzePieChart oldWidget) {
    if (oldWidget.transactionAnalysisSummery != widget.transactionAnalysisSummery) {
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
    if (currentValue < 0.5 || _currentTransactionAnalysisSummery == widget.transactionAnalysisSummery) return;
    setState(() => _currentTransactionAnalysisSummery = widget.transactionAnalysisSummery);
  }

  Color _getColor(int index) => _chartColors[index % _chartColors.length];

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
      padding: const EdgeInsets.all(AppSizes.double20),
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
                        _currentTransactionAnalysisSummery.items.length,
                        (index) {
                          final summeryItem = _currentTransactionAnalysisSummery.items[index];

                          return PieChartSectionData(
                            color: _getColor(index),
                            value: _currentTransactionAnalysisSummery.amountPercentage(summeryItem.transactionCategory),
                            showTitle: false,
                            radius: _chartStrokeWidth,
                          );
                        },
                      ),
                    ),
                    duration: Duration(milliseconds: (_animationDuration.inMilliseconds/2).toInt()),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.double3),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.transactionAnalysisSummery.items.length, (index) {
                          final summeryItem = widget.transactionAnalysisSummery.items[index];
                          return Indicator(
                            color: _getColor(index),
                            text:
                                '${widget.transactionAnalysisSummery.amountPercentage(summeryItem.transactionCategory).smartTruncate()}% ${summeryItem.transactionCategory.name}',
                            textStyle: TextTheme.of(context).labelSmall?.copyWith(fontSize: AppSizes.double7),
                            size: 5.65,
                            isSquare: false,
                          );
                        }),
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

class Indicator extends StatelessWidget {
  const Indicator({
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
