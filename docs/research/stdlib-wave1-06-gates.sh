set -uo pipefail
cd /data/workspace/wave1-item-06
export PATH=/data/workspace/wave1-control:/tmp/burn-starshine-fix-tools:/data/workspace/tools:/data/home/.moon/bin:/usr/local/bin:/usr/bin:/bin
mkdir -p .tmp
cat > .tmp/clang <<'CC'
#!/usr/bin/env bash
exec /usr/bin/clang "$@" -fbracket-depth=4096 -g0 -O0
CC
chmod +x .tmp/clang
export MOON_CC="$PWD/.tmp/clang"
cleanup() {
  rm -rf _build .mooncakes .dew/cache
  find .tmp tools/dew-test -type f \( -name '*.wasm' -o -name '*harness*' \) -delete
}
trap cleanup EXIT
status=0
run() {
  local label="$1"
  shift
  /usr/bin/time -v "$@" > ".tmp/$label.log" 2>&1
  local code=$?
  echo "$label exit=$code"
  tail -28 ".tmp/$label.log"
  if [ "$code" != 0 ]; then status=1; fi
  return "$code"
}
run binary_generator python3 tools/generate_binary_std.py --check
run identity_generator python3 tools/generate_standard_module_identities.py --check
if run focused moon run -j 1 --target native src/dew_test_gen -- .tmp/binary.wasm dew.std dew.std std/tests/binary_codec_test.dew std/tests/binary_codec_test.dew; then
  run focused_runtime node tools/dew-test/run.mjs --wasm .tmp/binary.wasm
fi
if run consumer moon run -j 1 --target native src/module_snapshot_gen -- .tmp/consumer.wasm production app.binary binary-consumer.dew docs/research/stdlib-wave1-06-consumer.dew; then
  run runtime node --expose-gc docs/research/stdlib-wave1-06-runtime.mjs .tmp/consumer.wasm
fi
run equivalence moon test -j 1 --target native src/standard_loader/interface_bundle_cache_wbtest.mbt --filter 'bootstrap and on-disk standard providers are byte identical'
run registry env DEW_NATIVE_TEST_PACKAGES=standard_sources bash tools/test-native.sh -j 1
run integration env DEW_INTEGRATION_TEST_FILES='src/semantic/module_system_wbtest.mbt src/semantic/standard_preamble_wbtest.mbt' bash tools/test-integration-native.sh -j 1
run interfaces moon info --target native src/standard_sources
run generated bash tools/check-generated.sh
exit "$status"
