import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

/// {@template PinInputField.class}
/// PinInputField widget.
/// {@endtemplate}
class PinInputField extends StatefulWidget {
  /// {@macro PinInputField.class}
  const PinInputField({
    super.key,
    required this.pinLength,
    required this.filledLength,
    required this.isError,
    required this.errorAnimationDuration,
  });

  final Duration errorAnimationDuration;
  final int pinLength;
  final int filledLength;
  final bool isError;

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;
  Color? _radioColor;

  bool _isSelected(int index) => index < widget.filledLength;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.errorAnimationDuration,
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    final color = ColorScheme.of(context).primary;
    _changeRadioColor(color);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant PinInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      _triggerVerification(widget.isError);
    }
    if (widget.errorAnimationDuration != oldWidget.errorAnimationDuration) {
      _controller.duration = widget.errorAnimationDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeRadioColor(Color v) {
    if (_radioColor == v || !mounted) return;
    setState(() => _radioColor = v);
  }

  Future<void> _triggerVerification(bool isError) async {
    final colorScheme = ColorScheme.of(context);
    final errorColor = colorScheme.error;
    final primaryColor = colorScheme.primary;
    _changeRadioColor(errorColor);
    await _controller.forward(from: 0);
    _changeRadioColor(primaryColor);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _offsetAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.pinLength,
            (index) => Radio(
              value: _isSelected(index),
              groupValue: true,
              onChanged: null,
              fillColor: WidgetStatePropertyAll(_radioColor ?? AppColorScheme.of(context).primary),
            ),
          ),
        ),
      );
}
