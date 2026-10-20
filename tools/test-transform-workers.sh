#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-workers.sh COMPILER.wasm [HOST]}
host=${2:-}
if [[ -z "$host" ]]; then
  mkdir -p .tmp/transform-workers
  work=$(mktemp -d .tmp/transform-workers/host-XXXXXXXX)
  host=$work/host
  self_host_measure 'Wago worker host build' mise exec go@1.27.2 wasm-tools@1.262.0 -- \
    python3 tools/build-wago-transform-host.py "$host" --test
fi
self_host_measure 'worker request tool build' moon build --target native --release src/self_host_bootstrap_fixture
self_host_measure 'serial and parallel Wago transform checks' mise exec wasm-tools@1.262.0 -- \
  python3 tools/test-transform-workers.py "$compiler" "$host"
