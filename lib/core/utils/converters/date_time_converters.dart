abstract class DateTimeConverter {
  static String toIsoDTString(DateTime dateTime) => dateTime.toUtc().toIso8601String();

  static String? maybeToIsoDTString(DateTime? dateTime) => dateTime == null ? null : toIsoDTString(dateTime);

  static DateTime fromJson(String isoDtString) => DateTime.parse(isoDtString).toLocal();

  static DateTime? maybeFromJson(String? isoDtString) => isoDtString == null ? null : fromJson(isoDtString);
}
