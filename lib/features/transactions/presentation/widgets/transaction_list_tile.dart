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
    required this.title,
    this.comment,
    this.commentStyle,
    required this.emoji,
    required this.amount,
    this.transactionDateTime,
    this.enableTopDivider = false,
    this.enableBottomDivider = false,
    this.onTap,
  });

  final String title;
  final String? comment;
  final TextStyle? commentStyle;
  final String emoji;
  final String amount;
  final String? transactionDateTime;
  final bool enableTopDivider;
  final bool enableBottomDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enableTopDivider) const Divider(),
          ListTile(
            onTap: onTap,
            leading: Text(emoji),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 3),
                      if (comment?.trim().isNotEmpty ?? false)
                        Text(
                          comment!,
                          maxLines: 3,
                          style: commentStyle ?? Theme.of(context).listTileTheme.subtitleTextStyle,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(amount),
                    if (transactionDateTime != null)
                      Text(
                        transactionDateTime!,
                        style: Theme.of(context).listTileTheme.titleTextStyle,
                      ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: ColorScheme.of(context).outline.withValues(alpha: AppSizes.double03),
            ),
          ),
          if (enableBottomDivider) const Divider(),
        ],
      );
}
