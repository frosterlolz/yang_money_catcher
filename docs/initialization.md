## Перед запуском приложения
1 - запустить билд-раннер в packages/database/
 -- cd packages/database && dart run build_runner build --delete-conflicting-outputs
2 - запустить кодогенерацию в основном проекте
 -- (если вы внутри database) -> cd ../../
 -- make codegen (если make запустить нет возможности см пункт ниже)
 -- flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter gen-l10n
3 - запускать через main.dart файл (точно совместимая версия флаттер находится в файле .tool-versions)

## Мок данные (чтобы не создавать вручную большое кол-во транзакций)
Мок данные генерируются автоматически, если соответствующая таблица не заполнена
Если необходимо запустить проект БЕЗ генерации мок данных:
 - найти шаги инициализации: InitializationRoot -> _prepareInitializationSteps
 - закомментировать вызовы методов .generateMockData() (можно найти все через ctrl+f)