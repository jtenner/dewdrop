#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh

# The shipped CLI uses JavaScript. The slower content-hash cases use three
# sample groups to keep each measured activity below 30 seconds.
files=(
  src/cache_binary/byte_decode_bench_test.mbt
  src/cache_binary/index_search_bench_test.mbt
  src/core_linker/subtype_lookup_bench_wbtest.mbt
  src/core_linker/subtype_link_bench_test.mbt
  src/semantic/content_hash_bench_test.mbt
)
for file in "${files[@]}"; do
  self_host_measure "compile hot paths $file" \
    moon bench --target js --release --no-parallelize "$file"
done
