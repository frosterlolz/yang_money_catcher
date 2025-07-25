import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

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
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android || defaultTargetPlatform != TargetPlatform.iOS) return;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _changeBlurVisibility(true);
      case AppLifecycleState.resumed:
        _changeBlurVisibility(false);
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _changeBlurVisibility(bool shouldShow) {
    final isPinAuthEnabled = context.read<PinAuthenticationBloc>().state.status != PinAuthenticationStatus.disabled;
    if (shouldShow == _shouldBlur || !isPinAuthEnabled || !mounted) return;
    setState(() => _shouldBlur = shouldShow);
  }

  @override
  Widget build(BuildContext context) => BlocSelector<PinAuthenticationBloc, PinAuthenticationState, bool>(
        selector: (state) => state.status != PinAuthenticationStatus.disabled,
        builder: (context, isPinAuthEnabled) => Stack(
          children: [
            widget.child,
            if (isPinAuthEnabled && _shouldBlur)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withValues(alpha: 0.1)),
                ),
              ),
          ],
        ),
      );
}
