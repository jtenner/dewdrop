#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== generated sources =="
python3 tools/generate_lane_std.py --check
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
python3 tools/generate_standard_builtin_registry.py --check
python3 tools/generate_std_tests.py --check
node --test tools/dew-test/metadata.test.mjs tools/dew-abi-metadata.test.mjs
node --check tools/dew-abi-metadata.mjs
node --check tools/dew-abi.mjs
node --check tools/dew-wasm-consumer.mjs
node --check tools/wasm-metrics.mjs
python3 tools/dew_cli_test.py
python3 tools/cli-fixtures.py

