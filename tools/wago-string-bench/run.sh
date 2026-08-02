#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

moon run --target native --release src/string_bench_gen
wasm-tools parse tools/wago-string-bench/v128_array_probe.wat \
  -o tools/wago-string-bench/v128_array_probe.wasm
wasm-tools validate --features all tools/wago-string-bench/v128_array_probe.wasm
node --expose-gc tools/wago-string-bench/bench.mjs

printf '\nWago V128 GC-array support probe:\n'
if ! (
  cd tools/wago-enum-bench
  go run . \
    -compile 1 \
    -instantiate 1 \
    -warmup 10 \
    -exec 100 \
    -heap-mib 64 \
    -export run \
    ../wago-string-bench/v128_array_probe.wasm
); then
  printf 'Wago does not yet accept array<mut v128>; Node results remain valid.\n'
fi
