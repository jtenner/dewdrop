#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh

for file in src/semantic/import_intern_bench_wbtest.mbt src/cache_binary/loaded_index_bench_test.mbt; do
  self_host_measure "compile imports $file" \
    moon bench --target js --release --no-parallelize "$file"
done

# Compare the current source identity with hashing a freshly built compiler.
# This is an experiment only; the bootstrap still uses its source identity.
self_host_measure 'build compiler for identity benchmark' \
  moon run --target js --release -j 8 --build-only src/dew_cli
export DEW_REPOSITORY_ROOT="$PWD"
export DEW_BENCH_COMPILER_ARTIFACT="$PWD/_build/js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js"
self_host_measure 'bootstrap identity benchmark' \
  moon bench --target native --release --no-parallelize src/dew_bootstrap/fingerprint_bench_wbtest.mbt
