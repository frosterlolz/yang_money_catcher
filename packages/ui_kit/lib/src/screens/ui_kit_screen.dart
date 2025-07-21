import 'package:flutter/material.dart';
import 'package:ui_kit/src/screens/screens.dart';

/// {@template UiKitScreen.class}
/// UiKitScreen widget.
/// {@endtemplate}
class UiKitScreen extends StatelessWidget {
  /// {@macro UiKitScreen.class}
  const UiKitScreen({super.key});

  void _onPushRouteTap(BuildContext context, {required Widget screen}) =>
      Navigator.of(context).push(MaterialPageRoute<dynamic>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('UiKitScreen'),
        ),
        body: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              ListTile(
                leading: const Icon(Icons.widgets),
                title: const Text('UIKit Widgets'),
                onTap: () => _onPushRouteTap(context, screen: const DebugElementsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('ColorScheme'),
                onTap: () => _onPushRouteTap(
                  context,
                  screen: const ColorSchemeScreen(),
                ),
              ),
            ],
          ).toList(),
        ),
      );
}
