#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

source tools/self-host-common.sh
work=.tmp/self-host-hardening
mkdir -p "$work"
self_host_ensure_starshine_ffi
self_host_measure 'hardening real-library request' \
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$work/array.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-array-probe.wasm \
    app.array_probes tools/dew-test/array_operations.dew
self_host_measure 'hardening raw GC storage request' \
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$work/raw-gc.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-raw-gc-probe.wasm \
    app.raw_gc tools/dew-test/raw_gc_storage.dew
self_host_measure 'hardening raw Unit array request' \
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$work/raw-gc-unit.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-raw-gc-unit-probe.wasm \
    app.raw_gc_unit tools/dew-test/raw_gc_unit.dew
mapfile -t compiler_sources < <(
  find self_host/compiler -maxdepth 1 -name '*.dew' ! -name '*_test.dew' ! -name main.dew | sort
)
test_args=("$work/tests.raw.wasm" self_host.compiler self_host.compiler ffi.dew self_host/starshine/ffi.dew)
for source in "${compiler_sources[@]}" \
  self_host/compiler/compiler_runtime_assertions_test.dew \
  self_host/compiler/semantic_wasm_body_plan_test.dew \
  self_host/compiler/semantic_physical_specialization_test.dew \
  self_host/compiler/semantic_raw_conversions_test.dew \
  self_host/compiler/semantic_raw_memory_test.dew \
  self_host/compiler/semantic_raw_arithmetic_test.dew \
  self_host/compiler/semantic_raw_math_test.dew \
  self_host/compiler/semantic_raw_simd_test.dew \
  self_host/compiler/semantic_specialization_shapes_test.dew \
  self_host/compiler/semantic_capture_inference_test.dew \
  self_host/compiler/semantic_lambda_fragments_test.dew \
  self_host/compiler/semantic_local_unification_test.dew \
  self_host/compiler/semantic_impl_index_test.dew \
  self_host/compiler/semantic_imported_semantics_test.dew \
  self_host/compiler/semantic_compile_time_types_test.dew \
  self_host/compiler/semantic_imported_trait_contract_test.dew \
  self_host/compiler/semantic_solver_invariants_test.dew
do
  test_args+=(self_host.compiler "${source#self_host/compiler/}" "$source")
done
self_host_measure 'hardening test generation' env DEW_STD_ROOT="$PWD" \
  moon run --target native --release src/dew_test_gen -- "${test_args[@]}"
self_host_measure 'hardening time provider' \
  wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'hardening test link' \
  moon run --target native --release src/self_host_link_fixture -- \
    "$work/tests.raw.wasm" starshine-mb/dist/ffi/starshine-ffi.wasm \
    fixtures/facet/facet-adapter.wasm "$work/time.wasm" "$work/tests.wasm" \
    --single-validation
test_status=0
self_host_measure 'hardening tests' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" \
    --label 'self-host hardening tests' "$@" || test_status=1
self_host_measure 'hardening invariant records' \
  node tools/check-self-host-invariants.mjs "$work/tests.wasm" || test_status=1
self_host_measure 'hardening host record decoder' \
  node --test tools/self-host-invariant-record.test.mjs || test_status=1
self_host_measure 'hardening emission probes' \
  node tools/check-self-host-emission.mjs "$work/tests.wasm" || test_status=1
self_host_measure 'hardening semantic probes' \
  node tools/check-self-host-semantic-probes.mjs "$work/tests.wasm" || test_status=1
exit "$test_status"
