import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/bloc/transaction_categories_bloc/transaction_categories_bloc.dart';

/// {@template MainStackScreen.class}
/// MainStackScreen widget.
/// {@endtemplate}
@RoutePage()
class MainStackScreen extends StatelessWidget {
  /// {@macro MainStackScreen.class}
  const MainStackScreen({super.key});

  void _onRetryTap(BuildContext context) {
    context.read<TransactionCategoriesBloc>().add(const TransactionCategoriesEvent.load());
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionCategoriesBloc, TransactionCategoriesState>(
        builder: (context, categoriesState) => switch (categoriesState) {
          _ when categoriesState.categories != null => const AutoRouter(),
          TransactionCategoriesState$Error(:final error) => ErrorBodyView(
              title: ErrorUtil.messageFromObject(context, error: error),
              retryButtonText: context.l10n.tryItAgain,
              description: context.l10n.retry,
              onRetryTap: () => _onRetryTap(context),
            ),
          _ => const AutoRouter(),
        },
      );
}
