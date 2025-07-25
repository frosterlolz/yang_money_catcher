#!/usr/bin/env bash
set -e

# Перейти во временную директорию пакета localization
pushd packages/localization > /dev/null

# Сгенерировать локализации
flutter gen-l10n

# При необходимости отформатировать сгенерированные файлы (если нужно)
sh ../../scripts/format.sh

# Вернуться обратно в корень репозитория
popd > /dev/null
