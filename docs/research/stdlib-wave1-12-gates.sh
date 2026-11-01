set -uo pipefail
cd /data/workspace/wave1-item-12
export PATH=/tmp/burn-starshine-fix-tools:/data/workspace/wave1-control:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/directory-cc"
mkdir -p .tmp/directory-logs
trap 'rm -rf _build .mooncakes .dew/cache; find .tmp tools/dew-test -type f \( -name "*.wasm" -o -name "*harness*" \) -delete' EXIT
status=0
run() {
  local label="$1"
  shift
  /usr/bin/time -f 'TIME %e RSS_KB %M' "$@" > ".tmp/directory-logs/$label.log" 2>&1
  local code=$?
  echo "$label exit=$code"
  tail -16 ".tmp/directory-logs/$label.log"
  if [ "$code" != 0 ]; then status=1; fi
  return "$code"
}
run generator python3 tools/generate_directory_std.py --check
run identities python3 tools/generate_standard_module_identities.py --check
if run focused moon run -j 1 --target native src/dew_test_gen -- .tmp/directory.wasm app.directory app.directory std/tests/directory_test.dew std/tests/directory_test.dew; then
 run focused_runtime node tools/dew-test/run.mjs --wasm .tmp/directory.wasm
fi
if run probe moon run -j 1 --target native src/dew_test_gen -- .tmp/directory_operations.wasm app.directory_operations app.directory_operations tools/dew-test/directory_operations.dew tools/dew-test/directory_operations.dew; then
 run host_runtime node --expose-gc tools/check-directory-operations.mjs .tmp/directory_operations.wasm
fi
if run production moon run -j 1 --target native src/module_snapshot_gen -- .tmp/directory-consumer.wasm production app.directory directory-consumer.dew docs/research/stdlib-wave1-12-consumer.dew; then
 run production_runtime node tools/check-directory-consumer.mjs .tmp/directory-consumer.wasm
fi
run equivalence moon test -j 1 --target native src/standard_loader/interface_bundle_cache_wbtest.mbt --filter 'bootstrap and on-disk standard providers are byte identical'
run registry env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh -j 1
run integration env DEW_INTEGRATION_TEST_FILES='src/semantic/module_system_wbtest.mbt src/semantic/standard_preamble_wbtest.mbt' bash tools/test-integration-native.sh -j 1
run interfaces moon info --target native src/standard_sources
run generated bash tools/check-generated.sh
exit "$status"
