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
through_b=0
binaryen=0
for argument in "$@"; do
  case "$argument" in
    --clean) build_cache_args=(--no-build-cache) ;;
    --fast) self_host_runtime=node-facet ;;
    --through-b) through_b=1 ;;
    --binaryen) binaryen=1 ;;
    *)
      echo "usage: tools/check-self-host-bootstrap.sh [--clean] [--fast] [--through-b] [--binaryen]" >&2
      exit 2
      ;;
  esac
done

source tools/self-host-common.sh

if (( binaryen )); then
  if ! command -v wasm-opt >/dev/null 2>&1; then
    echo "self-host: --binaryen needs wasm-opt" >&2
    exit 1
  fi
  wasm_opt_path=$(command -v wasm-opt)
  wasm_opt_version=$("$wasm_opt_path" --version)
  read -r wasm_opt_sha _ < <(sha256sum "$wasm_opt_path")
  echo "self-host: Binaryen $wasm_opt_version"
  echo "self-host: wasm-opt sha256 $wasm_opt_sha"
fi

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

prepare_compiler() {
  local raw=$1
  local compiler=$2
  local stage=$3
  self_host_measure "compiler $stage raw validation" \
    wasm-tools validate --features all "$raw"
  if (( ! binaryen )); then
    cp "$raw" "$compiler"
    return
  fi
  self_host_measure "Binaryen compiler optimization: $stage" \
    "$wasm_opt_path" "$raw" \
      --enable-gc \
      --enable-reference-types \
      --enable-simd \
      --enable-bulk-memory \
      --enable-tail-call \
      --enable-multivalue \
      -O3 \
      --shrink-level=1 \
      -o "$compiler"
  local raw_size
  local optimized_size
  raw_size=$(wc -c < "$raw")
  optimized_size=$(wc -c < "$compiler")
  echo "self-host: Binaryen size $stage: $raw_size -> $optimized_size bytes"
  self_host_measure "compiler $stage Binaryen validation" \
    wasm-tools validate --features all "$compiler"
}

self_host_measure "compiler A build" tools/dew build \
  --link-wasm starshine "$provider" \
  --link-wasm facet "$facet_provider" \
  --link-wasm __moonbit_time_unstable "$time_provider" \
  "${build_cache_args[@]}" \
  -o "$work/a/compiler.raw.wasm" \
  "${sources[@]}"
prepare_compiler "$work/a/compiler.raw.wasm" "$work/a/compiler.wasm" A
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
  local validation_args=()
  if [[ "$self_host_runtime" == node-facet ]]; then
    validation_args=(--single-validation)
  fi
  self_host_measure "compiler output link: $(basename "$(dirname "$input")")" \
    moon run --target native --release src/self_host_link_fixture -- \
      "$input" "$provider" "$facet_provider" "$time_provider" "$output" \
      "${validation_args[@]}"
  if wasm-tools print "$output" | grep '(import "wasi_snapshot_preview1"' >/dev/null; then
    echo "self-host: linked compiler retains wasi_snapshot_preview1 imports" >&2
    return 1
  fi
  if wasm-tools print "$output" | grep '(import "link:' >/dev/null; then
    echo "self-host: linked compiler retains unresolved provider imports" >&2
    return 1
  fi
}

write_request "$work/a" compiler-b-core.wasm
run_stage "$work/a/compiler.wasm" "$work/a/request.bin"
mv compiler-b-core.wasm "$work/a/compiler-b-core.wasm"
self_host_measure "compiler B core validation" \
  wasm-tools validate --features all "$work/a/compiler-b-core.wasm"
link_stage_output "$work/a/compiler-b-core.wasm" "$work/b/compiler.raw.wasm"
prepare_compiler "$work/b/compiler.raw.wasm" "$work/b/compiler.wasm" B
self_host_measure "compiler B validation" \
  wasm-tools validate --features all "$work/b/compiler.wasm"
if [[ "$self_host_runtime" == node-facet ]]; then
  self_host_measure "compiler B semantic probes" \
    node --stack-size=65500 tools/run-dew-facet.mjs "$work/b/compiler.wasm" --check-semantic-probes
fi

if (( through_b )); then
  echo "self-host compiler B checkpoint passed"
  exit 0
fi

write_request "$work/b" compiler-c-core.wasm
run_stage "$work/b/compiler.wasm" "$work/b/request.bin"
mv compiler-c-core.wasm "$work/b/compiler-c-core.wasm"
self_host_measure "compiler C core validation" \
  wasm-tools validate --features all "$work/b/compiler-c-core.wasm"
link_stage_output "$work/b/compiler-c-core.wasm" "$work/c/compiler.raw.wasm"
prepare_compiler "$work/c/compiler.raw.wasm" "$work/c/compiler.wasm" C
self_host_measure "compiler C validation" \
  wasm-tools validate --features all "$work/c/compiler.wasm"

cmp "$work/a/compiler-b-core.wasm" "$work/b/compiler-c-core.wasm"
cmp "$work/b/compiler.raw.wasm" "$work/c/compiler.raw.wasm"
cmp "$work/b/compiler.wasm" "$work/c/compiler.wasm"

b_raw_sha=$(sha256sum "$work/b/compiler.raw.wasm" | cut -d' ' -f1)
c_raw_sha=$(sha256sum "$work/c/compiler.raw.wasm" | cut -d' ' -f1)
b_sha=$(sha256sum "$work/b/compiler.wasm" | cut -d' ' -f1)
c_sha=$(sha256sum "$work/c/compiler.wasm" | cut -d' ' -f1)
echo "self-host fixed point passed"
echo "compiler B raw sha256: $b_raw_sha"
echo "compiler C raw sha256: $c_raw_sha"
echo "compiler B sha256: $b_sha"
echo "compiler C sha256: $c_sha"
