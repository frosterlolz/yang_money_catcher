import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/features/settings/domain/bloc/settings_bloc/settings_bloc.dart';
import 'package:yang_money_catcher/features/settings/domain/enity/haptic_type.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/layout/material_spacing.dart';

/// {@template HapticSettingsScreen.class}
/// HapticSettingsScreen widget.
/// {@endtemplate}
@RoutePage()
class HapticSettingsScreen extends StatelessWidget {
  /// {@macro HapticSettingsScreen.class}
  const HapticSettingsScreen({super.key});

  Future<void> _setSelectedHaptic(BuildContext context, {required HapticType type}) async {
    await type.play();
    if (!context.mounted) return;
    context.read<SettingsBloc>().add(SettingsEvent.updateHaptic(type));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.hapticEffect)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const HorizontalSpacing.compact().copyWith(top: AppSizes.double16),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: colorScheme.onInverseSurface,
                borderRadius: const BorderRadius.all(Radius.circular(AppSizes.double16)),
              ),
              sliver: BlocSelector<SettingsBloc, SettingsState, HapticType>(
                selector: (state) => state.settings.hapticType,
                builder: (context, hapticType) => SliverList.separated(
                  itemCount: HapticType.values.length,
                  itemBuilder: (context, index) {
                    final item = HapticType.values[index];
                    final isSelected = item == hapticType;

                    return ListTile(
                      title: Text(context.l10n.hapticTitleValue(item.name)),
                      subtitle: Text(context.l10n.hapticDescriptionValue(item.name)),
                      leading: Icon(Icons.check, color: isSelected ? colorScheme.primary : Colors.transparent),
                      onTap: () => _setSelectedHaptic(context, type: item),
                    );
                  },
                  separatorBuilder: (context, index) => const Padding(
                    padding: HorizontalSpacing.compact(),
                    child: Divider(),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.double16),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.l10n.hapticScreenIntro,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(
                  dimension: AppSizes.double100,
                  child: Icon(Icons.phonelink_ring, size: AppSizes.double50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
