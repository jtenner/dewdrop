#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
if (( $# > 1 )); then
  echo 'usage: tools/test-runtime-raw-bool.sh [dew_cli.js]' >&2
  exit 2
fi
compiler=${1:-_build/js/release/build/jtenner/dewdrop/dew_cli/dew_cli.js}
if (( $# == 0 )); then
  self_host_measure 'raw Bool Native compiler build' moon build --target js --release src/dew_cli
fi
work=.tmp/runtime-raw-bool
mkdir -p "$work"
for kind in runtime transform; do
  source="tools/dew-test/raw-bool-bits/$kind.dew"
  output="$work/$kind.wasm"
  self_host_measure "raw Bool compile: $kind" env DEW_STD_ROOT="$PWD" \
    node "$compiler" build -o "$output" "$source"
  self_host_measure "raw Bool validate: $kind" \
    mise exec wasm-tools@1.262.0 -- wasm-tools validate "$output"
  self_host_measure "raw Bool execute: $kind" node - "$output" tools/dew-test/raw-bool-bits/expected.json <<'JS'
const fs = require('node:fs');
const assert = require('node:assert/strict');
const module_ = new WebAssembly.Module(fs.readFileSync(process.argv[2]));
assert.deepEqual(WebAssembly.Module.imports(module_), []);
const instance = new WebAssembly.Instance(module_, {});
instance.exports.__dew_init?.();
const expected = JSON.parse(fs.readFileSync(process.argv[3], 'utf8'));
const actual = {};
for (const [name, value] of Object.entries(expected)) {
  assert.equal(typeof instance.exports[name], 'function', `missing export ${name}`);
  actual[name] = instance.exports[name]();
  assert.equal(actual[name], value, name);
}
console.log(JSON.stringify(actual));
JS
done
