import 'package:auto_route/auto_route.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';

Future<Color?> showSeedColorDialog(BuildContext context, {required Color initialColor}) => showDialog(
      context: context,
      builder: (context) => SeedColorPickerDialog(initialColor),
    );

/// {@template SeedColorPickerDialog.class}
/// SeedColorPickerDialog widget.
/// {@endtemplate}
class SeedColorPickerDialog extends StatefulWidget {
  /// {@macro SeedColorPickerDialog.class}
  const SeedColorPickerDialog(this.initialColor, {super.key});

  final Color initialColor;

  @override
  State<SeedColorPickerDialog> createState() => _SeedColorPickerDialogState();
}

class _SeedColorPickerDialogState extends State<SeedColorPickerDialog> {
  late Color _seedColor;

  @override
  void initState() {
    super.initState();
    _seedColor = widget.initialColor;
  }

  void _onResetColorTap() {
    final effectiveColor = AppColorScheme.of(context).primary;
    setState(() {
      _seedColor = effectiveColor;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: FittedBox(child: Text(context.l10n.selectMainColor)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _seedColor,
            onColorChanged: (color) => _seedColor = color,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          IconButton(onPressed: _onResetColorTap, icon: const Icon(Icons.refresh)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text(context.l10n.save),
                onPressed: () => context.maybePop(_seedColor),
              ),
              TextButton(
                child: Text(context.l10n.cancel),
                onPressed: () => context.maybePop(),
              ),
            ],
          ),
        ],
      );
}
