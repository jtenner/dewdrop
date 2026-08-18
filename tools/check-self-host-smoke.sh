#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/self-host-smoke

tools/starshine-ffi.sh build
python3 tools/generate_starshine_ffi_consumer.py --check
tools/dew test \
  self_host/compiler/tokenizer.dew \
  self_host/compiler/parser.dew \
  self_host/compiler/tokenizer_test.dew \
  self_host/compiler/parser_test.dew

rm -rf "$work"
mkdir -p "$work/a" "$work/b" "$work/reject-fingerprint" "$work/reject-count"

sources=(
  self_host/starshine/ffi.dew
  self_host/starshine/fingerprint.dew
  self_host/compiler/tokenizer.dew
  self_host/compiler/parser.dew
  self_host/compiler/request.dew
  self_host/compiler/starshine_module.dew
  self_host/compiler/main.dew
)

build_compiler() {
  local stage=$1
  tools/dew build \
    --link-wasm starshine starshine-mb/dist/ffi/starshine-ffi.wasm \
    --no-build-cache \
    -o "$work/$stage/compiler.wasm" \
    "${sources[@]}"
  wasm-tools validate --features all "$work/$stage/compiler.wasm"
}

write_request() {
  local stage=$1
  moon run --target native --release src/self_host_smoke_fixture -- \
    "$work/$stage/request.bin" \
    starshine-mb/dist/ffi/starshine-ffi.wasm \
    self_host/starshine/fingerprint-prefix.bin \
    output.wasm
}

run_compiler() {
  local stage=$1
  NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
    "$work/$stage/compiler.wasm" \
    "$work/$stage/request.bin"
  wasm-tools validate --features all "$work/$stage/output.wasm"
  wasm-tools print "$work/$stage/output.wasm" | grep -Fq 'i32.const 73'
}

build_compiler a
build_compiler b
cmp "$work/a/compiler.wasm" "$work/b/compiler.wasm"
write_request a
write_request b
run_compiler a
run_compiler b
cmp "$work/a/output.wasm" "$work/b/output.wasm"

cp "$work/a/compiler.wasm" "$work/reject-fingerprint/compiler.wasm"
cp "$work/a/request.bin" "$work/reject-fingerprint/request.bin"
python3 - "$work/reject-fingerprint/request.bin" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
data = bytearray(path.read_bytes())
data[-1] ^= 1
path.write_bytes(data)
PY
if NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
  "$work/reject-fingerprint/compiler.wasm" \
  "$work/reject-fingerprint/request.bin"; then
  echo "self-host smoke accepted a mismatched compiler fingerprint" >&2
  exit 1
fi
test ! -e "$work/reject-fingerprint/output.wasm"

cp "$work/a/compiler.wasm" "$work/reject-count/compiler.wasm"
cp "$work/a/request.bin" "$work/reject-count/request.bin"
python3 - "$work/reject-count/request.bin" <<'PY'
from pathlib import Path
import struct
import sys
path = Path(sys.argv[1])
data = bytearray(path.read_bytes())
offset = 20
output_length = struct.unpack_from("<I", data, offset)[0]
offset += 4 + output_length
root_length = struct.unpack_from("<I", data, offset)[0]
offset += 4 + root_length
struct.pack_into("<I", data, offset, 0xFFFFFFFF)
path.write_bytes(data)
PY
if NODE_NO_WARNINGS=1 node tools/run-dew-wasi.mjs \
  "$work/reject-count/compiler.wasm" \
  "$work/reject-count/request.bin"; then
  echo "self-host smoke accepted an unbounded module count" >&2
  exit 1
fi
test ! -e "$work/reject-count/output.wasm"

compiler_sha=$(sha256sum "$work/a/compiler.wasm" | cut -d' ' -f1)
output_sha=$(sha256sum "$work/a/output.wasm" | cut -d' ' -f1)
echo "self-host source-request smoke passed"
echo "compiler sha256: $compiler_sha"
echo "output sha256: $output_sha"
