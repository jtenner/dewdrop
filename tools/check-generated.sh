#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== generated sources =="
python3 tools/generate_preamble_sources.py --check
python3 tools/generate_types_std.py --check
python3 tools/generate_standard_module_identities.py --check
python3 tools/generate_lane_std.py --check
python3 tools/generate_simd_intrinsics.py --check
python3 tools/test_simd_builtin_policy.py
python3 tools/test_packed_builtin_policy.py
python3 tools/test_scalar_builtin_policy.py
python3 tools/test_memory_builtin_policy.py
python3 tools/test_wasi_foreign_policy.py
python3 tools/test_debug_dispatch_policy.py
python3 tools/test_debug_integer_policy.py
python3 tools/test_debug_float_policy.py
python3 tools/test_debug_vector_policy.py
python3 tools/test_debug_swar_policy.py
python3 tools/test_debug_unit_policy.py
python3 tools/test_debug_bool_policy.py
python3 tools/test_debug_text_policy.py
python3 tools/test_intrinsic_name_policy.py
python3 tools/test_variant_lookup_policy.py
python3 tools/test_option_layout_policy.py
python3 tools/test_result_layout_policy.py
python3 tools/test_global_read_policy.py
python3 tools/test_call_target_read_policy.py
python3 tools/test_local_declaration_policy.py
python3 tools/test_callback_signature_policy.py
python3 tools/test_removed_link_recovery_policy.py
python3 tools/test_trait_call_policy.py
python3 tools/test_assertion_library_policy.py
python3 tools/test_production_assertion_policy.py
python3 tools/test_wasi_write_runtime_policy.py
python3 tools/test_wasi_staging_policy.py
python3 tools/test_arithmetic_builtin_policy.py
python3 tools/test_math_builtin_policy.py
python3 tools/test_array_builtin_policy.py
python3 tools/test_queue_builtin_policy.py
python3 tools/test_deque_builtin_policy.py
python3 tools/test_circular_buffer_builtin_policy.py
python3 tools/test_map_builtin_policy.py
python3 tools/test_set_builtin_policy.py
python3 tools/test_bytes_algorithm_policy.py
python3 tools/test_string_view_algorithm_policy.py
python3 tools/test_string_algorithm_policy.py
python3 tools/test_string_simd_library_policy.py
python3 tools/test_bytes_simd_library_policy.py
python3 tools/test_bytes_length_policy.py
python3 tools/test_bytes_view_policy.py
python3 tools/test_bytes_access_policy.py
python3 tools/test_bytes_builder_storage_policy.py
python3 tools/test_builder_length_policy.py
python3 tools/test_builder_defaults_policy.py
python3 tools/test_text_cast_policy.py
python3 tools/test_string_builder_append_policy.py
python3 tools/test_string_builder_storage_policy.py
python3 tools/test_runtime_protocol_retirement_policy.py
python3 tools/generate_self_host_numeric_builtins.py --check
python3 tools/generate_string_std.py --check
python3 tools/generate_wasi_std.py --check
python3 tools/generate_wasm_intrinsics_std.py --check
python3 tools/generate_fixed_array_std.py --check
python3 tools/generate_array_std.py --check
python3 tools/generate_map_std.py --check
python3 tools/generate_set_std.py --check
python3 tools/generate_stack_std.py --check
python3 tools/generate_queue_std.py --check
python3 tools/generate_circular_buffer_std.py --check
python3 tools/generate_deque_std.py --check
python3 tools/generate_ordering_std.py --check
python3 tools/generate_binary_heap_std.py --check
python3 tools/generate_priority_queue_std.py --check
python3 tools/generate_red_black_tree_std.py --check
python3 tools/generate_ordered_map_std.py --check
python3 tools/generate_ordered_set_std.py --check
python3 tools/generate_show_std.py --check
python3 tools/generate_disposable_std.py --check
python3 tools/generate_iter_std.py --check
python3 tools/generate_math_std.py --check
python3 tools/generate_io_std.py --check
python3 tools/generate_testing_std.py --check
python3 tools/generate_bloom_filter_std.py --check
python3 tools/generate_blake3_std.py --check
python3 tools/generate_sha256_std.py --check
python3 tools/generate_facet_bindings.py --check
python3 tools/generate_host_std.py --check
python3 tools/generate_package_std.py --check
PYTHONPATH=tools python3 tools/test_starshine_ffi_consumer.py
(
  cd starshine-mb
  bun test scripts/lib/wasm-export-renaming.test.ts
)
tools/check-facet.sh
python3 tools/generate_json_std.py --check
python3 tools/generate_text_iteration_std.py --check
python3 tools/generate_utf8_std.py --check
python3 tools/generate_standard_builtin_registry.py --check
python3 tools/generate_std_tests.py --check
node --test tools/dew-test/metadata.test.mjs tools/dew-abi-metadata.test.mjs
node --check tools/dew-abi-metadata.mjs
node --check tools/dew-abi.mjs
node --check tools/dew-wasm-consumer.mjs
node --check tools/wasm-metrics.mjs
node --check tools/run-dew-wasi.mjs
node --check tools/run-dew-facet.mjs
python3 -m py_compile tools/export-wasm-memory.py
moon test --target native src/dew_bootstrap
python3 tools/cli-fixtures.py
