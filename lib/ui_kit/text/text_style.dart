//ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

// TODO(frosterlolz): заменить шрифт из фигмы!!!
const _kDefaultFontFamily = 'Roboto';

/// App text style.
// ignore_for_file: prefer-match-file-name
enum AppTextStyle {
  regular11(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontSize: 11,
    ),
  ),
  regular12(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontSize: 12,
    ),
  ),
  regular13(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontSize: 13,
    ),
  ),
  regular14(TextStyle(fontSize: 14)),
  regular15(
    TextStyle(
      fontSize: 15,
      fontFamily: _kDefaultFontFamily,
    ),
  ),
  regular16(
    TextStyle(
      fontSize: 16,
      fontFamily: _kDefaultFontFamily,
    ),
  ),
  regular18(
    TextStyle(
      fontSize: 18,
      fontFamily: _kDefaultFontFamily,
    ),
  ),
  regular20(
    TextStyle(
      fontSize: 20,
      fontFamily: _kDefaultFontFamily,
    ),
  ),

  medium11(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
    ),
  ),

  medium12(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  ),
  medium13(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),
  ),
  medium14(
    TextStyle(
      fontSize: 14,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
    ),
  ),
  medium15(
    TextStyle(
      fontSize: 15,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
    ),
  ),
  medium16(
    TextStyle(
      fontSize: 16,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
    ),
  ),
  medium18(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
  ),
  medium20(
    TextStyle(
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
  ),

  bold10(
    TextStyle(
      fontSize: 10,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w700,
    ),
  ),

  bold11(
    TextStyle(
      fontSize: 11,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w700,
    ),
  ),

  bold13(
    TextStyle(
      fontSize: 13,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w700,
    ),
  ),

  bold14(
    TextStyle(
      fontSize: 14,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w700,
    ),
  ),
  bold16(
    TextStyle(
      fontSize: 16,
      fontFamily: _kDefaultFontFamily,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
  );

  final TextStyle value;

  // ignore: sort_constructors_first
  const AppTextStyle(this.value);
}
