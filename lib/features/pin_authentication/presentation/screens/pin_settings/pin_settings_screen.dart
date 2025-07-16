import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/service/local_auth_service.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/screens/pin_settings/pin_settings.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_field.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_keyboard.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';

const _pinLength = 4;
const _errorAnimationDuration = Duration(milliseconds: 400);

/// {@template PinSettingsScreen.class}
/// PinSettingsScreen widget.
/// {@endtemplate}
@RoutePage()
class PinSettingsScreen extends StatefulWidget {
  /// {@macro PinSettingsScreen.class}
  const PinSettingsScreen({
    super.key,
    required this.pinSettingsScreenStatus,
    required this.onPinSettingsScreenStatusChanged,
  });

  final PinSettingsScreenStatus pinSettingsScreenStatus;
  final ValueChanged<PinSettingsScreenStatus> onPinSettingsScreenStatusChanged;

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> with _PinSettingsScreenMixin {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    final initialPage = _calculatePage();
    _controller = PageController(initialPage: initialPage);
  }

  @override
  void didUpdateWidget(covariant PinSettingsScreen oldWidget) {
    if (oldWidget.pinSettingsScreenStatus != widget.pinSettingsScreenStatus) {
      final nextPage = _calculatePage();
      _controller.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      _setPin('');
      _setRepeatPin('');
    }
    super.didUpdateWidget(oldWidget);
  }

  int _calculatePage() => switch (widget.pinSettingsScreenStatus) {
        PinSettingsScreenStatus.other => 0,
        PinSettingsScreenStatus.createPin => 0,
        PinSettingsScreenStatus.changePin => 0,
        PinSettingsScreenStatus.verified => 2,
      };

  void _onPinEnterComplete(String pin) {
    if (pin.trim().length > _pinLength) {
      throw StateError('Invalid pin length');
    }
    _setPin(pin);
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _onPinRepeatComplete(String pin) async {
    if (pin.trim().length > _pinLength) {
      throw StateError('Invalid pin length');
    }
    _setRepeatPin(pin);
    final isValid = _validate(context);
    if (isValid) {
      switch (widget.pinSettingsScreenStatus) {
        case PinSettingsScreenStatus.createPin:
          context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.signUp(_pin));
        case PinSettingsScreenStatus.changePin:
          context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.changePin(_pin));
        case PinSettingsScreenStatus.verified || PinSettingsScreenStatus.other:
          throw StateError('Invalid status inside {PinSettingsScreen._onPinRepeatComplete}');
      }
    }
    await Future<void>.delayed(_errorAnimationDuration);
    _setRepeatPin('');
  }

  void _pinAuthStateListener(BuildContext context, PinAuthenticationState state) {
    switch (state) {
      case PinAuthenticationState$Processing():
      case PinAuthenticationState$Idle():
        _setErrorMessage(null);
      case PinAuthenticationState$Success():
        widget.onPinSettingsScreenStatusChanged(PinSettingsScreenStatus.verified);
      case PinAuthenticationState$Error(:final error):
        final message = switch (error) {
          PinException$Invalid() => context.l10n.pinIsIncorrect,
          _ => context.l10n.somethingWentWrong,
        };
        _setErrorMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<PinAuthenticationBloc, PinAuthenticationState>(
        listener: _pinAuthStateListener,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          children: [
            _PinInputPage(
              key: const ValueKey('primary_pin_input'),
              currentPin: _pin,
              pinLength: _pinLength,
              title: context.l10n.enterPinCode,
              onComplete: _onPinEnterComplete,
              errorMessage: _errorMessage,
            ),
            _PinInputPage(
              key: const ValueKey('secondary_pin_input'),
              currentPin: _repeatPin,
              pinLength: _pinLength,
              title: context.l10n.repeatPinCode,
              onComplete: _onPinRepeatComplete,
              errorMessage: _errorMessage,
            ),
            _PinSettingsPanelScreen(
              key: const ValueKey('pin_settings'),
              onChangePinTap: () => widget.onPinSettingsScreenStatusChanged.call(PinSettingsScreenStatus.changePin),
            ),
          ],
        ),
      );
}

mixin _PinSettingsScreenMixin on State<PinSettingsScreen> {
  String _pin = '';
  String _repeatPin = '';
  String? _errorMessage;

  bool _validate(BuildContext context) {
    bool isValid = false;
    isValid = _pin.length < _pinLength || _repeatPin.length < _pinLength;
    if (isValid) {
      _setErrorMessage(null);
      return isValid;
    }
    isValid = _pin == _repeatPin;
    _setErrorMessage(isValid ? null : context.l10n.pinsDoNotMatch);
    return isValid;
  }

  void _setPin(String v) {
    if (_pin.trim() == v.trim() || v.length > _pinLength || !mounted) return;
    setState(() => _pin = v);
  }

  void _setRepeatPin(String v) {
    if (_repeatPin.trim() == v.trim() || v.length > _pinLength || !mounted) return;
    setState(() => _repeatPin = v);
  }

  void _setErrorMessage(String? v) {
    if (_errorMessage == v || !mounted) return;
    setState(() => _errorMessage = v);
  }
}

/// {@template _PinInputPage.class}
/// View для ввода пин-кода
/// {@endtemplate}
class _PinInputPage extends StatefulWidget {
  /// {@macro _PinInputPage.class}
  const _PinInputPage({
    super.key,
    required this.title,
    required this.currentPin,
    required this.onComplete,
    required this.pinLength,
    this.errorMessage,
  });

  final String title;
  final String currentPin;
  final int pinLength;
  final ValueChanged<String> onComplete;
  final String? errorMessage;

  @override
  State<_PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<_PinInputPage> {
  late String _pin;

  String? get _errorMessage => _pin.isNotEmpty && _pin.length < widget.pinLength ? null : widget.errorMessage;

  @override
  void initState() {
    super.initState();
    _pin = widget.currentPin;
  }

  @override
  void didUpdateWidget(covariant _PinInputPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPin != oldWidget.currentPin) {
      _changePin(widget.currentPin);
    }
  }

  void _onKeyTap(String v) {
    final nextPin = _pin + v;
    _changePin(nextPin);
  }

  void _onDelTap() {
    if (_pin.isEmpty) return;
    final nextPin = _pin.substring(0, _pin.length - 1);
    _changePin(nextPin);
  }

  void _changePin(String v) {
    if (_pin.trim() == v.trim() || v.length > widget.pinLength || !mounted) return;
    setState(() => _pin = v);
    if (_pin.length == widget.pinLength) {
      widget.onComplete(_pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);

    return Column(
      spacing: AppSizes.double10,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),
        Text(widget.title, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
        PinInputField(
          pinLength: widget.pinLength,
          filledLength: _pin.length,
          isError: _errorMessage != null,
          errorAnimationDuration: _errorAnimationDuration,
        ),
        Text(_errorMessage ?? '', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
        const Spacer(),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: PinInputKeyboard(
            onTap: _onKeyTap,
            onDelTap: _onDelTap,
            onBiometricTap: () {},
            biometricPreference: BiometricPreference.disabled,
          ),
        ),
      ],
    );
  }
}

/// {@template _PinSettingsPanelScreen.class}
/// _PinSettingsPanelScreen widget.
/// {@endtemplate}
class _PinSettingsPanelScreen extends StatefulWidget {
  /// {@macro _PinSettingsPanelScreen.class}
  const _PinSettingsPanelScreen({super.key, required this.onChangePinTap});

  final VoidCallback onChangePinTap;

  @override
  State<_PinSettingsPanelScreen> createState() => _PinSettingsPanelScreenState();
}

class _PinSettingsPanelScreenState extends State<_PinSettingsPanelScreen> {
  late final LocalAuthService _localAuthService;

  @override
  void initState() {
    super.initState();
    _localAuthService = LocalAuthService();
  }

  void _onPinResetTap(BuildContext context) {
    context.read<PinAuthenticationBloc>().add(const PinAuthenticationEvent.resetPin());
  }

  void _onBiometricPreferenceTap(BuildContext context, {required BiometricPreference preference}) {
    context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.changeBiometricStatus(preference));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);

    return Padding(
      padding: const HorizontalSpacing.compact(),
      child: Column(
        spacing: AppSizes.double10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.double10),
          Card(
            margin: EdgeInsets.zero,
            color: colorScheme.tertiary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppSizes.double16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () => _onPinResetTap(context), child: Text(context.l10n.pinDisable)),
                const Divider(indent: AppSizes.double10, endIndent: AppSizes.double10),
                TextButton(onPressed: widget.onChangePinTap, child: Text(context.l10n.pinChange)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.double10),
            child: Text(context.l10n.pinSettingsDescriptionDemo),
          ),
          BlocSelector<PinAuthenticationBloc, PinAuthenticationState, BiometricPreference>(
            selector: (state) => state.biometricPreference,
            builder: (context, biometricPreference) => FutureBuilder(
              future: _localAuthService.getBiometricAvailableType(),
              builder: (context, snapshot) {
                final availableBiometricType = snapshot.data;
                if (availableBiometricType == null) return const SizedBox.shrink();

                return SwitchListTile(
                  tileColor: colorScheme.tertiary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppSizes.double16)),
                  ),
                  title: Text(
                    context.l10n.pinBiometricUnlock(availableBiometricType.name),
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiary),
                  ),
                  value: biometricPreference != BiometricPreference.disabled,
                  onChanged: (v) => _onBiometricPreferenceTap(
                    context,
                    preference: v ? availableBiometricType : BiometricPreference.disabled,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
