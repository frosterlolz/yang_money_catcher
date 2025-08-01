import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/features/account/domain/bloc/accounts_bloc/accounts_bloc.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/bloc/transaction_categories_bloc/transaction_categories_bloc.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

/// {@template TransactionCategorySelectorView.class}
/// TransactionCategorySelectorView widget.
/// {@endtemplate}
class TransactionCategorySelectorView extends StatelessWidget {
  /// {@macro TransactionCategorySelectorView.class}
  const TransactionCategorySelectorView({super.key, this.currentTransactionCategoryId, this.isIncome});

  final int? currentTransactionCategoryId;
  final bool? isIncome;

  void _onRetryTap(BuildContext context) =>
      context.read<TransactionCategoriesBloc>().add(const TransactionCategoriesEvent.load());

  @override
  Widget build(BuildContext context) => BlocBuilder<TransactionCategoriesBloc, TransactionCategoriesState>(
        builder: (context, transactionCategoriesState) {
          List<TransactionCategory>? transactionCategories = transactionCategoriesState.categories;
          if (isIncome != null) {
            transactionCategories = transactionCategories?.where((e) => e.isIncome == isIncome).toList();
          }
          return switch (transactionCategoriesState) {
            _ when transactionCategories != null => _TransactionCategoriesListView(
                transactionCategories,
                currentTransactionCategoryId: currentTransactionCategoryId,
              ),
            AccountsState$Error(:final error) => ErrorBodyView(
                title: ErrorUtil.messageFromObject(context, error: error),
                retryButtonText: context.l10n.tryItAgain,
                description: context.l10n.retry,
                onRetryTap: () => _onRetryTap(context),
              ),
            _ => const LoadingBodyView(),
          };
        },
      );
}

/// {@template _TransactionCategoriesListView.class}
/// _TransactionCategoriesListView widget.
/// {@endtemplate}
class _TransactionCategoriesListView extends StatelessWidget {
  /// {@macro _TransactionCategoriesListView.class}
  const _TransactionCategoriesListView(this.items, {this.currentTransactionCategoryId});

  final int? currentTransactionCategoryId;
  final List<TransactionCategory> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: Text(context.l10n.articlesAreEmpty));
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          key: Key('transaction_category_$index'),
          leading: Text(item.emoji),
          title: Text(item.name),
          subtitle: Text(item.isIncome ? context.l10n.singleIncome : context.l10n.expense),
          trailing: currentTransactionCategoryId == item.id
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => context.maybePop(item),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}
