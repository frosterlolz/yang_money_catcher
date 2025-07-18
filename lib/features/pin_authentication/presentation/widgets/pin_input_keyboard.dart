import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yang_money_catcher/core/assets/res/svg_icons.dart';
import 'package:yang_money_catcher/features/pin_authentication/domain/entity/pin_config.dart';

const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', _biometricKey, '0', _delKey];
const _biometricKey = 'biometric';
const _delKey = 'del';

/// {@template PinInputKeyboard.class}
/// PinInputKeyboard widget.
/// {@endtemplate}
class PinInputKeyboard extends StatelessWidget {
  /// {@macro PinInputKeyboard.class}
  const PinInputKeyboard({
    super.key,
    required this.onTap,
    required this.onDelTap,
    required this.onBiometricTap,
    required this.biometricPreference,
  });

  final ValueChanged<String> onTap;
  final VoidCallback onDelTap;
  final VoidCallback onBiometricTap;
  final BiometricPreference biometricPreference;

  void _onTap(String key) {
    if (key == _biometricKey) return onBiometricTap();
    if (key == _delKey) return onDelTap();
    onTap(key);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.8,
      children: _keys.map(
        (key) {
          final isDisabled = key == _biometricKey && biometricPreference == BiometricPreference.disabled;
          if (isDisabled) return const SizedBox.shrink();
          return Center(
            child: InkWell(
              onTap: () => _onTap(key),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                child: switch (key) {
                  _delKey => const Icon(Icons.backspace_outlined),
                  _biometricKey => switch (biometricPreference) {
                      BiometricPreference.face => SvgPicture.asset(
                          SvgIcons.faceId,
                          colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
                        ),
                      BiometricPreference.fingerprint => Icon(Icons.fingerprint_outlined, color: colorScheme.onSurface),
                      BiometricPreference.disabled => throw UnimplementedError(),
                    },
                  _ => Text(key, style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface)),
                },
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
