#!/bin/bash
set -uo pipefail
cd /data/workspace/wave1-wildcard-fix
D="$PWD/docs/research/data/stdlib-wave1-wildcard-fix"
export PATH="$D/native-tools:/data/workspace/tools:/data/home/.moon/bin:$PATH"
export MOON_CC="$PWD/docs/research/data/stdlib-wave1/native-tools/cc"
exec 9>/data/workspace/wave1-control/build.lock
flock -x 9 || exit $?
cleanup() {
  rm -rf _build .mooncakes .dew/cache .tmp/wildcard tools/module-snapshots/__pycache__
  find tools/dew-test -maxdepth 1 -type f -name '*.wasm' -delete
  rm -f .tmp/iter-consumer.wasm .tmp/iter-consumer.wat
}
trap cleanup EXIT
mkdir -p .tmp/wildcard
status=0
run() {
  local label=$1
  shift
  /usr/bin/time -p "$@" > "$D/$label.log" 2>&1
  local result=$?
  printf '%s %s\n' "$label" "$result" | tee -a "$D/status"
  if ((result)); then status=1; fi
}
: > "$D/status"
run focused env DEW_INTEGRATION_TEST_FILES='src/semantic/program_function_type_preflight_wbtest.mbt src/semantic/program_link_plan_wbtest.mbt src/semantic/wasmgc_fragment_plan_wbtest.mbt src/semantic/program_physical_reference_invariants_wbtest.mbt src/semantic/program_physical_type_invariants_wbtest.mbt' bash tools/test-integration-native.sh
run snapshots python3 "$D/snapshots.py"
run adapters moon run --target native src/dew_test_gen -- .tmp/wildcard/adapters.wasm dew.std dew.std std/tests/iter_adapters_test.dew std/tests/iter_adapters_test.dew
if [[ -f .tmp/wildcard/adapters.wasm ]]; then run adapters-runtime node tools/dew-test/run.mjs --wasm .tmp/wildcard/adapters.wasm; fi
run consumer moon run --target native src/module_snapshot_gen -- .tmp/iter-consumer.wasm production app.consumer consumer.dew docs/research/stdlib-wave1-08/consumer.dew fixture.callbacks provider.dew docs/research/stdlib-wave1-08/provider.dew
if [[ -f .tmp/iter-consumer.wasm ]]; then
  run consumer-wat wasm-tools print .tmp/iter-consumer.wasm -o .tmp/iter-consumer.wat
  run consumer-runtime node --expose-gc docs/research/stdlib-wave1-08/check.mjs
fi
run std bash tools/dew-test/run.sh
exit "$status"
