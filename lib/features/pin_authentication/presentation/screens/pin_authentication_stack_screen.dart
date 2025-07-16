import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yang_money_catcher/features/navigation/app_router.gr.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/bloc/pin_authentication_bloc/pin_authentication_bloc.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

/// {@template PinAuthenticationStackScreen.class}
/// PinAuthenticationStackScreen widget.
/// {@endtemplate}
@RoutePage()
class PinAuthenticationStackScreen extends StatelessWidget {
  /// {@macro PinAuthenticationStackScreen.class}
  const PinAuthenticationStackScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PinAuthenticationBloc, PinAuthenticationState>(
        builder: (context, pinAuthenticationState) => AutoRouter.declarative(
          routes: (handler) => <PageRouteInfo<Object?>>[
            if (pinAuthenticationState.status == PinAuthenticationStatus.unauthenticated)
              PinAuthenticationRoute()
            else
              const MainStackRoute(),
          ],
        ),
      );
}
