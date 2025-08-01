import 'package:flutter/material.dart';
import 'package:ui_kit/src/snacks/topside_snack_bars.dart';

/// {@template DebugElementsScreen.class}
/// DebugElementsScreen widget.
/// {@endtemplate}
class DebugElementsScreen extends StatelessWidget {
  /// {@macro DebugElementsScreen.class}
  const DebugElementsScreen({super.key});

  void _onShowSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        // BottomSideSnackBars.success(context, message: 'sample message'),
        BottomSideSnackBars.error(context, titleText: 'Sample error'),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('DebugElementsScreen'),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Show snackBar'),
              onTap: () => _onShowSnackBar(context),
            ),
          ],
        ),
      );
}
