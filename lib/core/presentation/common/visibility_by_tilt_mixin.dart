import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';

mixin VisibilityByTiltMixin<T extends StatefulWidget> on State<T> {
  bool _isVisible = true;
  late final StreamSubscription<AccelerometerEvent> _accelerationSubscription;
  bool _toggleInProcessing = false;

  DateTime? _tiltTimestamp;

  bool get isVisible => _isVisible;

  @override
  void initState() {
    super.initState();
    _accelerationSubscription = accelerometerEventStream().listen(_onAccelerometer);
  }

  @override
  void dispose() {
    _accelerationSubscription.cancel();
    super.dispose();
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final z = event.z;

    if (z < -4.0 && !_toggleInProcessing) {
      _tiltTimestamp = event.timestamp;
      _toggleInProcessing = true;
    }
    if (z >= -1.0 && _toggleInProcessing) {
      final eventDifference = _tiltTimestamp?.difference(event.timestamp).abs();
      if (eventDifference != null && eventDifference.inSeconds < 1) {
        _toggleBalance();
      }
      _toggleInProcessing = false;
    }
  }

  void _toggleBalance() {
    context.read<SettingsBloc>().state.settings.hapticType.play();
    setState(() {
      _isVisible = !_isVisible;
    });
  }
}
