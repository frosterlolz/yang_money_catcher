import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:localization/localization.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:yang_money_catcher/core/presentation/common/error_util.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/bloc/transaction_categories_bloc/transaction_categories_bloc.dart';
import 'package:yang_money_catcher/features/transaction_categories/domain/entity/transaction_category.dart';

/// {@template TransactionCategoriesScreen.class}
/// Экран отображения категорий транзакций
/// {@endtemplate}
@RoutePage()
class TransactionCategoriesScreen extends StatelessWidget {
  /// {@macro TransactionCategoriesScreen.class}
  const TransactionCategoriesScreen({super.key});

  void _onRetryTap(BuildContext context) {
    context.read<TransactionCategoriesBloc>().add(const TransactionCategoriesEvent.load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.myArticles)),
        body: BlocBuilder<TransactionCategoriesBloc, TransactionCategoriesState>(
          builder: (context, transactionCategoriesState) => switch (transactionCategoriesState) {
            _ when transactionCategoriesState.categories != null =>
              _TransactionCategoriesSuccessView(transactionCategoriesState.categories!),
            TransactionCategoriesState$Error(:final error) => ErrorBodyView(
                title: ErrorUtil.messageFromObject(context, error: error),
                retryButtonText: context.l10n.tryItAgain,
                description: context.l10n.retry,
                onRetryTap: () => _onRetryTap(context),
              ),
            _ => const LoadingBodyView(),
          },
        ),
      );
}

/// {@template _TransactionCategoriesSuccessView.class}
/// _TransactionCategoriesSuccessView widget.
/// {@endtemplate}
class _TransactionCategoriesSuccessView extends StatefulWidget {
  /// {@macro _TransactionCategoriesSuccessView.class}
  const _TransactionCategoriesSuccessView(this.transactionCategories);

  final List<TransactionCategory> transactionCategories;

  @override
  State<_TransactionCategoriesSuccessView> createState() => _TransactionCategoriesSuccessViewState();
}

class _TransactionCategoriesSuccessViewState extends State<_TransactionCategoriesSuccessView> {
  late String _searchQuery;
  late List<TransactionCategory> _transactionCategories$Filtered;

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
    _transactionCategories$Filtered = widget.transactionCategories;
  }

  @override
  void didUpdateWidget(covariant _TransactionCategoriesSuccessView oldWidget) {
    if (!const ListEquality<TransactionCategory>()
        .equals(widget.transactionCategories, oldWidget.transactionCategories)) {
      _searchUpdate();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onSearchChanged(String v) {
    if (_searchQuery.trim() == v.trim()) return;
    _searchQuery = v.trim();
    _searchUpdate();
  }

  void _searchUpdate() {
    final fuse = Fuzzy<TransactionCategory>(
      widget.transactionCategories,
      options: FuzzyOptions(
        threshold: 0.4,
        keys: [
          WeightedKey(name: 'name', getter: (e) => e.name, weight: 1),
        ],
        shouldSort: true,
        sortFn: (a, b) => a.score.compareTo(b.score),
      ),
    );
    final result = fuse.search(_searchQuery);
    setState(() {
      _transactionCategories$Filtered = result.map((e) => e.item).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactionCategories.isEmpty) {
      return Center(
        child: Text(
          context.l10n.articlesAreEmpty,
          textAlign: TextAlign.center,
          style: TextTheme.of(context).titleMedium,
        ),
      );
    }
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: SearchTextField(onChanged: _onSearchChanged),
        ),
        if (_transactionCategories$Filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                context.l10n.nothingFound,
                textAlign: TextAlign.center,
                style: TextTheme.of(context).titleMedium,
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: _transactionCategories$Filtered.length,
            itemBuilder: (context, index) {
              final transactionCategory = _transactionCategories$Filtered[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Text(transactionCategory.emoji),
                    title: Text(transactionCategory.name),
                    onTap: () => context.maybePop(transactionCategory),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
      ],
    );
  }
}
