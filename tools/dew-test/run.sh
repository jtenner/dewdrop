#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
python3 tools/dew-test/assemble.py
node tools/dew-test/run.mjs \
  --builtin-traps tools/dew-test/builtin_traps.wasm \
  --label "Dew stdlib tests" \
  "$@"
node tools/check-scalar-conversions.mjs tools/dew-test/scalar_conversions.wasm
