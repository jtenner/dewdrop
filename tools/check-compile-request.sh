#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/compile-request-smoke
rm -rf "$work"
mkdir -p "$work/a" "$work/b"

write_request() {
  local stage=$1
  moon run --target native --release src/compile_request_fixture -- \
    "$work/$stage/request.bin" \
    "$work/$stage/compiler.wasm"
}

run_request() {
  local stage=$1
  (
    cd "$work/$stage"
    DEW_CACHE_DIR="$work/forbidden-cache-$stage" \
    DEW_PARSE_EVENT_CACHE=1 \
    DEW_INTERFACE_CACHE=1 \
    DEW_BODY_CACHE=1 \
    DEW_BODY_FAMILY_CACHE=1 \
    DEW_PLAN_CACHE=1 \
    DEW_CACHE_PACK=1 \
    DEW_PROGRAM_CACHE=1 \
      moon run --target native --release "$root/src/dew_cli" -- \
        --compile-request "$work/$stage/request.bin"
  )
  wasm-tools validate "$work/$stage/compiler.wasm"
  test ! -e "$work/forbidden-cache-$stage"
}

write_request a
run_request a
write_request b
run_request b
cmp "$work/a/compiler.wasm" "$work/b/compiler.wasm"

echo "source-Bytes compile request smoke passed"
