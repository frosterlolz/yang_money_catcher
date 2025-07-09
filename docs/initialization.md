# 🚀 Инициализация проекта YangMoneyCatcher

Перед запуском убедитесь, что выполнены следующие шаги подготовки проекта.

---

## 🧱 1. Генерация кода

### 📦 Для пакета `database`
Перейдите в папку `packages/database` и выполните генерацию `.g.dart` файлов:
```bash
cd packages/database
dart run build_runner build --delete-conflicting-outputs
```

### 🧩 Для основного проекта
```bash
cd ../../ # (если вы внутри database)
```
#### Запустите генерацию:
```bash
make codegen
```

### ⚠️ Если make недоступен, выполните команды вручную:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

## ⚙️ 2. Конфигурация окружения
В директории config/ по образцу config.template.json создайте файл dev.json.

Пример содержимого:
```json
{
  "ENVIRONMENT": "dev",
  "BASE_URL": "***",
  "AUTH_TOKEN": "***"
}
```

## 🏁 3. Запуск приложения
Запускайте приложение через файл main.dart, добавляя параметр --dart-define-from-file:
```bash
flutter run --dart-define-from-file=config/dev.json
```

### ✅ Поддерживаемая версия Flutter указана в .tool-versions