#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/transforms
mkdir -p "$work"
self_host_ensure_starshine_ffi
self_host_measure 'transform standard test data' python3 tools/generate_transform_test_pool.py "$work/standard-pool.dew"
mapfile -t compiler_sources < <(rg --files self_host/compiler -g '*.dew' -g '!**/*_test.dew' -g '!**/main.dew' | sort)
test_args=("$work/tests.raw.wasm" self_host.compiler
  self_host.compiler transform_fixture_std_pool.dew "$work/standard-pool.dew"
  self_host.compiler ffi.dew self_host/starshine/ffi.dew
  self_host.compiler ffi_smoke.dew self_host/starshine/smoke.dew)
for source in "${compiler_sources[@]}" self_host/compiler/transform_test.dew self_host/compiler/transform_reference_test.dew self_host/compiler/transform_intrinsic_contracts_test.dew self_host/compiler/transform_intrinsic_arguments_test.dew self_host/compiler/transform_vector_test.dew self_host/compiler/transform_scalar_bits_test.dew self_host/compiler/transform_frames_test.dew self_host/compiler/transform_default_products_test.dew self_host/compiler/transform_product_carriers_test.dew self_host/compiler/semantic_physical_type_demand_test.dew self_host/compiler/semantic_raw_null_test.dew self_host/compiler/semantic_generic_raw_builtin_test.dew self_host/compiler/transform_frame_roots_test.dew self_host/compiler/transform_generic_impl_test.dew self_host/compiler/transform_generic_identity_test.dew self_host/compiler/transform_text_operations_test.dew self_host/compiler/transform_environment_test.dew self_host/compiler/transform_loop_guards_test.dew self_host/compiler/transform_bytecode_test.dew self_host/compiler/transform_raw_bool_test.dew self_host/compiler/transform_memory_test.dew self_host/compiler/transform_memory_source_test.dew self_host/compiler/transform_memory_goldens_test.dew self_host/compiler/transform_vector_contracts_test.dew self_host/compiler/semantic_compile_time_qualified_guards_test.dew self_host/compiler/transform_expression_types_test.dew self_host/compiler/semantic_function_value_overloads_test.dew self_host/compiler/request_test.dew; do
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
