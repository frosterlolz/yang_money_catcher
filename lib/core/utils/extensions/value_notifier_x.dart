import 'package:flutter/cupertino.dart';

extension ValueNotifierX<T> on ValueNotifier<T> {
  // ignore: use_setters_to_change_properties
  void emit(T value) => this.value = value;
}
