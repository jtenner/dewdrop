#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tools/dew-test/assemble.py
node tools/dew-test/run.mjs \
  --builtin-traps tools/dew-test/builtin_traps.wasm \
  --label "Dew stdlib tests" \
  "$@"
node tools/check-scalar-conversions.mjs tools/dew-test/scalar_conversions.wasm
node tools/check-memory-operations.mjs tools/dew-test/memory_operations.wasm
node tools/check-simd-memory-operations.mjs tools/dew-test/simd-memory-operations.wasm
node tools/check-arithmetic-operations.mjs tools/dew-test/arithmetic_operations.wasm
node tools/check-math-operations.mjs tools/dew-test/math_operations.wasm
node tools/check-specialization-products.mjs tools/dew-test/specialization_products.wasm
node tools/check-specialization-callbacks.mjs tools/dew-test/specialization_callbacks.wasm
