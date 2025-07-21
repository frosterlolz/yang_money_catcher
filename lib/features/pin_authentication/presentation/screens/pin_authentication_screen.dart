import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_view.dart';
import 'package:yang_money_catcher/ui_kit/common/conditional_wrapper.dart';

enum PinAuthenticationReason { signIn, verifyAccess }

/// {@template PinAuthenticationScreen.class}
/// PinAuthenticationScreen widget.
/// {@endtemplate}
@RoutePage()
class PinAuthenticationScreen extends StatefulWidget {
  /// {@macro PinAuthenticationScreen.class}
  const PinAuthenticationScreen({super.key, this.reason = PinAuthenticationReason.signIn, this.onSuccess});

  /// Причина показа данного экрана
  final PinAuthenticationReason reason;

  final VoidCallback? onSuccess;

  @override
  State<PinAuthenticationScreen> createState() => _PinAuthenticationScreenState();
}

class _PinAuthenticationScreenState extends State<PinAuthenticationScreen> {
  String? _errorMessage;

  bool get _shouldApproveBiometric => switch (widget.reason) {
        PinAuthenticationReason.signIn => true,
        // Не даем пользоваться биометрией при запросе доступа к чувствительным настройкам
        PinAuthenticationReason.verifyAccess => false,
      };

  void _authenticationStateListener(BuildContext context, PinAuthenticationState state) {
    switch (state) {
      case PinAuthenticationState$Success():
        _setErrorMessage(null);
        widget.onSuccess?.call();
      case PinAuthenticationState$Processing():
        _setErrorMessage(null);
      case PinAuthenticationState$Idle():
        break;
      case PinAuthenticationState$Error(:final error):
        final message = switch (error) {
          PinException$Invalid() => context.l10n.pinIsIncorrect,
          _ => context.l10n.somethingWentWrong,
        };
        _setErrorMessage(message);
    }
  }

  void _setErrorMessage(String? v) {
    if (_errorMessage == v || !mounted) return;
    setState(() => _errorMessage = v);
  }

  Future<void> _onResetPin() async {
    context.read<PinAuthenticationBloc>().add(const PinAuthenticationEvent.resetPin());
  }

  void _onComplete(String pin, [bool? isBiometricVerified]) {
    if (isBiometricVerified != null) {
      _onBiometricComplete(isBiometricVerified);
      return;
    }
    switch (widget.reason) {
      case PinAuthenticationReason.signIn:
        context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.signIn(pin));
      case PinAuthenticationReason.verifyAccess:
        context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.verifyAccess(pin));
    }
  }

  Future<void> _onBiometricComplete(bool isSuccess) async {
    if (!isSuccess) {
      _setErrorMessage(context.l10n.biometricCheckFailed);
    }
    context.read<PinAuthenticationBloc>().add(
          switch (widget.reason) {
            PinAuthenticationReason.signIn => PinAuthenticationEvent.signIn('', forceWithBiometric: isSuccess),
            PinAuthenticationReason.verifyAccess =>
              PinAuthenticationEvent.verifyAccess('', forceWithBiometric: isSuccess),
          },
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<PinAuthenticationBloc, PinAuthenticationState>(
        listener: _authenticationStateListener,
        builder: (context, pinAuthState) => AbsorbPointer(
          absorbing: pinAuthState is PinAuthenticationState$Processing,
          child: ConditionalWrapper(
            condition: switch (widget.reason) {
              PinAuthenticationReason.signIn => true,
              PinAuthenticationReason.verifyAccess => false,
            },
            onAddWrapper: (child) => Material(child: child),
            child: PinInputView(
              title: context.l10n.enterPinCode,
              onComplete: _onComplete,
              shouldEnableBiometric: pinAuthState.shouldAllowBiometric && _shouldApproveBiometric,
              errorMessage: _errorMessage,
              pinLength: pinAuthState.pinLength,
              onResetPin: _onResetPin,
              shouldInitBiometricImmediately: true,
            ),
          ),
        ),
      );
}
