#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh

files=(
  src/parser/compile_scaling_bench_test.mbt
  src/semantic/compile_scaling_bench_test.mbt
  src/backend/compile_scaling_bench_test.mbt
  src/cache_binary/compile_scaling_bench_test.mbt
  src/core_linker/compile_scaling_bench_wbtest.mbt
)
for file in "${files[@]}"; do
  self_host_measure "compile scaling $file" \
    moon bench --target native --release --no-parallelize "$file"
done
