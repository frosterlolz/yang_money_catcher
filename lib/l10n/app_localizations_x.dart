// ignore_for_file: avoid-non-null-assertion

import 'package:flutter/material.dart';
import 'package:yang_money_catcher/l10n/app_localizations.g.dart';
import 'package:yang_money_catcher/l10n/localization.dart';

/// Extension for working with localization.
extension AppLocalizationsX on BuildContext {
  /// Getter for strings.
  AppLocalizations get l10n => Localization.of(this);
}
