class DataResult<T> {
  const DataResult({
    required this.data,
    required this.isOffline,
  });

  const DataResult.offline({
    required this.data,
  }) : isOffline = true;

  const DataResult.online({
    required this.data,
  }) : isOffline = false;

  final T data;
  final bool isOffline;
}
