#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
compiler=${1:?usage: tools/test-transform-source-pool.sh COMPILER.wasm}
work=.tmp/transform-source-pool
mkdir -p "$work"
python3 - "$work/unused.dew" <<'PY'
from pathlib import Path
import sys
Path(sys.argv[1]).write_bytes(b'\xff invalid unused pool source')
PY
self_host_measure 'source-pool request tool build' \
  moon build --target native --release src/self_host_bootstrap_fixture
fixture=_build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe
for kind in imported generated; do
  sources=(examples/transforms/imported.dew
    --pool-module example.tools examples/transforms/tools.dew)
  if [[ "$kind" == generated ]]; then
    sources=(tools/dew-test/transform-source-pool/generated.dew
      --pool-module example.late tools/dew-test/transform-source-pool/late.dew
      --pool-module example.constants tools/dew-test/transform-source-pool/constants.dew)
  fi
  rm -f "$work/$kind.wasm"
  self_host_measure "$kind source-pool request" "$fixture" \
    "$work/$kind.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin "$work/$kind.wasm" example.app \
    "${sources[@]}" --pool-module example.unused "$work/unused.dew" --standard-root "$PWD"
  self_host_measure "$kind source-pool compilation" \
    self_host_run_node_facet "$compiler" "$work/$kind.bin"
  self_host_measure "$kind source-pool Wasm validation" \
    wasm-tools validate --features all "$work/$kind.wasm"
  self_host_measure "$kind source-pool execution" \
    node -e 'WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();const result=instance.exports.main();if(result!==42)throw Error(`expected 42, got ${result}`);console.log(`main() = ${result}`)})' "$work/$kind.wasm"
done
