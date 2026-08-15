#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
out="$root/fixtures/starshine_guest/starshine-guest.wasm"
tmp="$out.tmp"

cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

cd "$root"
moon build src/starshine_guest --target wasm-gc --release
artifact="$root/_build/wasm-gc/release/build/jtenner/dewdrop/starshine_guest/starshine_guest.wasm"
wasm-tools validate --features all "$artifact"
cp "$artifact" "$tmp"
mv "$tmp" "$out"
moon clean
trap - EXIT
