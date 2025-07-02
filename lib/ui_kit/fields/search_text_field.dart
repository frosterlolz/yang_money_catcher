import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

/// {@template SearchTextField.class}
/// SearchTextField widget.
/// {@endtemplate}
class SearchTextField extends StatefulWidget {
  /// {@macro SearchTextField.class}
  const SearchTextField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClearTap() {
    _controller.clear();
    widget.onChanged.call('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final appColorScheme = AppColorScheme.of(context);

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, child) =>
              value.text.isEmpty ? child! : IconButton(onPressed: _onClearTap, icon: const Icon(Icons.cancel_outlined)),
          child: const Icon(Icons.search),
        ),
        filled: true,
        fillColor: appColorScheme.inactiveSecondary,
        hintText: 'Найти статью',
        hintStyle: TextTheme.of(context).bodyLarge?.copyWith(color: appColorScheme.labelTertiary),
      ),
    );
  }
}
