set -uo pipefail
cd /data/workspace/wave1-item-05
export PATH=/data/workspace/wave1-control:/tmp/burn-starshine-fix-tools:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
export MOON_CC="$PWD/.tmp/hex-cc"
gate_status=0
mkdir -p .tmp/hex-logs
cleanup() {
  rm -rf _build .mooncakes .dew/cache
  find .tmp -type f \( -name '*.wasm' -o -name '*.wat' \) -delete
}
trap cleanup EXIT
run() {
  name=$1
  shift
  /usr/bin/time -f 'TIME %e RSS_KB %M' "$@" > ".tmp/hex-logs/$name.log" 2>&1
  status=$?
  if [ "$status" != 0 ]; then
    gate_status=1
  fi
  echo "$name status=$status"
  tail -12 ".tmp/hex-logs/$name.log"
  return "$status"
}
run generator python3 tools/generate_hex_std.py --check
run identities python3 tools/generate_standard_module_identities.py --check
if run focused moon run -j 1 --target native src/dew_test_gen -- .tmp/hex.wasm dew.std dew.std std/tests/hex_test.dew std/tests/hex_test.dew; then
  run runtime node tools/dew-test/run.mjs --wasm .tmp/hex.wasm
fi
run info_help moon info --help
run info moon info --target native src/standard_sources
if run random_compile moon run -j 1 --target native src/dew_test_gen -- .tmp/random.wasm dew.std dew.std hex-reference_test.dew .tmp/hex-reference_test.dew; then
  run random_runtime node tools/dew-test/run.mjs --wasm .tmp/random.wasm
  run benchmark node --expose-gc tools/hex-benchmark.mjs .tmp/random.wasm
fi
run registry env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh
run integration env DEW_INTEGRATION_TEST_FILES='src/semantic/standard_preamble_wbtest.mbt src/semantic/module_system_wbtest.mbt' bash tools/test-integration-native.sh
if run production tools/dew build .tmp/hex-consumer.dew -o .tmp/consumer.wasm; then
  run production_runtime node tools/hex-consumer-check.mjs .tmp/consumer.wasm
fi
run check_generated bash tools/check-generated.sh
exit "$gate_status"
