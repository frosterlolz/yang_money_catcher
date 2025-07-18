import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/screens/pin_authentication_screen.dart';

/// {@template PinSettingsVerificationScreen.class}
/// PinSettingsVerificationScreen widget.
/// {@endtemplate}
@RoutePage()
class PinSettingsVerificationScreen extends StatelessWidget {
  /// {@macro PinSettingsVerificationScreen.class}
  const PinSettingsVerificationScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) =>
      PinAuthenticationScreen(reason: PinAuthenticationReason.verifyAccess, onSuccess: onSuccess);
}
