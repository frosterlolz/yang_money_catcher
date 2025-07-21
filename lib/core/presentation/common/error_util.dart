import 'package:flutter/cupertino.dart';
import 'package:localization/localization.dart';
import 'package:yang_money_catcher/core/utils/exceptions/app_exception.dart';

abstract class ErrorUtil {
  static String messageFromObject(BuildContext? context, {required Object error}) => switch (error) {
        AppException$Simple(:final message) when message != null => message,
        _ => context?.l10n.somethingWentWrong ?? 'Something went wrong',
      };
}
