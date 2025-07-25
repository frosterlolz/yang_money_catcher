//ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// App text style.
// ignore_for_file: prefer-match-file-name
enum AppTextStyle {
  // regular14(TextStyle(fontSize: 14)),
  // regular16(TextStyle(fontSize: 16)),
  // regular20(TextStyle(fontSize: 20)),
  //
  // medium12(TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
  // medium15(TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
  // medium16(TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  // medium20(TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
  //
  // semiBold12(TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),

  displayLarge(
    TextStyle(fontSize: 57),
  ),
  displayMedium(
    TextStyle(fontSize: 45),
  ),
  displaySmall(
    TextStyle(fontSize: 36),
  ),

  headlineLarge(
    TextStyle(fontSize: 32),
  ),
  headlineMedium(
    TextStyle(fontSize: 28),
  ),
  headlineSmall(
    TextStyle(fontSize: 24),
  ),

  titleLarge(
    TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
  ),
  titleMedium(
    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ),
  titleSmall(
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  ),

  labelLarge(
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  ),
  labelMedium(
    TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  ),
  labelSmall(
    TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  ),

  bodyLarge(
    TextStyle(fontSize: 16),
  ),
  bodyMedium(
    TextStyle(fontSize: 14),
  ),
  bodySmall(
    TextStyle(fontSize: 12),
  );

  const AppTextStyle(this.value);

  final TextStyle value;
}
