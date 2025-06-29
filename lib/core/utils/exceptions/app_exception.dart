import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:yang_money_catcher/core/types/json_types.dart';

/// {@template AppException.class}
/// Базовый класс для имплементации ошибок приложения
/// Сформированная ошибка НЕ передается в крашлитику, тк является ожидаемой
/// {@endtemplate}

/// {@macro AppException.class}
abstract interface class AppException implements Exception {
  /// Сообщение для отображения в UI
  abstract final String? message;
}

/// {@template AppException$Inputs.class}
/// Базовый класс для реализации ошибок полей
/// {@endtemplate}
abstract base class AppException$Inputs implements AppException {
  /// {@macro AppException$Inputs.class}
  const AppException$Inputs();

  /// Ищет [String] сообщение для конкретного ключа [key]
  /// Предполагается, что структура ошибки придет в мормате
  /// ```json
  /// {
  ///  "status": "error",
  ///  "inputs": {
  ///   "key1": "Message 1",
  ///   "key2": "Message 2"
  ///   },
  ///   "message": "common message"
  /// }
  /// ```
  @protected
  static String? findInputMessage(String key, JsonMap data) {
    final inputs = data['inputs'];
    if (inputs is! JsonMap) return null;

    try {
      final res = inputs[key];
      if (res is! String) return null;

      return res;
    } on Object catch (_) {
      return null;
    }
  }

  /// Обозначение отсутствия ошибок инпутов (может присутствовать общее сообщение)
  @mustBeOverridden
  bool get isInputsEmpty;
}

/// {@template AppException$Simple.class}
/// Базовая ошибка с возможным сообщением для отображения в UI
/// {@endtemplate}
final class AppException$Simple implements AppException {
  /// {@macro AppException$Simple.class}
  const AppException$Simple(this.message);

  /// Ищет [String] общее сообщение об ошибке
  /// Предполагается, что структура ошибки придет в мормате
  /// ```json
  /// {
  ///  "status": "error",
  ///  "message": "common message"
  /// }
  /// ```
  factory AppException$Simple.fromStructuredException(JsonMap json) {
    final message = json['message'];
    if (message is! String) return const AppException$Simple(null);

    return AppException$Simple(message);
  }

  @override
  final String? message;
}

/// {@template AppException$EventReason.class}
/// Ошибка, связанная с каким либо событием (чтобы можно в дальнейшем отреагировать только не него)
/// {@endtemplate}
final class AppException$EventReason implements AppException {
  /// {@macro AppException$EventReason.class}
  const AppException$EventReason({this.message, required this.event});

  /// Событие, в следствие которого возникла ошибка
  /// Например "после какого эвента случилась ошибка"
  final Object event;

  @override
  final String? message;
}
