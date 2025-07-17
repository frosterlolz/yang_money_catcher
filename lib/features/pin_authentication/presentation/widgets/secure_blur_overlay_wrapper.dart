import 'dart:ui';

import 'package:flutter/material.dart';

/// {@template SecureBlurOverlayWrapper.class}
/// SecureBlurOverlayWrapper widget.
/// {@endtemplate}
class SecureBlurOverlayWrapper extends StatefulWidget {
  /// {@macro SecureBlurOverlayWrapper.class}
  const SecureBlurOverlayWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<SecureBlurOverlayWrapper> createState() => _SecureBlurOverlayWrapperState();
}

class _SecureBlurOverlayWrapperState extends State<SecureBlurOverlayWrapper> with WidgetsBindingObserver {
  bool _shouldBlur = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        setState(() => _shouldBlur = true);
      case AppLifecycleState.resumed:
        setState(() => _shouldBlur = false);
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          if (_shouldBlur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),
        ],
      );
}
