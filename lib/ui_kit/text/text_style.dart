//ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// App text style.
// ignore_for_file: prefer-match-file-name
enum AppTextStyle {
  regular11(TextStyle(fontSize: 11)),
  regular12(TextStyle(fontSize: 12)),
  regular13(TextStyle(fontSize: 13)),
  regular14(TextStyle(fontSize: 14)),
  regular15(TextStyle(fontSize: 15)),
  regular16(TextStyle(fontSize: 16)),
  regular18(TextStyle(fontSize: 18)),
  regular20(TextStyle(fontSize: 20)),
  regular22(TextStyle(fontSize: 20)),

  medium11(TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),

  medium12(TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
  medium13(TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
  medium14(TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  medium15(TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
  medium16(TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  medium18(TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
  medium20(TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),

  semiBold12(TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),

  bold10(TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),

  bold11(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),

  bold13(TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),

  bold14(TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
  bold16(TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.blue));

  final TextStyle value;

  // ignore: sort_constructors_first
  const AppTextStyle(this.value);
}
