#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
work=.tmp/scalar-intrinsics
mkdir -p "$work"
compiler=${1:-}
if (( $# > 1 )); then
  echo "usage: tools/test-scalar-intrinsics.sh [COMPILER.wasm]" >&2
  exit 2
fi
python3 tools/generate_wasm_scalar_intrinsics.py --check
python3 tools/generate_self_host_numeric_builtins.py --check
python3 tools/generate_scalar_intrinsic_tests.py --check
self_host_measure 'scalar intrinsic native generator build' \
  moon build --target native --release src/dew_test_gen
self_host_measure 'scalar intrinsic test generation' env DEW_STD_ROOT="$PWD" \
  _build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe \
  "$work/tests.wasm" scalar_intrinsics \
  scalar_intrinsics scalar_intrinsics.dew tools/dew-test/scalar_intrinsics.dew \
  scalar_intrinsics scalar_intrinsics_test.dew tools/dew-test/scalar_intrinsics_test.dew
self_host_measure 'scalar intrinsic Wasm validation' \
  mise exec wasm-tools@1.262.0 -- wasm-tools validate "$work/tests.wasm"
self_host_measure 'scalar intrinsic runtime tests' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" --label 'scalar intrinsics'
if [[ -n "$compiler" ]]; then
  self_host_measure 'scalar intrinsic request packer build' \
    moon build --target native --release src/self_host_bootstrap_fixture
  for case_ in overloads scalar_intrinsics; do
    source=examples/transforms/overloads.dew
    if [[ "$case_" == scalar_intrinsics ]]; then
      source=tools/dew-test/scalar_intrinsics.dew
    fi
    self_host_measure "scalar request pack: $case_" \
      _build/native/release/build/jtenner/dewdrop/self_host_bootstrap_fixture/self_host_bootstrap_fixture.exe \
      "$work/$case_.bin" starshine-mb/dist/ffi/starshine-ffi.wasm \
      self_host/starshine/fingerprint-prefix.bin "$work/$case_.wasm" example.app "$source"
    self_host_measure "scalar Dew request: $case_" \
      self_host_run_cached_failure node-facet "$compiler" "$work/$case_.bin"
    self_host_measure "scalar Dew output validation: $case_" \
      mise exec wasm-tools@1.262.0 -- wasm-tools validate "$work/$case_.wasm"
    self_host_measure "scalar Dew output execution: $case_" \
      node -e 'const fs=require("fs"); const assert=require("node:assert/strict"); WebAssembly.instantiate(fs.readFileSync(process.argv[1])).then(({instance})=>{assert.equal(instance.exports.main(),42); console.log("main()=42")})' "$work/$case_.wasm"
  done
fi
