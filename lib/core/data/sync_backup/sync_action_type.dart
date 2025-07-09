enum SyncActionType {
  create,
  update,
  delete;

  factory SyncActionType.fromName(String name) => values.firstWhere((e) => e.name == name);
}
