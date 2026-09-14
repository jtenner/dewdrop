#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/self-host-common.sh
native_flags=()
if [[ "${DEW_SHORT_INFERENCE_NATIVE_PROFILE:-release}" == release ]]; then
  native_flags=(--release)
fi
work=.tmp/short-inference-self-host
all_tests=0
if [[ "${1:-}" == --all ]]; then
  all_tests=1
  shift
  work=.tmp/short-inference-all-tests
fi
mkdir -p "$work"
self_host_ensure_starshine_ffi
test_args=("$work/tests.raw.wasm" self_host.compiler
  self_host.compiler ffi.dew self_host/starshine/ffi.dew)
test_filter=(--filter 'short inference')
if (( all_tests )); then
  mapfile -t sources < <(rg --files self_host/compiler -g '*.dew' | sort)
  sources+=(self_host/starshine/fingerprint.dew self_host/starshine/smoke.dew)
  test_filter=(--allow-unused-host-imports)
else
  mapfile -t sources < <(rg --files self_host/compiler -g '*.dew' -g '!main.dew' -g '!*_test.dew' | sort)
  sources+=(self_host/compiler/semantic_imported_semantics_test.dew self_host/compiler/semantic_short_inference_test.dew)
fi
for source in "${sources[@]}"; do
  test_args+=(self_host.compiler "${source##*/}" "$source")
done
self_host_measure 'short inference self-host test generation' env DEW_STD_ROOT="$PWD" \
  moon run --target native "${native_flags[@]}" src/dew_test_gen -- "${test_args[@]}"
self_host_measure 'short inference time provider' \
  wasm-tools parse tools/moonbit-time-provider.wat -o "$work/time.wasm"
self_host_measure 'short inference self-host test link' \
  moon run --target native "${native_flags[@]}" src/self_host_link_fixture -- \
    "$work/tests.raw.wasm" starshine-mb/dist/ffi/starshine-ffi.wasm \
    fixtures/facet/facet-adapter.wasm "$work/time.wasm" "$work/tests.wasm" --single-validation
self_host_measure 'short inference self-host tests' \
  node tools/dew-test/run.mjs --wasm "$work/tests.wasm" "${test_filter[@]}" "$@"
self_host_measure 'short inference emitted execution' \
  node tools/check-short-inference-emission.mjs "$work/tests.wasm"
