#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== generated sources =="
python3 tools/generate_preamble_sources.py --check
python3 tools/generate_lane_std.py --check
python3 tools/test_packed_builtin_policy.py
python3 tools/test_scalar_builtin_policy.py
python3 tools/test_memory_builtin_policy.py
python3 tools/test_arithmetic_builtin_policy.py
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
