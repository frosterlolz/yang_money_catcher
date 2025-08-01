import 'package:auto_route/annotations.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/assets/res/app_images.dart';

/// {@template PinSettingsPreviewScreen.class}
/// PinSettingsPreviewScreen widget.
/// {@endtemplate}
@RoutePage()
class PinSettingsPreviewScreen extends StatelessWidget {
  /// {@macro PinSettingsPreviewScreen.class}
  const PinSettingsPreviewScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return Padding(
      padding: const HorizontalSpacing.compact(),
      child: Column(
        spacing: AppSizes.double20,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          FractionallySizedBox(
            widthFactor: 0.5,
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(const Size.fromHeight(250)),
              child: Image.asset(AppImages.pinCode),
            ),
          ),
          Text(context.l10n.pinScreenTitle, style: textTheme.headlineSmall),
          Text(
            '${context.l10n.pinScreenDescription} ${context.l10n.pinScreenBiometricNote}',
            textAlign: TextAlign.center,
          ),
          ElevatedButton(onPressed: onSuccess, child: Text(context.l10n.pinScreenEnableButton)),
          Text(context.l10n.pinScreenForgotInfo, textAlign: TextAlign.center),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
