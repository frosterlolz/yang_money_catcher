#!/usr/bin/env bash

if [ "$(basename "$PWD")" = 'scripts' ]; then cd ..; fi

sh scripts/clean_ios.sh
sh scripts/build_runner.sh
