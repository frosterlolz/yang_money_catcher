import 'package:auto_route/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:pretty_logger/pretty_logger.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/features/pin_authentication/data/utils/pin_exception.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/service/local_auth_service.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/screens/pin_settings/pin_settings.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_view.dart';

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

  void _onPinEnterComplete(String pin, {required int pinMaxLength}) {
    if (pin.trim().length > pinMaxLength) {
      throw StateError('Invalid pin length');
    }
    _setPin(pin, maxLength: pinMaxLength);
    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _onPinRepeatComplete(String pin) async {
    _setErrorMessage(null);
    final trimmedPin = pin.trim();
    try {
      if (trimmedPin.length > _pin.length) {
        throw StateError('Invalid pin length');
      }
      _setRepeatPin(pin);
      final isValid = _validate(context);
      if (!isValid) {
        return _setErrorMessage(isValid ? null : context.l10n.pinsDoNotMatch);
      }

      switch (widget.pinSettingsScreenStatus) {
        case PinSettingsScreenStatus.createPin:
          context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.signUp(_pin));
        case PinSettingsScreenStatus.changePin:
          context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.changePin(_pin));
        case PinSettingsScreenStatus.verified || PinSettingsScreenStatus.other:
          throw StateError('Invalid status inside {PinSettingsScreen._onPinRepeatComplete}');
      }
    } on Object catch (e, s) {
      logger.warn('$e', stackTrace: s);
      _setErrorMessage(context.l10n.somethingWentWrong);
    }
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
  Widget build(BuildContext context) => BlocConsumer<PinAuthenticationBloc, PinAuthenticationState>(
        listener: _pinAuthStateListener,
        builder: (context, pinAuthState) => PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          children: [
            PinInputView(
              key: const ValueKey('primary_pin_input'),
              pinLength: pinAuthState.pinLength,
              title: context.l10n.enterPinCode,
              onComplete: (pin, [_]) => _onPinEnterComplete(pin, pinMaxLength: pinAuthState.pinLength),
              errorMessage: _errorMessage,
            ),
            PinInputView(
              key: const ValueKey('secondary_pin_input'),
              pinLength: pinAuthState.pinLength,
              title: context.l10n.repeatPinCode,
              onComplete: (pin, [_]) => _onPinRepeatComplete(pin),
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
    final isValid = _repeatPin.length < _pin.length;
    if (isValid) return isValid;
    return _pin == _repeatPin;
  }

  void _setPin(String v, {int? maxLength}) {
    final trimmedPin = v.trim();
    if (_pin == trimmedPin || !mounted) return;
    if (maxLength != null && trimmedPin.length > maxLength) return;
    setState(() => _pin = v);
  }

  void _setRepeatPin(String v) {
    if (_repeatPin.trim() == v.trim() || v.length > _pin.length || !mounted) return;
    setState(() => _repeatPin = v);
  }

  void _setErrorMessage(String? v) {
    if (_errorMessage == v || !mounted) return;
    setState(() => _errorMessage = v);
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

  void _onBiometricPreferenceTap(BuildContext context, {required bool shouldAllowBiometric}) {
    context.read<PinAuthenticationBloc>().add(PinAuthenticationEvent.changeBiometricStatus(shouldAllowBiometric));
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
          BlocSelector<PinAuthenticationBloc, PinAuthenticationState, bool>(
            selector: (state) => state.shouldAllowBiometric,
            builder: (context, shouldAllowBiometric) => FutureBuilder(
              future: _localAuthService.getBiometricAvailableType(),
              builder: (context, snapshot) {
                final availableBiometricType = snapshot.data;
                final isBiometricAvailable =
                    availableBiometricType != null && availableBiometricType != BiometricPreference.disabled;
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
                  value: shouldAllowBiometric,
                  onChanged: (v) => _onBiometricPreferenceTap(
                    context,
                    shouldAllowBiometric: v ? isBiometricAvailable : false,
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
