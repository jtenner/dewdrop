#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/reference-identity
mkdir -p "$work"
self_host_measure 'reference identity native generator build' \
  moon build --target native --release src/dew_test_gen
self_host_measure 'reference identity test generation' env DEW_STD_ROOT="$PWD" \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  "$work/tests.wasm" reference_identity \
  reference_identity reference_identity_test.dew tools/dew-test/reference_identity_test.dew
self_host_measure 'reference identity Wasm validation' \
  mise exec wasm-tools@1.262.0 -- wasm-tools validate "$work/tests.wasm"
self_host_measure 'reference identity runtime tests' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" --label 'reference identity'
