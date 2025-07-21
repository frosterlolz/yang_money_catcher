import 'package:flutter/material.dart';

/// {@template TextConfirmDialog.class}
/// TextConfirmDialog widget.
/// {@endtemplate}
class TextConfirmDialog extends StatefulWidget {
  /// {@macro TextConfirmDialog.class}
  const TextConfirmDialog({
    super.key,
    required this.initialValue,
    required this.onConfirmTap,
    required this.title,
    required this.confirmButtonTitle,
    required this.cancelButtonTitle,
  });

  final String? initialValue;
  final ValueChanged<String> onConfirmTap;
  final String title;
  final String confirmButtonTitle;
  final String cancelButtonTitle;

  @override
  State<TextConfirmDialog> createState() => _TextConfirmDialogState();
}

class _TextConfirmDialogState extends State<TextConfirmDialog> {
  late String _value;

  bool get _isValuesEqual => _value.trim() == widget.initialValue?.trim();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? '';
  }

  void _onChanged(String v) {
    if (v.trim() == _value.trim()) return;
    setState(() => _value = v);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: TextFormField(onChanged: _onChanged, initialValue: _value),
        actions: [
          TextButton(
            onPressed: _isValuesEqual ? null : () => widget.onConfirmTap.call(_value),
            child: Text(widget.confirmButtonTitle),
          ),
          TextButton(onPressed: Navigator.of(context).maybePop, child: Text(widget.cancelButtonTitle)),
        ],
      );
}
