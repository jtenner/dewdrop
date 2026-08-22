#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/self-host-bootstrap
provider=starshine-mb/dist/ffi/starshine-ffi.wasm
fingerprint=self_host/starshine/fingerprint-prefix.bin
root_module=self_host.compiler

mapfile -t compiler_sources < <(
  find self_host/compiler -maxdepth 1 -name '*.dew' ! -name '*_test.dew' | sort
)
sources=(
  self_host/starshine/ffi.dew
  self_host/starshine/fingerprint.dew
  "${compiler_sources[@]}"
)

rm -rf "$work"
mkdir -p "$work/a" "$work/b" "$work/c"

tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py --check

tools/dew build \
  --link-wasm starshine "$provider" \
  --no-build-cache \
  -o "$work/a/compiler.wasm" \
  "${sources[@]}"
wasm-tools validate --features all "$work/a/compiler.wasm"

write_request() {
  local directory=$1
  local output=$2
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$directory/request.bin" \
    "$provider" \
    "$fingerprint" \
    "$output" \
    "$root_module" \
    "${sources[@]}"
}

run_stage() {
  local compiler=$1
  local request=$2
  NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs "$compiler" "$request"
}

write_request "$work/a" compiler-b.wasm
run_stage "$work/a/compiler.wasm" "$work/a/request.bin"
mv "$work/a/compiler-b.wasm" "$work/b/compiler.wasm"
wasm-tools validate --features all "$work/b/compiler.wasm"

write_request "$work/b" compiler-c.wasm
run_stage "$work/b/compiler.wasm" "$work/b/request.bin"
mv "$work/b/compiler-c.wasm" "$work/c/compiler.wasm"
wasm-tools validate --features all "$work/c/compiler.wasm"

cmp "$work/b/compiler.wasm" "$work/c/compiler.wasm"

b_sha=$(sha256sum "$work/b/compiler.wasm" | cut -d' ' -f1)
c_sha=$(sha256sum "$work/c/compiler.wasm" | cut -d' ' -f1)
echo "self-host fixed point passed"
echo "compiler B sha256: $b_sha"
echo "compiler C sha256: $c_sha"
