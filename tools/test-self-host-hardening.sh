#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

source tools/self-host-common.sh
native_build_flags=(--release)
case "${DEW_HARDENING_NATIVE_PROFILE:-release}" in
  release) ;;
  debug) native_build_flags=() ;;
  *) echo "DEW_HARDENING_NATIVE_PROFILE must be release or debug" >&2; exit 2 ;;
esac
work=.tmp/self-host-hardening
mkdir -p "$work"
self_host_ensure_starshine_ffi
self_host_measure 'hardening real-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/array.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-array-probe.wasm \
    app.array_probes tools/dew-test/array_operations.dew
self_host_measure 'hardening ring-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/ring.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-ring-probe.wasm \
    app.ring_probes tools/dew-test/ring_operations.dew
self_host_measure 'hardening Map-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/map.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-map-probe.wasm \
    app.map_probes tools/dew-test/map_operations.dew
self_host_measure 'hardening Set-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/set.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-set-probe.wasm \
    app.set_probes tools/dew-test/set_operations.dew
self_host_measure 'hardening Bytes-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/bytes.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-bytes-probe.wasm \
    app.bytes_probes tools/dew-test/bytes_operations.dew
self_host_measure 'hardening StringView-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/string-view.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-string-view-probe.wasm \
    app.string_view_probes tools/dew-test/string_view_operations.dew
self_host_measure 'hardening String-library request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/string.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-string-probe.wasm \
    app.string_probes tools/dew-test/string_operations.dew
self_host_measure 'hardening raw GC storage request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/raw-gc.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-raw-gc-probe.wasm \
    app.raw_gc tools/dew-test/raw_gc_storage.dew
self_host_measure 'hardening String pattern request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/string-patterns.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-string-pattern-probe.wasm \
    app.string_patterns tools/dew-test/string_patterns.dew
self_host_measure 'hardening raw Unit array request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/raw-gc-unit.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-raw-gc-unit-probe.wasm \
    app.raw_gc_unit tools/dew-test/raw_gc_unit.dew
self_host_measure 'hardening FixedArray request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/fixed-array.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-fixed-array-probe.wasm \
    app.fixed_array_probes tools/dew-test/fixed_array_operations.dew
self_host_measure 'hardening raw array contract request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/raw-array-contracts.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-raw-array-contracts.wasm \
    app.raw_array_contracts tools/dew-test/raw_array_contracts.dew
self_host_measure 'hardening type-query request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/type-queries.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-type-query-probe.wasm \
    app.type_queries tools/dew-test/type_queries.dew
self_host_measure 'hardening WASI foreign request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/wasi-foreign.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-wasi-foreign.wasm \
    app.wasi_probes tests/module-snapshots/wasm/wasi-preview1-runtime.dew
self_host_measure 'hardening Debug dispatch request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/debug-dispatch.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-debug-dispatch.wasm \
    app.debug_probes tools/dew-test/debug_dispatch.dew
self_host_measure 'hardening product pattern request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/product-patterns.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-product-patterns.wasm \
    app.product_patterns tools/dew-test/product_patterns.dew
self_host_measure 'hardening integer Debug request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/debug-integers.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-debug-integers.wasm \
    app.debug_integers tools/dew-test/debug_integers.dew
self_host_measure 'hardening float Debug request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/debug-floats.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-debug-floats.wasm \
    app.debug_floats tools/dew-test/debug_floats.dew
self_host_measure 'hardening V128 Debug request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/debug-vectors.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-debug-vectors.wasm \
    app.debug_vectors tools/dew-test/debug_vectors.dew
self_host_measure 'hardening WASI Bytes request' \
  moon run --target native "${native_build_flags[@]}" src/self_host_bootstrap_fixture -- \
    "$work/wasi-bytes.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin unused-wasi-bytes.wasm \
    app.wasi_bytes tools/dew-test/wasi_bytes.dew
mapfile -t compiler_sources < <(
  find self_host/compiler -maxdepth 1 -name '*.dew' ! -name '*_test.dew' ! -name main.dew | sort
)
test_args=("$work/tests.raw.wasm" self_host.compiler
  self_host.compiler ffi.dew self_host/starshine/ffi.dew
  self_host.compiler ffi_smoke.dew self_host/starshine/smoke.dew)
for source in "${compiler_sources[@]}" \
  self_host/compiler/compiler_runtime_assertions_test.dew \
  self_host/compiler/parser_pattern_test.dew \
  self_host/compiler/semantic_product_patterns_test.dew \
  self_host/compiler/semantic_wasm_body_plan_test.dew \
  self_host/compiler/semantic_physical_body_tables_test.dew \
  self_host/compiler/semantic_body_child_ownership_test.dew \
  self_host/compiler/semantic_physical_specialization_test.dew \
  self_host/compiler/semantic_method_context_test.dew \
  self_host/compiler/semantic_text_operators_test.dew \
  self_host/compiler/semantic_raw_conversions_test.dew \
  self_host/compiler/semantic_raw_memory_test.dew \
  self_host/compiler/semantic_raw_arithmetic_test.dew \
  self_host/compiler/semantic_raw_math_test.dew \
  self_host/compiler/semantic_array_runtime_test.dew \
  self_host/compiler/semantic_raw_simd_test.dew \
  self_host/compiler/semantic_specialization_shapes_test.dew \
  self_host/compiler/semantic_capture_inference_test.dew \
  self_host/compiler/semantic_lambda_fragments_test.dew \
  self_host/compiler/semantic_local_unification_test.dew \
  self_host/compiler/semantic_body_arena_contracts_test.dew \
  self_host/compiler/semantic_impl_index_test.dew \
  self_host/compiler/semantic_impl_type_walk_test.dew \
  self_host/compiler/semantic_trait_evidence_test.dew \
  self_host/compiler/semantic_interface_type_walk_test.dew \
  self_host/compiler/semantic_imported_semantics_test.dew \
  self_host/compiler/semantic_standard_module_ids_test.dew \
  self_host/compiler/semantic_compile_time_types_test.dew \
  self_host/compiler/semantic_computed_types_test.dew \
  self_host/compiler/semantic_compile_time_queries_test.dew \
  self_host/compiler/semantic_physical_type_demand_test.dew \
  self_host/compiler/semantic_imported_trait_contract_test.dew \
  self_host/compiler/semantic_solver_invariants_test.dew \
  self_host/compiler/semantic_module_graph_invariants_test.dew \
  self_host/compiler/semantic_link_invariants_test.dew \
  self_host/compiler/semantic_constructor_flow_test.dew
do
  test_args+=(self_host.compiler "${source#self_host/compiler/}" "$source")
done
self_host_measure 'hardening test generation' env DEW_STD_ROOT="$PWD" \
  moon run --target native "${native_build_flags[@]}" src/dew_test_gen -- "${test_args[@]}"
self_host_measure 'hardening time provider' \
  wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'hardening test link' \
  moon run --target native "${native_build_flags[@]}" src/self_host_link_fixture -- \
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
