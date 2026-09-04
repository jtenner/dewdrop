#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if (( $# == 0 )); then
  echo "usage: tools/check-self-host-probe.sh [--clean] [--reuse-b] SOURCE..." >&2
  exit 2
fi

clean_args=()
reuse_b=0
sources=()
for argument in "$@"; do
  case "$argument" in
    --clean) clean_args=(--clean) ;;
    --reuse-b) reuse_b=1 ;;
    *) sources+=("$argument") ;;
  esac
done
if (( ${#sources[@]} == 0 )); then
  echo "self-host probe needs at least one Dew source file" >&2
  exit 2
fi

bootstrap_args=(--fast --through-b)
bootstrap_args+=("${clean_args[@]}")
if (( ! reuse_b )); then
  tools/check-self-host-bootstrap.sh "${bootstrap_args[@]}"
fi

source tools/self-host-common.sh
root=$PWD
work=$root/.tmp/self-host-bootstrap
probe=$root/.tmp/self-host-probe
provider=starshine-mb/dist/ffi/starshine-ffi.wasm
fingerprint=self_host/starshine/fingerprint-prefix.bin
mkdir -p "$probe"
if [[ ! -f "$work/b/compiler.wasm" ]]; then
  echo "self-host probe compiler B checkpoint is missing" >&2
  exit 2
fi
rm -f "$probe/request.bin" "$probe/output-core.wasm"

self_host_measure "compiler B probe request build" \
  moon run --target native --release src/self_host_bootstrap_fixture -- \
    "$probe/request.bin" \
    "$provider" \
    "$fingerprint" \
    "$probe/output-core.wasm" \
    self_host.probe \
    "${sources[@]}"

self_host_measure "compiler B focused probe execution" \
  self_host_run_cached_failure \
    node-facet \
    "$work/b/compiler.wasm" \
    "$probe/request.bin"

wasm-tools validate --features all "$probe/output-core.wasm"
echo "self-host compiler B focused probe passed"
