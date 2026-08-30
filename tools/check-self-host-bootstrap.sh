#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

root=$PWD
work=$root/.tmp/self-host-bootstrap
provider=starshine-mb/dist/ffi/starshine-ffi.wasm
facet_provider=fixtures/facet/facet-adapter.wasm
time_provider_wat=tools/moonbit-time-provider.wat
time_provider=$work/moonbit-time-provider.wasm
fingerprint=self_host/starshine/fingerprint-prefix.bin
root_module=self_host.compiler
build_cache_args=()
self_host_runtime=wago
for argument in "$@"; do
  case "$argument" in
    --clean) build_cache_args=(--no-build-cache) ;;
    --fast) self_host_runtime=node-facet ;;
    *)
      echo "usage: tools/check-self-host-bootstrap.sh [--clean] [--fast]" >&2
      exit 2
      ;;
  esac
done

source tools/self-host-common.sh

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

self_host_ensure_starshine_ffi
self_host_measure "MoonBit time provider build" \
  wasm-tools parse "$time_provider_wat" -o "$time_provider"

self_host_measure "compiler A build" tools/dew build \
  --link-wasm starshine "$provider" \
  --link-wasm facet "$facet_provider" \
  --link-wasm __moonbit_time_unstable "$time_provider" \
  "${build_cache_args[@]}" \
  -o "$work/a/compiler.wasm" \
  "${sources[@]}"
self_host_measure "compiler A validation" \
  wasm-tools validate --features all "$work/a/compiler.wasm"

write_request() {
  local directory=$1
  local output=$2
  self_host_measure "compiler request build: $(basename "$directory")" \
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
  self_host_measure "compiler execution ($self_host_runtime): $(basename "$(dirname "$compiler")")" \
    self_host_run_cached_failure "$self_host_runtime" "$compiler" "$request"
}

link_stage_output() {
  local input=$1
  local output=$2
  self_host_measure "compiler output link: $(basename "$(dirname "$input")")" \
    moon run --target native --release src/self_host_link_fixture -- \
      "$input" "$provider" "$facet_provider" "$time_provider" "$output"
  if wasm-tools print "$output" | grep -q '(import "wasi_snapshot_preview1"'; then
    echo "self-host: linked compiler retains wasi_snapshot_preview1 imports" >&2
    return 1
  fi
  if wasm-tools print "$output" | grep -q '(import "link:'; then
    echo "self-host: linked compiler retains unresolved provider imports" >&2
    return 1
  fi
}

write_request "$work/a" compiler-b-core.wasm
run_stage "$work/a/compiler.wasm" "$work/a/request.bin"
mv compiler-b-core.wasm "$work/a/compiler-b-core.wasm"
link_stage_output "$work/a/compiler-b-core.wasm" "$work/b/compiler.wasm"
self_host_measure "compiler B validation" \
  wasm-tools validate --features all "$work/b/compiler.wasm"

write_request "$work/b" compiler-c-core.wasm
run_stage "$work/b/compiler.wasm" "$work/b/request.bin"
mv compiler-c-core.wasm "$work/b/compiler-c-core.wasm"
link_stage_output "$work/b/compiler-c-core.wasm" "$work/c/compiler.wasm"
self_host_measure "compiler C validation" \
  wasm-tools validate --features all "$work/c/compiler.wasm"

cmp "$work/b/compiler.wasm" "$work/c/compiler.wasm"

b_sha=$(sha256sum "$work/b/compiler.wasm" | cut -d' ' -f1)
c_sha=$(sha256sum "$work/c/compiler.wasm" | cut -d' ' -f1)
echo "self-host fixed point passed"
echo "compiler B sha256: $b_sha"
echo "compiler C sha256: $c_sha"
