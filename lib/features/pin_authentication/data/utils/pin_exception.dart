sealed class PinException implements Exception {
  const PinException();

  abstract final String internalMessage;
}

final class PinException$Invalid extends PinException {
  const PinException$Invalid(this.internalMessage);

  @override
  final String internalMessage;
}

final class PinException$Forbidden extends PinException {
  const PinException$Forbidden(this.internalMessage);

  @override
  final String internalMessage;
}
