#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
if [[ $# != 1 || ! -f $1 ]]; then
  echo 'usage: tools/test-named-function-identity.sh COMPILER_WASM' >&2
  exit 2
fi
compiler=$1
work=.tmp/named-function-identity
mkdir -p "$work"
self_host_measure 'named function identity request tool build' \
  moon build --target native --release src/self_host_bootstrap_fixture
fixture=_build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe
for source in tools/dew-test/generic-identity/*.dew \
  tools/dew-test/named-function-identity/{no_references,plain_singleton_only,startup_once,fresh_captures,bound_receiver_wrapper,cross_module_main}.dew \
  examples/transforms/signatures.dew; do
  name=$(basename "$source" .dew)
  extra=()
  if [[ $name == cross_module_main ]]; then
    extra=(--module example.helper tools/dew-test/named-function-identity/cross_module_helper.dew)
  fi
  self_host_measure "$name request" "$fixture" \
    "$work/$name.request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin "$work/$name.wasm" \
    example.app "$source" "${extra[@]}" --standard-root "$PWD"
  self_host_measure "$name Dew compilation" \
    self_host_run_node_facet "$compiler" "$work/$name.request.bin"
  self_host_measure "$name Wasm validation" \
    wasm-tools validate --features all "$work/$name.wasm"
  self_host_measure "$name runtime identity" \
    node tools/check-named-function-identity.mjs "$work/$name.wasm"
done
