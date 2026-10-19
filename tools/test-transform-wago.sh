#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-wago.sh COMPILER.wasm}
work=.tmp/transform-wago
mkdir -p "$work"
self_host_measure 'pinned Wago host build' \
  mise exec go@1.27.2 -- go -C tools/wago-transform-host build -mod=readonly -o "$PWD/$work/host" .
self_host_measure 'Wago compiler adapter' \
  python3 tools/prepare-wago-compiler.py "$compiler" "$work/compiler.wasm"
self_host_measure 'Wago transform request' \
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$work/request.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin "$work/output.wasm" \
    example.app examples/transforms/local.dew
rm -f "$work/output.wasm"
self_host_measure 'native Wago transform execution' \
  "$work/host" run -p8 --core 3 --local --locked --no-input \
    --gc-heap 2GiB --gc-nursery 512MiB "$work/compiler.wasm" "$work/request.bin"
self_host_measure 'native Wago transform output validation' \
  wasm-tools validate --features all "$work/output.wasm"
self_host_measure 'native Wago transform result' \
  node -e 'WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{const result=instance.exports.main();if(result!==42)throw Error(`expected 42, got ${result}`);console.log(`main() = ${result}`)})' "$work/output.wasm"
