!!! Прежде чем выполнять команды- необходимо убедиться, что мы находимся в нужно разделе (/packages/database)

1 - кодоген
dart run build_runner build --delete-conflicting-outputs

2 - миграция
*предварительно не забыть увеличить счетчик миграций
dart run drift_dev make-migrations