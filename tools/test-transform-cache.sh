#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-cache.sh COMPILER.wasm | --native}
mkdir -p .tmp/transform-cache
self_host_measure 'transform cache request tool build' \
  moon build --target native --release src/self_host_bootstrap_fixture
mode=dew
if [[ "$compiler" == --native ]]; then
  mode=native
  self_host_measure 'transform cache native compiler build' \
    moon build --target native --release src/dew_cli
  compiler=_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe
else
  compiler=$(self_host_node_facet_compiler "$compiler")
fi
self_host_measure 'transform cache fresh-process checks' \
  python3 tools/test-transform-cache.py "$mode" "$compiler"
