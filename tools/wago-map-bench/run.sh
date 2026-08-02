#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

count=${COUNT:-512}
calls=${CALLS:-20}
rounds=${ROUNDS:-7}
work=.tmp/map-growth-bench
mkdir -p "$work"
python3 tools/wago-map-bench/generate.py \
  --count "$count" \
  --output "$work/workload.dew"
tools/dew build "$work/workload.dew" -o "$work/workload.wasm"
node tools/wago-map-bench/bench.mjs "$work/workload.wasm" "$calls" "$rounds"
(
  cd tools/wago-map-bench
  go run . --calls "$calls" --rounds "$rounds" ../../"$work/workload.wasm"
)
