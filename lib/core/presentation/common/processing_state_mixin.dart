import 'package:flutter/material.dart';

typedef ProcessingCallback = Future<void> Function();

mixin ProcessingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void _setProcessing(bool value) {
    if (_isProcessing == value || !mounted) return;
    setState(() {
      _isProcessing = value;
    });
  }

  Future<void> doProcessing(ProcessingCallback onProcessing) async {
    try {
      _setProcessing(true);
      await onProcessing();
    } finally {
      _setProcessing(false);
    }
  }
}
