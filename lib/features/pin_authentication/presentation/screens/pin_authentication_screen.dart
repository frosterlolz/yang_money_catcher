import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/service/local_auth_service.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_field.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_keyboard.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/common/conditional_wrapper.dart';

const _pinLength = 4;
const _errorAnimationDuration = Duration(milliseconds: 400);

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
  String _pin = '';
  String? _errorMessage;

  late final LocalAuthService _localAuthService;

  bool get _shouldApproveBiometric => switch (widget.reason) {
        PinAuthenticationReason.signIn => true,
        // Не даем пользоваться биометрией при запросе доступа к чувствительным настройкам
        PinAuthenticationReason.verifyAccess => false,
      };

  @override
  void initState() {
    super.initState();
    _localAuthService = LocalAuthService();
    _initBiometricAuthentication();
  }

  Future<void> _initBiometricAuthentication() async {
    if (!_shouldApproveBiometric) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isBiometricEnabled =
          context.read<PinAuthenticationBloc>().state.biometricPreference != BiometricPreference.disabled;
      if (!isBiometricEnabled) return;
      _onBiometricTap();
    });
  }

  void _authenticationStateListener(BuildContext context, PinAuthenticationState state) {
    switch (state) {
      case PinAuthenticationState$Success():
        widget.onSuccess?.call();
      case PinAuthenticationState$Processing():
      case PinAuthenticationState$Idle():
        break;
      case PinAuthenticationState$Error(:final error):
        final message = switch (error) {
          PinException$Invalid() => context.l10n.pinIsIncorrect,
          _ => context.l10n.somethingWentWrong,
        };
        _onCompleteError(message);
    }
  }

  void _onKeyTap(String v) {
    final nextPin = _pin + v.trim();
    final isCompleted = _changePin(nextPin);
    if (!isCompleted) return;
    switch (widget.reason) {
      case PinAuthenticationReason.signIn:
        context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.signIn(_pin));
      case PinAuthenticationReason.verifyAccess:
        context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.verifyAccess(_pin));
    }
  }

  void _onDelTap() {
    if (_pin.isEmpty) return;
    final nextPin = _pin.substring(0, _pin.length - 1);
    _changePin(nextPin);
  }

  Future<void> _onBiometricTap() async {
    final isBiometricAvailable = await _localAuthService.checkBiometricsAvailability();
    if (!isBiometricAvailable || !mounted) return;
    final reasonMessage = switch (widget.reason) {
      PinAuthenticationReason.signIn => context.l10n.biometricReasonSignIn,
      PinAuthenticationReason.verifyAccess => context.l10n.biometricReasonVerifyAccess,
    };
    final isVerified = await _localAuthService.authenticate(reasonMessage);
    _changePin('****');
    if (mounted && !isVerified) {
      await _onCompleteError(context.l10n.biometricCheckFailed);
      return;
    }
    if (!mounted || !isVerified) return;
    context.read<PinAuthenticationBloc>().add(
          switch (widget.reason) {
            PinAuthenticationReason.signIn => PinAuthenticationEvent.signIn('', forceWithBiometric: isVerified),
            PinAuthenticationReason.verifyAccess =>
              PinAuthenticationEvent.verifyAccess('', forceWithBiometric: isVerified),
          },
        );
  }

  Future<void> _onCompleteError(String message) async {
    _setErrorMessage(message);
    await Future<void>.delayed(_errorAnimationDuration);
    _changePin('');
  }

  bool _changePin(String v) {
    if (_pin == v || v.length > _pinLength || !mounted) return false;
    setState(() => _pin = v.trim());
    if (_pin.isNotEmpty && _pin.length < _pinLength) {
      _setErrorMessage(null);
    }
    return _pin.length == _pinLength;
  }

  void _setErrorMessage(String? v) {
    if (_errorMessage == v || !mounted) return;
    setState(() => _errorMessage = v);
  }

  Future<void> _onResetPin() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.areYouSure),
        content: Text(context.l10n.resetPinDescriptionDemo),
        actions: [
          TextButton(onPressed: () => context.maybePop(false), child: Text(context.l10n.no)),
          TextButton(
            onPressed: () => context.maybePop(true),
            child: Text(
              context.l10n.yes,
              style: TextTheme.of(context).bodyMedium?.copyWith(color: ColorScheme.of(context).error),
            ),
          ),
        ],
      ),
    );
    if (res != true || !mounted) return;
    context.read<PinAuthenticationBloc>().add(const PinAuthenticationEvent.resetPin());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);

    return BlocConsumer<PinAuthenticationBloc, PinAuthenticationState>(
      listener: _authenticationStateListener,
      builder: (context, pinAuthState) => AbsorbPointer(
        absorbing: pinAuthState is PinAuthenticationState$Processing,
        child: ConditionalWrapper(
          condition: switch (widget.reason) {
            PinAuthenticationReason.signIn => true,
            PinAuthenticationReason.verifyAccess => false,
          },
          onAddWrapper: (child) => Material(child: child),
          child: Column(
            children: [
              // pin input
              const Spacer(),
              Text(context.l10n.enterPinCode, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
              PinInputField(
                pinLength: _pinLength,
                filledLength: _pin.length,
                isError: _errorMessage != null,
                errorAnimationDuration: _errorAnimationDuration,
              ),
              Text(_errorMessage ?? '', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
              const Spacer(),
              TextButton(onPressed: _onResetPin, child: Text(context.l10n.resetPin)),
              // keyboard
              BlocSelector<PinAuthenticationBloc, PinAuthenticationState, BiometricPreference>(
                selector: (state) => state.biometricPreference,
                builder: (context, biometricPreference) => FractionallySizedBox(
                  widthFactor: 0.8,
                  child: PinInputKeyboard(
                    onTap: _onKeyTap,
                    onDelTap: _onDelTap,
                    onBiometricTap: _onBiometricTap,
                    biometricPreference: _shouldApproveBiometric ? biometricPreference : BiometricPreference.disabled,
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
