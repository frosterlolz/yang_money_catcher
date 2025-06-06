#!/usr/bin/env bash

if [ "$(basename "$PWD")" = 'scripts' ]; then cd ..; fi

flutter pub get &&
  dart run build_runner build --delete-conflicting-outputs &&
  sh scripts/intl_with_format.sh
