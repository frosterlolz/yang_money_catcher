import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/service/local_auth_service.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_field.dart';
import 'package:yang_money_catcher/features/pin_authentication/presentation/widgets/pin_input_keyboard.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';

const _pinLength = 4;
const _errorAnimationDuration = Duration(milliseconds: 400);

/// {@template OnPinInputCompleted.typedef}
/// Колбэк, вызываемый при завершении ввода пин-кода или биометрической авторизации.
///
/// - [pin] — строка пин-кода (может быть отображаемая, например, "****").
/// - [isBiometricVerified]:
///   - `true` — верификация пройдена через биометрию;
///   - `false` — биометрия не пройдена (например, отказ пользователя);
///   - `null` — пин введён вручную.
/// {@endtemplate}
typedef OnPinInputCompleted = void Function(String pin, [bool? isBiometricVerified]);

/// {@template PinInputView.class}
/// PinInputView widget.
/// {@endtemplate}
class PinInputView extends StatefulWidget {
  /// {@macro PinInputView.class}
  const PinInputView({
    super.key,
    required this.title,
    this.pinLength = _pinLength,
    required this.onComplete,
    this.errorMessage,
    this.shouldEnableBiometric = false,
    this.shouldInitBiometricImmediately = true,
    this.onResetPin,
  });

  /// Текст заголовка над полем ввода пин-кода
  final String title;

  /// Длина пин-кода
  final int pinLength;

  /// {@macro OnPinInputCompleted.typedef}
  final OnPinInputCompleted onComplete;

  /// Сообщение об ошибке
  final String? errorMessage;

  /// Должна ли быть доступна кнопка биометрического ввода
  final bool shouldEnableBiometric;

  /// Попробовать ли авторизоваться по биометрии сразу при инициализации
  final bool shouldInitBiometricImmediately;

  /// Если передан- над клавиатурой отобразится кнопка сброса пин-кода
  final VoidCallback? onResetPin;

  @override
  State<PinInputView> createState() => _PinInputViewState();
}

class _PinInputViewState extends State<PinInputView> {
  late final LocalAuthService _localAuthService;
  late String _pin;
  late final ValueNotifier<String?> _errorMessage;
  late BiometricPreference _biometricAvailableType;
  bool _isBiometricVerificationInProgress = false;

  @override
  void initState() {
    super.initState();
    _localAuthService = LocalAuthService();
    _pin = '';
    _errorMessage = ValueNotifier<String?>(null);
    _biometricAvailableType = BiometricPreference.disabled;
    _initBiometricConfig();
  }

  @override
  void didUpdateWidget(covariant PinInputView oldWidget) {
    super.didUpdateWidget(oldWidget);

    _setErrorMessage(widget.errorMessage);
  }

  Future<void> _initBiometricConfig() async {
    if (!widget.shouldEnableBiometric) {
      _changeBiometricAvailableType(BiometricPreference.disabled);
      return;
    }
    final availableType = await _localAuthService.getBiometricAvailableType();
    _changeBiometricAvailableType(availableType ?? BiometricPreference.disabled);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _biometricAvailableType != BiometricPreference.disabled && widget.shouldInitBiometricImmediately) {
        _onBiometricTap();
      }
    });
  }

  void _changeBiometricAvailableType(BiometricPreference v) {
    if (_biometricAvailableType == v || !mounted) return;
    setState(() => _biometricAvailableType = v);
  }

  void _onKeyTap(String v) {
    final nextPin = _pin + v;
    _handlePinChange(nextPin);
  }

  void _onDelTap() {
    if (_pin.isEmpty) return;
    final nextPin = _pin.substring(0, _pin.length - 1);
    _handlePinChange(nextPin);
  }

  Future<void> _onBiometricTap() async {
    if (_isBiometricVerificationInProgress || _biometricAvailableType == BiometricPreference.disabled) return;
    _isBiometricVerificationInProgress = true;
    final reasonMessage = context.l10n.biometricReasonSignIn;
    try {
      final isVerified = await _localAuthService.authenticate(reasonMessage);
      final fakePin = '*' * widget.pinLength;
      if (mounted && !isVerified) {
        return _handlePinChange(fakePin, isBiometricVerified: false);
      }
      if (!mounted || !isVerified) return;
      _handlePinChange(fakePin, isBiometricVerified: true);
    } finally {
      _isBiometricVerificationInProgress = false;
    }
  }

  void _handlePinChange(String v, {bool? isBiometricVerified}) {
    final trimmedPin = v.trim();
    if (_pin == trimmedPin || v.length > widget.pinLength || !mounted) return;
    setState(() => _pin = trimmedPin);
    if (_pin.isNotEmpty && _pin.length < widget.pinLength) {
      _setErrorMessage(null);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pin.length == widget.pinLength) {
        widget.onComplete(_pin, isBiometricVerified);
      }
    });
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
    widget.onResetPin?.call();
  }

  Future<void> _setErrorMessage(String? v) async {
    if (_errorMessage.value == v || !mounted) return;
    _errorMessage.value = v;
    await Future<void>.delayed(_errorAnimationDuration);
    if (v != null) {
      _handlePinChange('');
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
        ValueListenableBuilder(
          valueListenable: _errorMessage,
          builder: (_, message, __) => PinInputField(
            pinLength: widget.pinLength,
            filledLength: _pin.length,
            isError: _errorMessage.value != null,
            errorAnimationDuration: _errorAnimationDuration,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _errorMessage,
          builder: (_, message, __) => Text(
            message ?? '',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
        ),
        const Spacer(),
        if (widget.onResetPin != null) TextButton(onPressed: _onResetPin, child: Text(context.l10n.resetPin)),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: PinInputKeyboard(
            onTap: _onKeyTap,
            onDelTap: _onDelTap,
            onBiometricTap: _onBiometricTap,
            biometricPreference: _biometricAvailableType,
          ),
        ),
      ],
    );
  }
}
