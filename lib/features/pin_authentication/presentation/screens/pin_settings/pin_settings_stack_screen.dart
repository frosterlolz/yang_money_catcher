import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

enum PinSettingsScreenStatus {
  // Инициирован процесс создания код-пароля
  createPin,
  // Инициирован процесс изменения код-пароля
  changePin,
  // Подтвердил код-пароль, все верно
  verified,
  // Любой другой статус
  other,
}

/// {@template PinSettingsStackScreen.class}
/// PinSettingsStackScreen widget.
/// {@endtemplate}
@RoutePage()
class PinSettingsStackScreen extends StatefulWidget {
  /// {@macro PinSettingsStackScreen.class}
  const PinSettingsStackScreen({super.key});

  @override
  State<PinSettingsStackScreen> createState() => _PinSettingsStackScreenState();
}

class _PinSettingsStackScreenState extends State<PinSettingsStackScreen> {
  String? _pin;
  late PinSettingsScreenStatus _status;

  @override
  void initState() {
    super.initState();
    _status = PinSettingsScreenStatus.other;
  }

  void _onPinVerificationChanged(String? pin) {
    if (pin == null) {
      _changeSettingsPinStatus(PinSettingsScreenStatus.changePin);
      return;
    }
    _changePin(pin);
    _changeSettingsPinStatus(PinSettingsScreenStatus.verified);
  }

  void _changePin(String v) {
    if (_pin == v || !mounted) return;
    setState(() => _pin = v);
  }

  void _changeSettingsPinStatus(PinSettingsScreenStatus v) {
    if (_status == v || !mounted) return;
    setState(() => _status = v);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PinAuthenticationBloc, PinAuthenticationState>(
        builder: (context, pinAuthState) => AbsorbPointer(
          absorbing: pinAuthState is PinAuthenticationState$Processing,
          child: Scaffold(
            appBar: AppBar(title: Text(context.l10n.pinScreenTitle)),
            body: BlocSelector<PinAuthenticationBloc, PinAuthenticationState, PinAuthenticationStatus>(
              selector: (state) => state.status,
              builder: (context, authenticationStatus) => AutoRouter.declarative(
                routes: (handler) => [
                  if (_status == PinSettingsScreenStatus.verified ||
                      _status == PinSettingsScreenStatus.changePin ||
                      _status == PinSettingsScreenStatus.createPin)
                    PinSettingsRoute(
                      pinSettingsScreenStatus: _status,
                      validPin: _pin,
                      onPinChanged: _onPinVerificationChanged,
                    )
                  else
                    switch (authenticationStatus) {
                      PinAuthenticationStatus.disabled => PinSettingsPreviewRoute(
                          onSuccess: () => _changeSettingsPinStatus(PinSettingsScreenStatus.createPin),
                        ),
                      _ => PinSettingsVerificationRoute(onSuccess: _onPinVerificationChanged),
                    },
                ],
              ),
            ),
          ),
        ),
      );
}
