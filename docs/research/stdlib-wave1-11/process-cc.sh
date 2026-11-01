#!/usr/bin/env bash
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
