#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
if (( $# > 1 )); then
  echo 'usage: tools/test-runtime-generic-identity.sh [dew_cli.js]' >&2
  exit 2
fi
compiler=${1:-_build/js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js}
if (( $# == 0 )); then
  self_host_measure 'runtime identity Native compiler build' moon build --target js --release src/dew_cli
fi
work=.tmp/runtime-generic-identity
mkdir -p "$work"
for source in tools/dew-test/generic-identity/*.dew; do
  name=$(basename "$source" .dew)
  output="$work/$name.wasm"
  self_host_measure "runtime identity compile: $name" env DEW_STD_ROOT="$PWD" \
    node "$compiler" build -o "$output" "$source"
  self_host_measure "runtime identity validate: $name" \
    mise exec wasm-tools@1.262.0 -- wasm-tools validate "$output"
  self_host_measure "runtime identity execute: $name" node - "$output" <<'JS'
const fs = require('node:fs');
const assert = require('node:assert/strict');
const module_ = new WebAssembly.Module(fs.readFileSync(process.argv[2]));
assert.deepEqual(WebAssembly.Module.imports(module_), []);
const instance = new WebAssembly.Instance(module_, {});
instance.exports.__dew_init?.();
assert.equal(instance.exports.main(), 42);
console.log('initialized main()=42');
JS
done
