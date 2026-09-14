#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/self-host-performance-tests
mkdir -p "$work"
self_host_ensure_starshine_ffi
args=("$work/tests-core.wasm" self_host.compiler self_host.compiler ffi.dew self_host/starshine/ffi.dew)
mapfile -t sources < <(rg --files self_host/compiler -g '*.dew' -g '!main.dew' -g '!*_test.dew' | sort)
sources+=(self_host/compiler/semantic_slot_arrays_test.dew)
for source in "${sources[@]}"; do
  args+=(self_host.compiler "${source##*/}" "$source")
done
self_host_measure 'performance test generator build' \
  moon run --target native --release --build-only src/dew_test_gen
self_host_measure 'performance test generation' env DEW_STD_ROOT="$PWD" \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe "${args[@]}"
self_host_measure 'performance test time provider' \
  wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'performance test linker build' \
  moon run --target native --release --build-only src/self_host_link_fixture
self_host_measure 'performance test link' \
  _build/native/release/build/jtenner/dewdrop/self_host_link_fixture/self_host_link_fixture.exe \
    "$work/tests-core.wasm" starshine-mb/dist/ffi/starshine-ffi.wasm \
    fixtures/facet/facet-adapter.wasm "$work/time.wasm" "$work/tests.wasm" --single-validation
self_host_measure 'performance test execution' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" --filter 'slot arrays' "$@"
