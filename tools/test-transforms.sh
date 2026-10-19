#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/transforms
mkdir -p "$work"
self_host_ensure_starshine_ffi
mapfile -t compiler_sources < <(rg --files self_host/compiler -g '*.dew' -g '!**/*_test.dew' -g '!**/main.dew' | sort)
test_args=("$work/tests.raw.wasm" self_host.compiler
  self_host.compiler ffi.dew self_host/starshine/ffi.dew
  self_host.compiler ffi_smoke.dew self_host/starshine/smoke.dew)
for source in "${compiler_sources[@]}" self_host/compiler/transform_test.dew self_host/compiler/transform_reference_test.dew self_host/compiler/transform_intrinsic_contracts_test.dew self_host/compiler/transform_intrinsic_arguments_test.dew self_host/compiler/transform_vector_test.dew self_host/compiler/transform_scalar_bits_test.dew self_host/compiler/transform_expression_types_test.dew self_host/compiler/semantic_function_value_overloads_test.dew self_host/compiler/request_test.dew; do
  test_args+=(self_host.compiler "${source#self_host/compiler/}" "$source")
done
self_host_measure 'transform native generator build' moon build --target native --release src/dew_test_gen
self_host_measure 'transform interpreter test generation' env DEW_STD_ROOT="$PWD" \
  moon run --target native --release src/dew_test_gen -- "${test_args[@]}"
self_host_measure 'transform time provider' wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'transform test link' moon run --target native --release src/self_host_link_fixture -- \
  "$work/tests.raw.wasm" starshine-mb/dist/ffi/starshine-ffi.wasm \
  fixtures/facet/facet-adapter.wasm "$work/time.wasm" "$work/tests.wasm" --single-validation
self_host_measure 'transform interpreter tests' node tools/dew-test/run.mjs --wasm "$work/tests.wasm" \
  --allow-unused-host-imports --label 'compile-time transforms' "$@"
