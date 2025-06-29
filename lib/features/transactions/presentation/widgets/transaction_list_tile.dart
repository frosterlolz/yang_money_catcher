import 'package:flutter/material.dart';
import 'package:yang_money_catcher/ui_kit/app_sizes.dart';
import 'package:yang_money_catcher/ui_kit/colors/app_color_scheme.dart';

/// {@template TransactionListTile.class}
/// TransactionListTile widget.
/// {@endtemplate}
class TransactionListTile extends StatelessWidget {
  /// {@macro TransactionListTile.class}
  const TransactionListTile({
    super.key,
    required this.leadingEmoji,
    required this.title,
    required this.amount,
    this.subtitle,
    required this.onTap,
  });

  final String leadingEmoji;
  final String title;
  final String amount;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Text(leadingEmoji),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 3),
                  if (subtitle?.trim().isNotEmpty ?? false)
                    Text(
                      subtitle!,
                      maxLines: 3,
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                    ),
                ],
              ),
            ),
            Text(amount),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColorScheme.of(context).labelTertiary.withValues(alpha: AppSizes.double03),
        ),
      );
}
