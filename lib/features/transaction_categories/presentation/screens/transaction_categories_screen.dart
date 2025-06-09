import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations_x.dart';

/// {@template TransactionCategoriesScreen.class}
/// Экран отображения категорий транзакций
/// {@endtemplate}
@RoutePage()
class TransactionCategoriesScreen extends StatelessWidget {
  /// {@macro TransactionCategoriesScreen.class}
  const TransactionCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.myArticles)),
        body: const Center(child: Text('Статьи')),
      );
}
